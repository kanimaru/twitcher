@tool
extends Node

## Advanced websocket client that automatically reconnects to the server
class_name WebsocketClient


## Called as soon the websocket got a connection
signal connection_established

## Called as soon the websocket closed the connection
signal connection_closed

## Called when a complete message got received
signal message_received(message: PackedByteArray)

## Called when the state of the websocket changed
signal connection_state_changed(state : WebSocketPeer.State)

## Failed connection attempts after which the delay stops growing.
const _MAX_TRIES: int = 16

@export var connection_url: String:
	set(val):
		_logDebug("Set connection to %s" % val)
		connection_url = val

var connection_state : WebSocketPeer.State = WebSocketPeer.STATE_CLOSED:
	set(new_state):
		if new_state != connection_state:
			connection_state_changed.emit(new_state)
			if new_state == WebSocketPeer.STATE_OPEN: connection_established.emit()
			if new_state == WebSocketPeer.STATE_CLOSED: connection_closed.emit()
		connection_state = new_state

## Determines if a connection should be established or not
@export var auto_reconnect: bool:
	set(val):
		auto_reconnect = val
		# Turned off on purpose, so a node that is out of the tree must not resume either.
		if not val:
			_resume_on_enter = false
		_logDebug("New auto_reconnect value: %s" % val)

## Seconds to wait before the first connection attempt. Doubles with every failed attempt.
@export var reconnect_base_delay: float = 1.0
## Upper bound of the wait between two connection attempts, so a long outage doesn't push the
## next attempt hours into the future.
@export var max_reconnect_delay: float = 60.0

## True if currently connecting to prevent 2 connectionen processes at the same time
var _is_already_connecting: bool
var is_open: bool:
	get(): return _peer.get_ready_state() == WebSocketPeer.STATE_OPEN
var is_closed: bool:
	get(): return _peer.get_ready_state() == WebSocketPeer.STATE_CLOSED

var _peer: WebSocketPeer = WebSocketPeer.new()
var _tries: int
## Bumped on every close, abort and tree exit. A connection attempt that started waiting in an
## older generation gives up instead of reopening a client that got closed in the meantime.
var _generation: int
## The pending wait of [method _establish_connection], kept so it can be cut short.
var _connection_wait: SceneTreeTimer
## Remembers across a tree exit that the client was supposed to be connected.
var _resume_on_enter: bool


func open_connection() -> void:
	if not is_closed: return
	auto_reconnect = true
	# Without a tree there is no timer to wait with, _enter_tree connects as soon as it's added.
	if not is_inside_tree():
		return
	_logInfo("Open connection")
	await _establish_connection()


func wait_connection_established() -> void:
	if is_open: return
	await connection_established

## Seconds to wait before the connection attempt after [param tries] failed ones.
func get_reconnect_delay(tries: int) -> float:
	return minf(reconnect_base_delay * pow(2.0, tries), max_reconnect_delay)


func _establish_connection() -> void:
	if _is_already_connecting || not is_closed: return
	_is_already_connecting = true
	var generation: int = _generation
	var wait_time: float = get_reconnect_delay(_tries)
	_logDebug("Wait %s before connecting" % [wait_time])
	var wait: SceneTreeTimer = get_tree().create_timer(wait_time, true, false, true)
	_connection_wait = wait
	await wait.timeout
	if _connection_wait == wait:
		_connection_wait = null
	_is_already_connecting = false
	if generation != _generation or not auto_reconnect or not is_inside_tree():
		_logDebug("Connection attempt got cancelled")
		return
	_logInfo("Connecting to %s" % connection_url)
	var err = _peer.connect_to_url(connection_url)
	if err != OK:
		logError("Couldn't connect cause of %s" % [error_string(err)])
	_tries = mini(_tries + 1, _MAX_TRIES)


func _enter_tree() -> void:
	# A paused client doesn't answer pings and the server drops it, so it keeps running while the
	# game is paused. Only INHERIT is replaced, a mode chosen on purpose stays; that can't happen
	# in _init, a scene sets its saved mode before the script exists.
	if process_mode == Node.PROCESS_MODE_INHERIT:
		process_mode = Node.PROCESS_MODE_ALWAYS
	if _resume_on_enter:
		_resume_on_enter = false
		auto_reconnect = true
	if auto_reconnect: open_connection()


func _exit_tree() -> void:
	var resume: bool = auto_reconnect
	_stop_connecting()
	# A node outside the tree isn't polled, so a close handshake would never finish and the
	# socket would hang in CLOSING. Drop it and reconnect when the node comes back.
	_peer.close(-1)
	_resume_on_enter = resume


func _process(delta: float) -> void:
	_poll()


func _poll() -> void:
	if connection_url == "": return

	var state := _peer.get_ready_state()
	if state == WebSocketPeer.STATE_CLOSED and auto_reconnect:
		_establish_connection()
	_peer.poll()
	_handle_state_changes(state)
	connection_state = state
	if state == WebSocketPeer.STATE_OPEN:
		_read_data()


func _handle_state_changes(state: WebSocketPeer.State) -> void:
	if connection_state != WebSocketPeer.STATE_OPEN && state == WebSocketPeer.STATE_OPEN:
		_logInfo("connected")
		_tries = 0

	if connection_state != WebSocketPeer.STATE_CLOSED && state == WebSocketPeer.STATE_CLOSED:
		_logInfo("connection was closed [%s]: %s" % [_peer.get_close_code(), _peer.get_close_reason()])


func _read_data() -> void:
	while (_peer.get_available_packet_count()):
		message_received.emit(_peer.get_packet())


func send_text(message: String) -> Error:
	return _peer.send_text(message)


func close(status: int = 1000, message: String = "Normal Closure") -> void:
	_logDebug("Websocket activly closed")
	_stop_connecting()
	_peer.close(status, message)


## Drops the connection at once without a close handshake. Meant for a peer that stopped
## answering, where [method close] would wait for a reply that never comes. Like
## [method close] it turns [member auto_reconnect] off.
func abort() -> void:
	_logDebug("Websocket aborted")
	_stop_connecting()
	_peer.close(-1)


## Stops the pending and every future connection attempt until the connection gets opened again.
func _stop_connecting() -> void:
	_generation += 1
	auto_reconnect = false
	_cancel_connection_wait()


## Resumes a pending connection attempt right away so it can see that it got cancelled. Waiting
## for the timer instead would resume the attempt on a node that might be freed by then.
func _cancel_connection_wait() -> void:
	if _connection_wait == null:
		return
	var wait: SceneTreeTimer = _connection_wait
	_connection_wait = null
	wait.timeout.emit()


# === LOGGER ===
static var logger: Dictionary = {}
static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug
	logger.info = info
	logger.error = error
	if LambdaLoggerCleanup.has_lambda([error, info, debug]):
		LambdaLoggerCleanup.remove_on_shutdown(WebsocketClient._remove_lambda_loggers)


## Drops lambda loggers; Godot frees them before this static dictionary at shutdown.
static func _remove_lambda_loggers() -> void:
	LambdaLoggerCleanup.remove_lambdas(logger)


func _logDebug(text: String) -> void:
	logDebug("[%s]: %s" % [connection_url, text])


static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text)


func _logInfo(text: String) -> void:
	logInfo("[%s]: %s" % [connection_url, text])


static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text)


static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text)
