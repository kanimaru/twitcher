@tool
extends RefCounted

## Provides a simple HTTP Service to serve web stuff
class_name HTTPServer

var _server : TCPServer

class Client extends RefCounted:
	var peer: StreamPeerTCP

## Called when a new request was made
signal request_received(client: Client)

var _clients: Array[Client] = []
var _port: int
var _bind_address: String


func _init(port: int, bind_address: String = "*") -> void:
	_server = TCPServer.new()
	_bind_address = bind_address
	_port = port
	Engine.get_main_loop().process_frame.connect(poll)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and self != null:
		Engine.get_main_loop().process_frame.disconnect(poll)


func poll() -> void:
	if(!_server.is_listening()): return

	if(_server.is_connection_available()):
		_handle_connect()

	for client in _clients:
		_process_request(client)
		_handle_disconnect(client)


func start():
	logInfo("{%s:%s} start" % [ _bind_address, _port ])
	var status = _server.listen(_port, _bind_address)
	if status != OK:
		logError("Could not listen to port %d: %s" % [_port, error_string(status)])


func stop():
	logInfo("{%s:%s} stop" % [ _bind_address, _port ])
	for client in _clients:
		client.peer.disconnect_from_host()
	_server.stop()


func _handle_connect() -> void:
	var peer := _server.take_connection()
	var client := Client.new()
	client.peer = peer
	_clients.append(client)
	logInfo("{%s:%s} client connected" % [ _bind_address, _port ])


func _process_request(client: Client) -> void:
	var peer := client.peer
	if(peer.get_status() == StreamPeerTCP.STATUS_CONNECTED):
		var error = peer.poll()
		if(error != OK):
			logError("{%s:%s} can't poll data: %s" % [ _bind_address, _port, error_string(error)])
		elif (peer.get_available_bytes() > 0):
			request_received.emit(client);


func _handle_disconnect(client: Client) -> void:
	if(client.peer.get_status() != StreamPeerTCP.STATUS_CONNECTED):
		logInfo("{%s:%s} client disconnected" % [ _bind_address, _port ])
		_clients.erase(client)


func send_response(client: Client, response_code : String, body : PackedByteArray) -> void:
	var peer = client.peer
	peer.put_data(("HTTP/1.1 %s\r\n" % response_code).to_utf8_buffer())
	peer.put_data("Server: Godot Engine (Twitcher)\r\n".to_utf8_buffer())
	peer.put_data(("Content-Length: %d\r\n"% body.size()).to_utf8_buffer())
	peer.put_data("Connection: close\r\n".to_utf8_buffer())
	peer.put_data("Content-Type: text/html charset=UTF-8\r\n".to_utf8_buffer())
	peer.put_data("\r\n".to_utf8_buffer())
	peer.put_data(body)


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
