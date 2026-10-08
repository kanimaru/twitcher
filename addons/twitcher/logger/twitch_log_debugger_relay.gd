@tool
class_name TwitchLogDebuggerRelay
extends RefCounted
## Sends the records of a game started from the editor to the editor's log panel
## and applies the context modes the panel sends back.
##
## It's the game side of the link; the editor side is
## [code]TwitchLogDebuggerPlugin[/code]. Both talk over the editor's debugger
## connection, so nothing is installed in exported games or when the game runs
## without the editor ([method EngineDebugger.is_active] is false then).
##
## Like the console, the relay only receives records of contexts that are
## switched on, see [TwitchLogContexts].

## Prefix of every message of the link.
const CAPTURE: String = "twitcher_log"
## Game to editor: [code][record: Dictionary][/code], see [TwitchLogRecord].
const RECORD_MESSAGE: String = CAPTURE + ":record"
## Editor to game: [code][context: String, mode: String][/code]. The game
## receives it without the prefix, see [constant SET_MODE_COMMAND].
const SET_MODE_MESSAGE: String = CAPTURE + ":set_mode"
const SET_MODE_COMMAND: String = "set_mode"

static var _instance: TwitchLogDebuggerRelay

## [code]func(message: String, data: Array) -> void[/code], defaults to
## [method EngineDebugger.send_message].
var sender: Callable

var _queue: Array[Dictionary] = []
var _mutex: Mutex = Mutex.new()
var _main_thread_id: int = OS.get_thread_caller_id()
var _is_running: bool = false


## Starts the relay of this process when the game runs under the editor. Called
## by [TwitchLoggerManager] on load.
static func install_if_attached() -> void:
	if _instance != null or Engine.is_editor_hint() or not EngineDebugger.is_active():
		return
	_instance = TwitchLogDebuggerRelay.new()
	_instance.start()


func _init() -> void:
	sender = _send_to_editor


## Subscribes to the logger manager and the editor's commands.
func start() -> void:
	if _is_running:
		return
	_is_running = true
	if not EngineDebugger.has_capture(CAPTURE):
		EngineDebugger.register_message_capture(CAPTURE, handle_command)
	var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
	TwitchLoggerManager.add_scoped_handler(relay, console.threshold_for)


func stop() -> void:
	if not _is_running:
		return
	_is_running = false
	TwitchLoggerManager.remove_handler(relay)
	if EngineDebugger.has_capture(CAPTURE):
		EngineDebugger.unregister_message_capture(CAPTURE)


func is_running() -> bool:
	return _is_running


## Handler entry point. Records of other threads wait for the main thread, as the
## debugger connection isn't meant to be used from several threads.
func relay(record: Dictionary) -> void:
	_mutex.lock()
	_queue.append(record.duplicate(true))
	_mutex.unlock()
	if OS.get_thread_caller_id() == _main_thread_id:
		flush()
	else:
		flush.call_deferred()


## Sends the waiting records to the editor.
func flush() -> void:
	_mutex.lock()
	var waiting: Array[Dictionary] = _queue
	_queue = []
	_mutex.unlock()
	for record: Dictionary in waiting:
		sender.call(RECORD_MESSAGE, [record])


## Receives the editor's commands. Returns true for the ones it knows.
func handle_command(command: String, data: Array) -> bool:
	if command != SET_MODE_COMMAND or data.size() < 2:
		return false
	TwitchLogContexts.set_mode(str(data[0]), str(data[1]), false)
	return true


func _send_to_editor(message: String, data: Array) -> void:
	EngineDebugger.send_message(message, data)
