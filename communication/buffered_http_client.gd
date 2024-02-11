@tool
extends RefCounted

## Http client that bufferes the requests and sends them sequentialy
class_name BufferedHTTPClient

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_HTTP_CLIENT)

## Will be send when a request is done.
signal request_done(response: ResponseData)

## After this amount of request in the buffer the client isn't free anymore.
const FREE_THRESHOLD = 2;

const HEADERS: Dictionary = {
	"User-Agent": "Twitcher/1.0 (Godot)",
	"Accept": "*/*"
};

@export var base_url: String;
@export var port: int = -1;

## Contains the request data to be send
class RequestData extends RefCounted:
	var client: BufferedHTTPClient;
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
	var error: bool;

var client: HTTPClient = HTTPClient.new();
var requests : Array[RequestData] = [];
var current_request : RequestData;
var current_response_data : PackedByteArray = PackedByteArray();
var connected : bool;
var responses : Dictionary = {};
var error_count : int;
## When a request fails max_error_count then cancel that request -1 for endless amount of tries.
var max_error_count : int = -1;

func _init(url: String, p: int = -1) -> void:
	base_url = url;
	port = p;
	var main_loop = Engine.get_main_loop();
	Engine.get_main_loop().process_frame.connect(_poll);

func _connect() -> void:
	log.i("connecting to %s" % base_url);
	var err = client.connect_to_host(base_url, port);
	if err != OK:
		log.e("Can't connect to %s cause of %s" % [base_url, error_string(err)]);
		return;

	# Wait until its conneceted
	while(client.get_status() == HTTPClient.STATUS_CONNECTING || client.get_status() == HTTPClient.STATUS_RESOLVING):
		client.poll();

	if client.get_status() != HTTPClient.STATUS_CONNECTED:
		error_count += 1;
		log.e("can't connect to %s" % [base_url])

	#print("Current State: %s" % client.get_status())
	assert(client.get_status() == HTTPClient.STATUS_CONNECTED)

	connected = true;

## Removes the complete http client. Don't use it after calling this method!
func shutdown() -> void:
	client.close();
	Engine.get_main_loop().process_frame.disconnect(_poll);

## Starts a request that will be handled as soon as the client gets free.
## Use HTTPClient.METHOD_* for the method.
func request(path: String, method: int, headers: Dictionary, body: String) -> RequestData:
	log.i("Start Request(%s) %s" % [ method, path ]);
	headers = headers.duplicate();
	headers.merge(HEADERS);
	var req = RequestData.new();
	req.path = path;
	req.method = method;
	req.body = body;
	req.headers = headers;
	req.client = self;
	requests.append(req);
	return req;

## When the response is available return it otherwise wait for the response
func wait_for_request(request_data: RequestData) -> ResponseData:
	if responses.has(request_data):
		var response = responses[request_data];
		responses.erase(request_data);
		return response;

	var latest_response : ResponseData = null;
	while (latest_response == null || request_data != latest_response.request_data):
		latest_response = await(request_done);
	responses.erase(request_data);
	return latest_response;

## Checks if the client can accept more requests
func is_free() -> bool:
	return requests.size() < FREE_THRESHOLD;

func _wait_error_duration():
	var duration = pow(2, error_count);
	duration = min(duration, 30);
	await Engine.get_main_loop().create_timer(duration).timeout

func _create_response() -> ResponseData:
	var response_data = ResponseData.new()
	response_data.client = client;
	response_data.request_data = current_request;
	response_data.response_data = current_response_data.duplicate();
	response_data.response_code = client.get_response_code();
	return response_data;

func empty_response(request_data: RequestData) -> ResponseData:
	var response_data = ResponseData.new()
	response_data.client = client;
	response_data.request_data = request_data;
	response_data.response_data = [];
	response_data.response_code = 0;
	return response_data;


func _poll() -> void:
	if(!connected):
		_connect();

	if(!requests.is_empty() && current_request == null):
		_start_request();

	if(client.get_status() == HTTPClient.STATUS_REQUESTING):
		client.poll();

	elif(client.get_status() == HTTPClient.STATUS_BODY):
		_handle_response();
		error_count = 0;

	elif(client.get_status() == HTTPClient.STATUS_CONNECTED):
		if current_request != null:
			var response_data = _create_response();
			_check_status(response_data);
			responses[current_request] = response_data;
			request_done.emit(response_data);
			_reset_request();

	elif(client.get_status() == HTTPClient.STATUS_DISCONNECTED):
		connected = false;
		requests.append(current_request);

	else: _handle_error();

func _handle_error():
	await _wait_error_duration();
	log.e("Error happend current client status: %s" % client.get_status())
	error_count += 1;
	connected = false;
	if error_count <= max_error_count || max_error_count == -1:
		# Retry
		requests.append(current_request);
		_reset_request();
	else:
		# Giveup
		var response_data = _create_response();
		response_data.error = true;
		request_done.emit(response_data);
		log.e("Abort request %s max retries reached. (%s)" % [current_request.path, client.get_status()])
	log.e("Problem with client status: %s/%s cause of %s" % [client.get_status(), client.get_response_code(), current_response_data.get_string_from_utf8()])

func _reset_request():
	current_request = null;
	current_response_data.clear();

func _check_status(response_data: ResponseData) -> void:
	var response_code = client.get_response_code();
	if !str(response_code).begins_with("2"):
		log.i("Problems with %s result %s body: \n%s" % [response_data.request_data.path, response_code, response_data.response_data.get_string_from_utf8()])

func _start_request() -> void:
	current_request = requests.pop_front() as RequestData;
	var headers = HEADERS if current_request.headers == null else current_request.headers;
	var packed_headers = _pack_headers(headers);
	client.request(current_request.method, current_request.path, packed_headers, current_request.body);
	log.i("Start request processing %s" % current_request.path)

func _pack_headers(headers: Dictionary) -> PackedStringArray:
	var result: PackedStringArray = [];
	for header_key in headers:
		var header_value = headers[header_key];
		result.append("%s: %s" % [header_key, header_value]);
	return result;

func _handle_response() -> void:
	if client.has_response():
		client.poll();
		var chunk = client.read_response_body_chunk();
		if chunk.size() > 0:
			current_response_data += chunk;
	else:
		log.e("No Response? Shouldn't happen.");

