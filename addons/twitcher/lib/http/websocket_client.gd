@tool
extends Node

## Advanced websocket client that automatically reconnects to the server
class_name WebsocketClient

const Constants = preload("res://addons/twitcher/constants.gd")

## Called as soon the websocket got a connection
signal connection_established()

## Called as soon the websocket closed the connection
signal connection_closed()

## Called when a complete message got received
signal message_received(message: PackedByteArray)

## Called when the state of the websocket changed
signal connection_state_changed(state : WebSocketPeer.State)

@export_enum(Constants.AUTO_CONNECT_NOT, \
	Constants.AUTO_CONNECT_RUNTIME, \
	Constants.AUTO_CONNECT_EDITOR_RUNTIME)
var connect_on_enter_tree: String = Constants.AUTO_CONNECT_RUNTIME
@export var connection_url: String:
	set(val):
		logInfo("Set connection to %s" % val)
		connection_url = val


var connection_state : WebSocketPeer.State = WebSocketPeer.STATE_CLOSED:
	set(new_state):
		if new_state != connection_state:
			connection_state_changed.emit(new_state)
			if new_state == WebSocketPeer.STATE_OPEN: connection_established.emit()
			if new_state == WebSocketPeer.STATE_CLOSED: connection_closed.emit()
		connection_state = new_state

## Determines if a connection should be established or not
var _connecting: bool:
	set(val):
		_connecting = val

## True if currently connecting to prevent 2 connectionen processes at the same time
var _is_already_connecting: bool
var is_open: bool:
	get(): return _peer.get_ready_state() == WebSocketPeer.STATE_OPEN
var is_closed: bool:
	get(): return _peer.get_ready_state() == WebSocketPeer.STATE_CLOSED

var _peer: WebSocketPeer = WebSocketPeer.new()
var _tries: int


func _init() -> void:
	_connecting = false


func open_connection() -> void:
	if not is_closed: return
	await _establish_connection()
	_connecting = true


func _establish_connection() -> void:
	if _is_already_connecting || not is_closed: return
	_is_already_connecting = true
	var wait_time = pow(2, _tries)
	logDebug("Wait %s before connecting" % [wait_time])
	await get_tree().create_timer(wait_time).timeout
	logInfo("Connecting to %s" % connection_url)
	var err = _peer.connect_to_url(connection_url)
	if err != OK:
		logError("Coulnd't connect to %s cause of %s" % [connection_url, error_string(err)])
	_tries+=1
	_is_already_connecting = false


func _enter_tree() -> void:
	match connect_on_enter_tree:
		Constants.AUTO_CONNECT_NOT: return
		Constants.AUTO_CONNECT_RUNTIME when OS.has_feature("editor"): return
		_:
			_connecting = true
			open_connection()


func _exit_tree() -> void:
	if not is_open: return
	close(1000, "Gracefully closed")


func _process(delta: float) -> void:
	_poll()

func _poll() -> void:
	if connection_url == "": return

	var state := _peer.get_ready_state()
	if state == WebSocketPeer.STATE_CLOSED and _connecting: _establish_connection()
	_peer.poll()
	_handle_state_changes(state)
	connection_state = state
	if state == WebSocketPeer.STATE_OPEN:
		_read_data()


func _handle_state_changes(state: WebSocketPeer.State) -> void:
	if connection_state != WebSocketPeer.STATE_OPEN && state == WebSocketPeer.STATE_OPEN:
		_on_open_connection()

	if connection_state != WebSocketPeer.STATE_CLOSED && state == WebSocketPeer.STATE_CLOSED:
		_on_close_connection()


func _on_open_connection():
	logInfo("connected to %s" % connection_url)
	_tries = 0


func _on_close_connection():
	logInfo("connection to %s was closed [%s]: %s" % [connection_url, _peer.get_close_code(), _peer.get_close_reason()])


func _read_data() -> void:
	while (_peer.get_available_packet_count()):
		message_received.emit(_peer.get_packet())


func send_text(message: String) -> void:
	_peer.send_text(message)


func close(status: int = 1000, message: String = "Normal Closure") -> void:
	_connecting = false
	_peer.close(status, message)


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
