@tool
extends Node

## Provides a simple HTTP Service to serve web stuff
class_name HTTPServer

## Key: int | Value: WeakRef(Server)
static var _servers : Dictionary = {}


class Server extends TCPServer:
	var _bind_address: String
	var _port: int
	var _clients: Array[Client] = []
	var _listeners: int

	signal request_received(client: Client)
	signal client_connected(client: Client)
	signal client_disconnected(client: Client)
	signal client_error_occured(client: Client, error: Error)
	
	
	func _init(bind_address: String, port: int) -> void:
		_bind_address = bind_address
		_port = port
		HTTPServer._servers[_port] = weakref(self)
	
	
	func start_listening() -> void:
		_listeners += 1
		if !is_listening(): 
			var status: Error = listen(_port, _bind_address)
			Engine.get_main_loop().process_frame.connect(_process)
			if status != OK:
				HTTPServer.logError("Could not listen to port %d: %s" % [_port, error_string(status)])
			else:
				HTTPServer.logInfo("{%s:%s} listening" % [ _bind_address, _port ])
		else:
			HTTPServer.logDebug("{%s:%s} already listening" % [ _bind_address, _port ])
	
	
	func stop_listening() -> void:
		_listeners -= 1
		HTTPServer.logDebug("{%s:%s} listener node detached %s left" % [ _bind_address, _port, _listeners ])
		if _listeners <= 0:
			_stop_server()

	
	func _stop_server() -> void:
		HTTPServer.logInfo("{%s:%s} stop" % [ _bind_address, _port ])
		Engine.get_main_loop().process_frame.disconnect(_process)
		for client in _clients:
			client.peer.disconnect_from_host()
		stop()
		
		
	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			HTTPServer.logInfo("{%s:%s} removed" % [ _bind_address, _port ])
			HTTPServer._servers.erase(_port)


	func _process() -> void:
		if !is_listening(): return

		if is_connection_available():
			_handle_connect()

		for client in _clients:
			_process_request(client)
			_handle_disconnect(client)
	
	
	func _process_request(client: Client) -> void:
		var peer := client.peer
		if peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			var error = peer.poll()
			if error != OK:
				HTTPServer.logError("Could not poll client %d: %s" % [_port, error_string(error)])
				client_error_occured.emit(client, error)
			elif peer.get_available_bytes() > 0:
				request_received.emit(client)
	
	
	func _handle_connect() -> void:
		var peer := take_connection()
		var client := Client.new()
		client.peer = peer
		_clients.append(client)
		client_connected.emit(client)
		HTTPServer.logInfo("{%s:%s} client connected" % [ _bind_address, _port ])
		
		
	func _handle_disconnect(client: Client) -> void:
		if client.peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			client_disconnected.emit(client)
			HTTPServer.logInfo("{%s:%s} client disconnected" % [ _bind_address, _port ])
			_clients.erase(client)
	
	
class Client extends RefCounted:
	var peer: StreamPeerTCP


## Called when a new request was made
signal request_received(client: Client)


@export var _port: int
@export var _bind_address: String

var _server : Server
var _listening: bool


static func create(port: int, bind_address: String = "*") -> HTTPServer:
	var server = HTTPServer.new()
	server._bind_address = bind_address
	server._port = port
	return server


func _ready() -> void:
	if _servers.has(_port) && _servers[_port] != null:
		_server = _servers[_port].get_ref()
	else:
		_server = Server.new(_bind_address, _port)
	_server.request_received.connect(_on_request_received)
	logInfo("{%s:%s} start" % [ _bind_address, _port ])


func _on_request_received(client: Client) -> void:
	request_received.emit(client)
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		stop_listening()


func start_listening() -> void:
	_listening = true
	_server.start_listening()
	
	
func stop_listening() -> void:
	if _listening:
		_listening = false
		_server.stop_listening()


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
