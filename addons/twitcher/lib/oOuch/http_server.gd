extends RefCounted

var server : TCPServer

class Client extends RefCounted:
	var peer: StreamPeerTCP;

signal request_received(client: Client);

var clients: Array[Client] = [];
var listening_port: int;

func _init(port: int) -> void:
	server = TCPServer.new();
	listening_port = port;
	Engine.get_main_loop().process_frame.connect(poll);

func poll() -> void:
	if(!server.is_listening()): return;

	if(server.is_connection_available()):
		_handle_connect();

	for client in clients:
		_process_request(client);

func start():
	logInfo("Start server")
	var status = server.listen(listening_port);
	if status != OK:
		logInfo("Could not listen to port %d: %s" % [listening_port, error_string(status)]);

func stop():
	clients.clear();
	server.stop();
	logInfo("Server stopped")

func _handle_connect() -> void:
	var peer := server.take_connection();
	var client := Client.new();
	client.peer = peer;
	clients.append(client);
	logInfo("%s client connected" % clients.size());

func _process_request(client: Client) -> void:
	var peer := client.peer;
	if(peer.get_status() == StreamPeerTCP.STATUS_CONNECTED):
		var error = peer.poll();
		logDebug("Check if data can be polled")
		if(error != OK):
			logError("Can't poll data: %s" % error_string(error));
		elif (peer.get_available_bytes() > 0):
			logDebug("Data received process");
			request_received.emit(client);
	elif(client.peer.get_status() != StreamPeerTCP.STATUS_CONNECTED):
		logInfo("Client disconnected")
		clients.erase(client);

func send_response(client: Client, response_code : String, body : PackedByteArray) -> void:
	var peer = client.peer;
	peer.put_data(("HTTP/1.1 %s\r\n" % response_code).to_utf8_buffer())
	peer.put_data("Server: Godot Engine\r\n".to_utf8_buffer())
	peer.put_data(("Content-Length: %d\r\n"% body.size()).to_utf8_buffer())
	peer.put_data("Connection: close\r\n".to_utf8_buffer())
	peer.put_data("Content-Type: text/html; charset=UTF-8\r\n".to_utf8_buffer())
	peer.put_data("\r\n".to_utf8_buffer())
	peer.put_data(body)
	logInfo("Client Responded")
	peer.disconnect_from_host();

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
