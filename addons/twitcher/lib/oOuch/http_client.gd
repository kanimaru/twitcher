extends RefCounted

## After this amount of request in the buffer the client isn't free anymore.
const FREE_THRESHOLD = 2;
const HEADERS: Dictionary = {
	"User-Agent": "OAuth/1.0 (Godot)",
	"Accept": "*/*"
};

## Will be send when a new request was added to queue
signal request_added(request: RequestData)

## Request is now started and handled.
signal request_started(request: RequestData);

## Will be send when a request is done.
signal request_done(response: ResponseData)

## Will return information if the client has connected or got disconnected
signal connection_status_changed(connected: bool);

var base_url: String:
	set(value):
		base_url = value;
		if value != "": connect_to_host();
var port: int = -1;

## Contains the request data to be send
class RequestData extends RefCounted:
	var client: HTTPClient;
	var path: String;
	var method: int;
	var headers: Dictionary;
	var body: String = "";

## Contains the response data
class ResponseData extends RefCounted:
	var client: HTTPClient;
	var response_code: int;
	var request_data: RequestData;
	var response_data: PackedByteArray;
	var response_header: Dictionary;
	var error: bool;

var client: HTTPClient = HTTPClient.new();
var requests : Array[RequestData] = [];
var current_request : RequestData;
var current_response_data : PackedByteArray = PackedByteArray();
var connected : bool:
	set(val):
		connected = val;
		connection_status_changed.emit(val);
		logDebug("Connection state changed: %s" % val)

var responses : Dictionary = {};
var error_count : int;
## When a request fails max_error_count then cancel that request -1 for endless amount of tries.
var max_error_count : int = -1;
## Only one poll at a time so block for all other tries to call it
var polling: bool;

func _init(url: String, p: int = -1) -> void:
	base_url = url;
	port = p;
	Engine.get_main_loop().process_frame.connect(_poll);
	connection_status_changed.emit(false);

func connect_to_host() -> void:
	logInfo("Connecting to %s" % base_url);
	var err = client.connect_to_host(base_url, port);
	if err != OK:
		logError("Can't connect to %s cause of %s" % [base_url, error_string(err)]);

## Starts a request that will be handled as soon as the client gets free.
## Use HTTPClient.METHOD_* for the method.
func request(path: String, method: int, headers: Dictionary, body: String) -> RequestData:
	logInfo("Start Request(%s) %s" % [ method, path ]);
	headers = headers.duplicate();
	headers.merge(HEADERS);
	var req = RequestData.new();
	req.path = path;
	req.method = method;
	req.body = body;
	req.headers = headers;
	req.client = self;
	requests.append(req);
	request_added.emit(req);
	return req;

## When the response is available return it otherwise wait for the response
func wait_for_request(request_data: RequestData) -> ResponseData:
	if responses.has(request_data):
		var response = responses[request_data];
		responses.erase(request_data);
		logDebug("Response was already cached. Return directly from wait");
		return response;

	var latest_response : ResponseData = null;
	while (latest_response == null || request_data != latest_response.request_data):
		latest_response = await(request_done); # TODO Still nessecerry ?
	logDebug("Response received. Return from wait");
	responses.erase(request_data);
	return latest_response;

## Checks if the client can accept more requests
func is_free() -> bool:
	return requests.size() < FREE_THRESHOLD;

## The amount of requests that are pending
func queued_request_size() -> int:
	var requests_size = requests.size();
	if current_request != null:
		requests_size += 1;
	return requests_size;

func _wait_error_duration():
	var duration = pow(2, error_count);
	duration = min(duration, 30);
	logInfo("Wait for %s in seconds" % duration);
	await Engine.get_main_loop().create_timer(duration).timeout

func _create_response() -> ResponseData:
	var response_data = ResponseData.new()
	response_data.client = client;
	response_data.request_data = current_request;
	response_data.response_data = current_response_data.duplicate();
	response_data.response_code = client.get_response_code();
	response_data.response_header = client.get_response_headers_as_dictionary();
	return response_data;

