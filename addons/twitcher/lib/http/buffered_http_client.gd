@tool
extends RefCounted

## Http client that bufferes the requests and sends them sequentialy
class_name BufferedHTTPClient

## Takes track of the amount of http clients
static var index = 0

## After this amount of request in the buffer the client isn't free anymore.
const FREE_THRESHOLD = 2

## Will be send when a new request was added to queue
signal request_added(request: RequestData)

## Request is now started and handled.
signal request_started(request: RequestData)

## Will be send when a request is done.
signal request_done(response: ResponseData)

## Will return information if the client has connected or got disconnected
signal connection_status_changed(connected: bool)


## Contains the request data to be send
class RequestData extends RefCounted:
	var client: BufferedHTTPClient
	var path: String
	var method: int
	var headers: Dictionary
	var body: String = ""


## Contains the response data
class ResponseData extends RefCounted:
	var client: HTTPClient
	var response_code: int
	var request_data: RequestData
	var response_data: PackedByteArray
	var response_header: Dictionary
	var error: bool

enum State {
	WAITING_FOR_REQUEST,
	CONNECTING,
	PROCESSING_REQUEST
}



@export var base_url: String
@export var _port: int = -1

var client: HTTPClient = HTTPClient.new()
var requests : Array[RequestData] = []
var current_request : RequestData
var current_response_data : PackedByteArray = PackedByteArray()
var connected : bool:
	set(val):
		connected = val
		connection_status_changed.emit(val)
		logInfo("connected" if val else "disconnected")

var custom_header : Dictionary = { "Accept": "*/*" }
var responses : Dictionary = {}
var error_count : int
## When a request fails max_error_count then cancel that request -1 for endless amount of tries.
var max_error_count : int = -1
## Only one poll at a time so block for all other tries to call it
var polling: bool
var processing: bool:
	get: return not requests.is_empty() || current_request != null
var state: State = State.WAITING_FOR_REQUEST


func _init(baseurl: String, port: int = -1) -> void:
	index += 1
	logger_format = ("{ %s-%s } " % [str(index), baseurl]) + "%s"
	base_url = baseurl
	_port = port
	Engine.get_main_loop().process_frame.connect(_poll)
	connection_status_changed.emit(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and self != null:
		Engine.get_main_loop().process_frame.disconnect(_poll)


func _connect_to_host() -> void:
	logInfo("connecting")
	var err = client.connect_to_host(base_url, _port)
	if err != OK:
		logError("[%s] can't connect cause of %s" % [base_url, error_string(err)])
	state = State.CONNECTING


func _disconnect() -> void:
	logInfo("disconnecting")
	client.close()
	connected = false


## Removes the complete http client. Don't use it after calling this method!
func shutdown() -> void:
	_disconnect()
	free()


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
	request_added.emit(req)

	return req


func _poll() -> void:
	if polling: return
	polling = true

	# Is a request available
	if current_request == null && not requests.is_empty():
		current_request = requests.pop_front()
		logInfo("[%s] start request processing" % [ current_request.path ])

		# Start connection
		_connect_to_host()

	match state:
		# Await connection
		State.CONNECTING:
			_poll_connecting()
			if connected:
				var headers = custom_header if current_request.headers == null else current_request.headers
				var packed_headers = _pack_headers(headers)
				# do request
				client.request(current_request.method, current_request.path, packed_headers, current_request.body)
				request_started.emit(current_request)
				state = State.PROCESSING_REQUEST

		State.PROCESSING_REQUEST:
			_process_request()

	# close connection


	polling = false


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


func _poll_connecting() -> void:
	match client.get_status():
		HTTPClient.STATUS_DISCONNECTED:
			_connect_to_host()

		HTTPClient.STATUS_CANT_CONNECT:
			client.close()
			_connect_to_host()

		HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_RESOLVING:
			client.poll()

		HTTPClient.STATUS_CONNECTED:
			connected = true


func _process_request() -> void:
	match client.get_status():
		HTTPClient.STATUS_REQUESTING:
			logDebug("[%s] requesting" % current_request.path)
			client.poll()

		HTTPClient.STATUS_BODY:
			logDebug("[%s] data received" % current_request.path)
			_handle_response()
			error_count = 0

		HTTPClient.STATUS_CONNECTED, HTTPClient.STATUS_DISCONNECTED:
			if current_request != null:
				logInfo("[%s] Response received" % current_request.path)
				var response_data = _create_response();
				_check_status(response_data);
				responses[current_request] = response_data;
				request_done.emit(response_data);
				_reset_request();
				_disconnect()

		HTTPClient.STATUS_CONNECTION_ERROR:
			logDebug("[%s] error" % current_request.path)
			_disconnect()
			logInfo("[%s] retry cause of disconnect" % current_request.path)
			requests.append(current_request)
			_reset_request()
			_connect_to_host()

		_:
			logInfo("[%s] unexpected state reached" % current_request.path)
			await _handle_error()


func _handle_error():
	await _wait_error_duration()
	logError("Error happened (client status: %s)" % client.get_status())
	error_count += 1
	if error_count >= max_error_count && max_error_count != -1:
		# Giveup
		var response_data = _create_response()
		response_data.error = true
		request_done.emit(response_data)
		logError("[%s] abort request max retries reached. (client status: %s)" % [current_request.path, client.get_status()])
	logError("problem with request client status: %s response code: %s cause of %s" % [client.get_status(), client.get_response_code(), current_response_data.get_string_from_utf8()])


func _reset_request():
	current_request = null
	current_response_data.clear()


func _check_status(response_data: ResponseData) -> void:
	var response_code = client.get_response_code()
	if !str(response_code).begins_with("2"):
		logInfo("[%s] problems with result \n\t> response code: %s \n\t> body: %s" % [response_data.request_data.path, response_code, response_data.response_data.get_string_from_utf8()])
		var response_headers = client.get_response_headers_as_dictionary()
		print_verbose(response_headers)


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


func _wait_error_duration():
	var duration = pow(2, error_count)
	duration = min(duration, 30)
	logInfo("wait for %s in seconds" % duration)
	await Engine.get_main_loop().create_timer(duration).timeout


func _handle_response() -> void:
	if client.has_response():
		client.poll()
		if client.get_status() != HTTPClient.STATUS_BODY:
			logDebug("[%s] status is %s but want to read body" % [ current_request.path, client.get_status() ])
		var chunk = client.read_response_body_chunk()
		if chunk.size() > 0:
			current_response_data += chunk
	else:
		logError("no response? shouldn't happen.")


func _create_response() -> ResponseData:
	var response_data = ResponseData.new()
	response_data.client = client
	response_data.request_data = current_request
	response_data.response_data = current_response_data.duplicate()
	response_data.response_code = client.get_response_code()
	response_data.response_header = client.get_response_headers_as_dictionary()
	return response_data


func empty_response(request_data: RequestData) -> ResponseData:
	var response_data = ResponseData.new()
	response_data.client = client
	response_data.request_data = request_data
	response_data.response_data = []
	response_data.response_code = 0
	response_data.response_header = {}
	return response_data


## Checks if the client can accept more requests
func is_free() -> bool:
	return requests.size() < FREE_THRESHOLD

# === LOGGER ===

static var logger: Dictionary = {}
static var logger_format: String
static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug
	logger.info = info
	logger.error = error

static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(logger_format % text)

static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(logger_format % text)

static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(logger_format % text)
