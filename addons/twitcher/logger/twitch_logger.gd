@tool
class_name TwitchLogger
extends RefCounted
## Named logger for one Twitcher component. (Works best with tool scripts)
##
## Every message becomes a record (see [TwitchLogRecord]) that
## [TwitchLoggerManager] hands to the registered handlers. The console is one of
## those handlers; whether it prints this logger's messages is configured under
## [code]twitcher/logs/<Context>[/code]. Other handlers, like the log file,
## filter on their own, so a message can reach them while the console is off.
## [codeblock]
## static var _log: TwitchLogger = TwitchLogger.new("MyNode")
##
## _log.i("Connected")
## _log.w("Retrying", { "attempt": 3 })
## [/codeblock]

## Name of the logger that will be shown in the logs
var context_name: String
## Shown after the context name in the console, e.g. [code]"-main"[/code].
## Set it via [method set_suffix].
var suffix: String
## Instance name set via [method set_suffix]; sent as the
## [code]instance[/code] attribute of every record.
var instance: String
## Whether the console prints info, warn and error messages of this logger.
var enabled: bool
## Whether the console also prints debug messages of this logger.
var debug: bool


func _init(ctx_name: String, active: bool = false, should_debug: bool = false) -> void:
	context_name = ctx_name
	enabled = active
	debug = should_debug
	TwitchLoggerManager.register(self)


func is_enabled() -> bool:
	return enabled


func set_enabled(status: bool) -> void:
	enabled = status


func set_suffix(s: String) -> void:
	instance = s
	suffix = "-" + s


## True when any handler wants [param level] messages of this logger. Use it to
## skip building expensive messages nobody receives.
func wants(level: int) -> bool:
	return TwitchLoggerManager.wants(context_name, level, self)


## Logs a message on info level.
func i(text: String, attributes: Dictionary = {}) -> void:
	_emit(LogfamiLevel.Severity.INFO, text, attributes)


## Logs a message on warn level.
func w(text: String, attributes: Dictionary = {}) -> void:
	_emit(LogfamiLevel.Severity.WARN, text, attributes)


## Logs a message on error level.
func e(text: String, attributes: Dictionary = {}) -> void:
	_emit(LogfamiLevel.Severity.ERROR, text, attributes)


## Logs a message on debug level.
func d(text: String, attributes: Dictionary = {}) -> void:
	_emit(LogfamiLevel.Severity.DEBUG, text, attributes)


func _emit(level: int, text: String, attributes: Dictionary) -> void:
	if not TwitchLoggerManager.wants(context_name, level, self):
		return
	var record_attributes: Dictionary = attributes
	if instance != "":
		record_attributes = attributes.duplicate()
		record_attributes[TwitchLogRecord.ATTRIBUTE_INSTANCE] = instance
	var record: Dictionary = TwitchLogRecord.create(
			level, context_name, text, record_attributes)
	TwitchLoggerManager.dispatch(record, self)