func empty_response(request_data: RequestData) -> ResponseData:
	var response_data = ResponseData.new()
	response_data.client = client;
	response_data.request_data = request_data;
	response_data.response_data = [];
	response_data.response_code = 0;
	return response_data;

func _connecting():
	logDebug("Connecting")
	if(client.get_status() == HTTPClient.STATUS_CANT_CONNECT):
		client.close();
		connect_to_host();
	elif(client.get_status() == HTTPClient.STATUS_CONNECTING ||
		client.get_status() == HTTPClient.STATUS_RESOLVING):
		client.poll();

	if(client.get_status() == HTTPClient.STATUS_CONNECTED):
		connected = true;

func _poll() -> void:
	if(not connected):
		_connecting();
		if not connected: return;

	if polling: return;
	polling = true;

	if(!requests.is_empty() && current_request == null):
		_start_request();

	if(client.get_status() == HTTPClient.STATUS_REQUESTING):
		logDebug("[%s] Requesting" % current_request.path)
		client.poll();

	elif(client.get_status() == HTTPClient.STATUS_BODY):
		logDebug("[%s] Data received" % current_request.path)
		_handle_response();
		error_count = 0;

	elif(client.get_status() == HTTPClient.STATUS_CONNECTED):
		if current_request != null:
			logDebug("[%s] Response received" % current_request.path)
			var response_data = _create_response();
			_check_status(response_data);
			responses[current_request] = response_data;
			request_done.emit(response_data);
			_reset_request();

	elif(client.get_status() == HTTPClient.STATUS_DISCONNECTED ||
		client.get_status() == HTTPClient.STATUS_CONNECTION_ERROR):
		logDebug("[%s] disconnected / error" % current_request.path)
		client.close();
		connected = false;
		logInfo("Retry cause of disconnect %s" % current_request.path)
		requests.append(current_request);
		_reset_request();
		connect_to_host();

	else:
		await _handle_error();

	polling = false;

func _handle_error():
	await _wait_error_duration();
	logError("Error happened (client status: %s)" % client.get_status())
	error_count += 1;
	if error_count >= max_error_count && max_error_count != -1:
		# Giveup
		var response_data = _create_response();
		response_data.error = true;
		request_done.emit(response_data);
		logError("Abort request %s max retries reached. (%s)" % [current_request.path, client.get_status()])
	logError("Problem with client status: %s/%s cause of %s" % [client.get_status(), client.get_response_code(), current_response_data.get_string_from_utf8()])

func _reset_request():
	current_request = null;
	current_response_data.clear();

func _check_status(response_data: ResponseData) -> void:
	var response_code = client.get_response_code();
	if !str(response_code).begins_with("2"):
		logInfo("Problems with %s result %s body: \n%s" % [response_data.request_data.path, response_code, response_data.response_data.get_string_from_utf8()])
		var response_headers = client.get_response_headers_as_dictionary();
		print_verbose(response_headers);

func _start_request() -> void:
	current_request = requests.pop_front() as RequestData;
	logInfo("Start request processing [%s] %s" % [current_request.method, current_request.path])
	var headers = HEADERS if current_request.headers == null else current_request.headers;
	var packed_headers = _pack_headers(headers);
	client.request(current_request.method, current_request.path, packed_headers, current_request.body);
	request_started.emit(current_request);

func _pack_headers(headers: Dictionary) -> PackedStringArray:
	var result: PackedStringArray = [];
	for header_key in headers:
		var header_value = headers[header_key];
		result.append("%s: %s" % [header_key, header_value]);
	return result;

func _handle_response() -> void:
	if client.has_response():
		client.poll();
		if client.get_status() != HTTPClient.STATUS_BODY:
			print_debug("Status is %s but want to read body %s" % [client.get_status(), current_request.path])
			return;
		var chunk = client.read_response_body_chunk();
		if chunk.size() > 0:
			current_response_data += chunk;
	else:
		logError("No Response? Shouldn't happen.");


# === LOGGER ===
static var logger: Dictionary = {};
static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug;
	logger.info = info;
	logger.error = error;

static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text);

static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text);

static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text);
