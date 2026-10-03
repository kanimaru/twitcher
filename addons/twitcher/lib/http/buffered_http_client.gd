@icon("./buffered-http-icon.svg")
@tool
extends Node

## Http client that buffers the requests and sends at most [member max_parallel_requests]
## of them at the same time. Everything above that limit waits in a queue and is
## dispatched in the order it was requested as soon as a slot gets free.
class_name BufferedHTTPClient


## Will be send when a new request was added to queue
signal request_added(request: RequestData)

## Will be send when a request is done.
signal request_done(response: ResponseData)


## Contains the request data to be send
class RequestData extends RefCounted:
	## The client that the request belongs too
	var client: BufferedHTTPClient
	## The request node that is executing the request (null while the request waits in the queue)
	var http_request: HTTPRequest
	## Path of the request
	var path: String
	## The method that is used to call request
	var method: int
	## The request headers
	var headers: Dictionary
	## The body that is requested (TODO does it make more sense to make a Byte Array out of it?)
	var body: String = ""
	## Amount of retries
	var retry: int
	## `Time.get_ticks_msec()` when the request was put on the wire (first attempt or retry)
	var started_at: int

	## When you are done free the request
	func queue_free() -> void:
		if http_request != null:
			http_request.queue_free()
			http_request = null


## Contains the response data
class ResponseData extends RefCounted:
	## Result of the request see `HTTPRequest.Result`
	var result: int
	## Response code from the request like 200 for OK
	var response_code: int
	## the initial request data
	var request_data: RequestData
	## The body of the response as byte array
	var response_data: PackedByteArray
	## The response header as dictionary, where multiple keys are concatenated with ';'
	var response_header: Dictionary
	## Had the response an error
	var error: bool

	## When you are done free the request
	func queue_free() -> void:
		request_data.queue_free()

## When a request fails max_error_count then cancel that request -1 for endless amount of tries.
@export var max_error_count : int = -1
## How many requests may be on the wire at the same time. [code]1[/code] sends them strictly
## one after another, which is the safe default for API calls (see PR #130: several threaded
## requests started in the same frame can stall and time out). Raise it for clients that
## download many independent small files like emotes and badges. [code]0[/code] or a negative
## value removes the limit.
@export var max_parallel_requests : int = 1
@export var custom_header : Dictionary[String, String] = { "Accept": "*/*" }
## Seconds until a single attempt of a request is aborted with [constant HTTPRequest.RESULT_TIMEOUT]
@export var request_timeout : float = 30

## Every request that was started and whose response wasn't consumed via `wait_for_request` yet.
var requests : Array[RequestData] = []
## Requests that wait for a free slot, in the order they were requested.
var queued_requests : Array[RequestData] = []
## Requests that are currently on the wire (including retries).
var active_requests : Array[RequestData] = []
var responses : Dictionary = {}

var processing: bool:
	get: return not requests.is_empty()


## Starts a request that will be handled as soon as the client gets free.
## Use HTTPClient.METHOD_* for the method.
func request(path: String, method: int, headers: Dictionary, body: String) -> RequestData:
	logInfo("[%s] start request " % [ path ])
	headers = headers.duplicate()
	headers.merge(custom_header)
	var req = RequestData.new()
	req.path = path
	req.method = method
	req.body = body
	req.headers = headers
	req.client = self
	requests.append(req)
	queued_requests.append(req)
	request_added.emit(req)
	logDebug("[%s] request queued (queued: %s, active: %s)" % [ path, queued_requests.size(), active_requests.size() ])
	_dispatch()
	return req


## When the response is available return it otherwise wait for the response
func wait_for_request(request_data: RequestData) -> ResponseData:
	if responses.has(request_data):
		var response = responses[request_data]
		requests.erase(request_data)
		responses.erase(request_data)
		request_data.queue_free()
		logDebug("response cached return directly from wait")
		return response

	var latest_response : ResponseData = null
	while (latest_response == null || request_data != latest_response.request_data):
		latest_response = await request_done
	logDebug("response received return from wait")
	requests.erase(request_data)
	responses.erase(request_data)
	request_data.queue_free()
	return latest_response


## Sends queued requests as long as there are free slots
func _dispatch() -> void:
	while not queued_requests.is_empty() and _has_free_slot():
		var req: RequestData = queued_requests.pop_front()
		active_requests.append(req)
		_send(req)


