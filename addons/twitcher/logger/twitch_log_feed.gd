@tool
class_name TwitchLogFeed
extends RefCounted
## Collects the records Twitcher logs into a [LogfamiRecordBuffer], for viewers
## like the editor's log dock.
##
## The feed receives what the console prints: a record arrives when the
## [member TwitchLogger.enabled] and [member TwitchLogger.debug] flags of its
## logger allow it (see [TwitchLogContexts]). While the feed is stopped it
## doesn't take part in [method TwitchLoggerManager.wants], so it costs nothing.

var buffer: LogfamiRecordBuffer

var _is_running: bool = false


func _init(max_records: int = 2000) -> void:
	buffer = LogfamiRecordBuffer.new(max_records)


## Subscribes to the logger manager. Starting twice does nothing.
func start() -> void:
	if _is_running:
		return
	_is_running = true
	var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
	TwitchLoggerManager.add_scoped_handler(handle, console.threshold_for)


func stop() -> void:
	if not _is_running:
		return
	_is_running = false
	TwitchLoggerManager.remove_handler(handle)


func is_running() -> bool:
	return _is_running


## Handler entry point, see [method TwitchLoggerManager.add_scoped_handler].
func handle(record: Dictionary) -> void:
	buffer.add(LogfamiRecord.from_dict(record))
