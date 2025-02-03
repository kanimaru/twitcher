@tool
extends Node

## Http client that bufferes the requests and sends them sequentialy
class_name BufferedHTTPClient


## Will be send when a new request was added to queue
signal request_added(request: RequestData)

## Will be send when a request is done.
signal request_done(response: ResponseData)


## Contains the request data to be send
class RequestData extends RefCounted:
	## The client that the request belongs too
	var client: BufferedHTTPClient
	## The request node that is executing the request
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

var requests : Array[RequestData] = []
var current_request : RequestData
var current_response_data : PackedByteArray = PackedByteArray()

var custom_header : Dictionary = { "Accept": "*/*" }
var responses : Dictionary = {}
var error_count : int
## When a request fails max_error_count then cancel that request -1 for endless amount of tries.
var max_error_count : int = -1
## Only one poll at a time so block for all other tries to call it
var polling: bool
var processing: bool:
	get: return not requests.is_empty() || current_request != null


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
	req.http_request = HTTPRequest.new()
	req.http_request.use_threads = true
	req.http_request.timeout = 30
	req.http_request.request_completed.connect(_on_request_completed.bind(req))
	add_child(req.http_request)
	var err : Error = req.http_request.request(req.path, _pack_headers(req.headers), req.method, req.body)
	if err != OK: logError("Problems with request to %s cause of %s" % [path, error_string(err)])
	requests.append(req)
	request_added.emit(req)
	logDebug("[%s] request started " % [ path ])
	return req


## When the response is available return it otherwise wait for the response
func wait_for_request(request_data: RequestData) -> ResponseData:
	if responses.has(request_data):
		var response = responses[request_data]
		responses.erase(request_data)
		logDebug("response cached return directly from wait")
		return response

	var latest_response : ResponseData = null
	while (latest_response == null || request_data != latest_response.request_data):
		latest_response = await request_done
	logDebug("response received return from wait")
	responses.erase(request_data)
	return latest_response


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request_data: RequestData) -> void:
	var response_data : ResponseData = ResponseData.new()
	if result != HTTPRequest.Result.RESULT_SUCCESS:
		logInfo("[%s] problems with result \n\t> response code: %s \n\t> body: %s" % [request_data.path, response_code, body.get_string_from_utf8()])
		response_data.error = true

	if result == HTTPRequest.Result.RESULT_CONNECTION_ERROR:
		if request_data.retry == max_error_count:
			printerr("Maximum amount of retries for the request. Abort request: %s" % [request_data.path])
			return
		var wait_time = pow(2, request_data.retry)
		wait_time = min(wait_time, 30)
		logDebug("Wait for %s" % wait_time)
		await get_tree().create_timer(wait_time).timeout
		var http_request: HTTPRequest = request_data.http_request.duplicate()
		add_child(http_request)
		request_data.http_request = http_request
		request_data.retry += 1
		http_request.request(request_data.url, _pack_headers(request_data.headers), request_data.method, request_data.body)
		http_request.request_completed.connect(_on_request_completed.bind(http_request))

	response_data.result = result
	response_data.request_data = request_data
	response_data.response_data = body
	response_data.response_code = response_code
	response_data.response_header = _get_response_headers_as_dictionary(headers)
	responses[request_data] = response_data
	logInfo("[%s] request done with result %s " % [ request_data.path, result ])
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


## The amount of requests that are pending
func queued_request_size() -> int:
	var requests_size = requests.size()
	if current_request != null:
		requests_size += 1
	return requests_size


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

static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text)

static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text)

static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text)