func _has_free_slot() -> bool:
	return max_parallel_requests <= 0 or active_requests.size() < max_parallel_requests


## Puts a request on the wire. Used for the first attempt and for every retry.
func _send(request_data: RequestData) -> void:
	if request_data.http_request != null:
		request_data.http_request.queue_free()
	var http_request: HTTPRequest = HTTPRequest.new()
	http_request.use_threads = true
	http_request.timeout = request_timeout
	http_request.request_completed.connect(_on_request_completed.bind(request_data))
	add_child(http_request)
	request_data.http_request = http_request
	request_data.started_at = Time.get_ticks_msec()
	var err : Error = http_request.request(request_data.path, _pack_headers(request_data.headers), request_data.method, request_data.body)
	if err != OK:
		logError("Problems with request to %s cause of %s" % [request_data.path, error_string(err)])
		# HTTPRequest doesn't emit request_completed when request() fails, finish it
		# ourself otherwise the request blocks its slot forever and waiters hang.
		_on_request_completed.call_deferred(HTTPRequest.Result.RESULT_REQUEST_FAILED, 0, PackedStringArray(), PackedByteArray(), request_data)
		return
	logDebug("[%s] request started " % [ request_data.path ])


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request_data: RequestData) -> void:
	var response_data : ResponseData = ResponseData.new()
	if result != HTTPRequest.Result.RESULT_SUCCESS:
		logInfo("[%s] problems with result \n\t> response code: %s \n\t> body: %s" % [request_data.path, response_code, body.get_string_from_utf8()])
		response_data.error = true
	if result == HTTPRequest.Result.RESULT_CONNECTION_ERROR || result == HTTPRequest.Result.RESULT_TLS_HANDSHAKE_ERROR:
		if request_data.retry == max_error_count:
			printerr("Maximum amount of retries for the request. Abort request: %s" % [request_data.path])
			# Fall through and deliver the failed response, so that waiters get an
			# answer and the slot is released for the next queued request.
		else:
			var wait_time = pow(2, request_data.retry)
			wait_time = min(wait_time, 30)
			logDebug("Error happend during connection. Wait for %s" % wait_time)
			await get_tree().create_timer(wait_time, true, false, true).timeout
			request_data.retry += 1
			# The request keeps its slot while retrying
			_send(request_data)
			return

	response_data.result = result
	response_data.request_data = request_data
	response_data.response_data = body
	response_data.response_code = response_code
	response_data.response_header = _get_response_headers_as_dictionary(headers)
	responses[request_data] = response_data
	logInfo("[%s] request done with result HTTPRequest.Result[%s] code %s after %sms (retries: %s)" % [ request_data.path, result, response_code, Time.get_ticks_msec() - request_data.started_at, request_data.retry ])
	active_requests.erase(request_data)
	_dispatch()
	request_done.emit(response_data)


func _get_response_headers_as_dictionary(headers: PackedStringArray) -> Dictionary:
	var header_dict: Dictionary = {}
	if headers == null:
		return header_dict

	for header in headers:
		var header_data = header.split(":", true, 1)
		var key = header_data[0]
		var val = header_data[1]
		if header_dict.has(key):
			header_dict[key] += "; " + val
		else:
			header_dict[key] = val
	return header_dict


func _pack_headers(headers: Dictionary) -> PackedStringArray:
	var result: PackedStringArray = []
	for header_key in headers:
		var header_value = headers[header_key]
		result.append("%s: %s" % [header_key, header_value])
	return result


## The amount of requests that are pending (waiting in the queue or on the wire)
func queued_request_size() -> int:
	return queued_requests.size() + active_requests.size()


func empty_response(request_data: RequestData) -> ResponseData:
	var response_data = ResponseData.new()
	response_data.request_data = request_data
	response_data.response_data = []
	response_data.response_code = 0
	response_data.response_header = {}
	response_data.result = 0
	return response_data


# === LOGGER ===

static var logger: Dictionary = {}
static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug
	logger.info = info
	logger.error = error
	if LambdaLoggerCleanup.has_lambda([error, info, debug]):
		LambdaLoggerCleanup.remove_on_shutdown(BufferedHTTPClient._remove_lambda_loggers)


## Drops lambda loggers; Godot frees them before this static dictionary at shutdown.
static func _remove_lambda_loggers() -> void:
	LambdaLoggerCleanup.remove_lambdas(logger)


static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text)


static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text)


static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text)
