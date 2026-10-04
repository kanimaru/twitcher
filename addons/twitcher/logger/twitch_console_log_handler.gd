@tool
class_name TwitchConsoleLogHandler
extends RefCounted
## Prints log records to the Godot output in the classic Twitcher look.
##
## Whether a record prints depends on the [member TwitchLogger.enabled] and
## [member TwitchLogger.debug] flags of the logger that emitted it, which come
## from [code]twitcher/logs/<Context>[/code] ([code]off[/code], [code]info[/code],
## [code]debug[/code]); see [method threshold_for]. The format is
## [code]<ticks> <level>[<Context>-<instance>] <message> {<attributes>}[/code],
## colored per context.

const BRIGHTEN_FACTOR: float = 1.5

const _ERROR_FORMAT: String = "%s E[b][color=%s][%s] %s[/color][/b]"
const _WARN_FORMAT: String = "%s [color=yellow]W[/color][color=%s][%s] %s[/color]"
const _INFO_FORMAT: String = "%s I[color=%s][%s] %s[/color]"
const _DEBUG_FORMAT: String = "%s D[i][color=%s][%s] %s[/color][/i]"

## Receives each formatted BBCode line. Defaults to [method @GlobalScope.print_rich].
var printer: Callable
## Escapes BBCode in the context name, message and attributes, so a message like
## [code]"[b]"[/code] shows literally. For rich text labels that display
## arbitrary messages; the Godot output keeps the classic behavior.
var escape_markup: bool = false


## Deterministic color for a context name, so every context keeps its color
## across sessions.
static func color_for(text: String) -> String:
	var hash_value: int = text.hash()
	var red: int = clampi(int((hash_value & 0xff) * BRIGHTEN_FACTOR), 0, 255)
	var green: int = clampi(int(((hash_value >> 8) & 0xff) * BRIGHTEN_FACTOR), 0, 255)
	var blue: int = clampi(int(((hash_value >> 16) & 0xff) * BRIGHTEN_FACTOR), 0, 255)
	return "#%02x%02x%02x" % [red, green, blue]


func _init() -> void:
	printer = _print_rich


## Handler entry point, see [method TwitchLoggerManager.add_scoped_handler].
func handle(record: Dictionary) -> void:
	printer.call(format(record))


func format(record: Dictionary) -> String:
	var level: int = record[TwitchLogRecord.SEVERITY_NUMBER]
	var scope: String = record[TwitchLogRecord.SCOPE]
	var attributes: Dictionary = record[TwitchLogRecord.ATTRIBUTES]
	var name: String = scope
	var instance: String = attributes.get(TwitchLogRecord.ATTRIBUTE_INSTANCE, "")
	if instance != "":
		name += "-" + instance
	var text: String = str(record[TwitchLogRecord.BODY]) + _format_attributes(attributes)
	if escape_markup:
		name = name.replace("[", "[lb]")
		text = text.replace("[", "[lb]")
	var values: Array = [record[TwitchLogRecord.TICKS_MSEC], color_for(scope), name, text]
	if level >= LogfamiLevel.Severity.ERROR:
		return _ERROR_FORMAT % values
	if level >= LogfamiLevel.Severity.WARN:
		return _WARN_FORMAT % values
	if level >= LogfamiLevel.Severity.INFO:
		return _INFO_FORMAT % values
	return _DEBUG_FORMAT % values


## Threshold of [param logger]: off when disabled, debug when debugging,
## otherwise info. A mode picked at runtime ([method TwitchLogContexts.set_mode])
## wins over the logger's flags. Without a logger (records dispatched directly) the logger
## registered last under [param scope] decides.
func threshold_for(scope: String, logger: TwitchLogger = null) -> int:
	var override_level: int = TwitchLogContexts.override_level(scope)
	if override_level != TwitchLogContexts.NO_OVERRIDE:
		return override_level
	var source: TwitchLogger = logger
	if source == null:
		var registered: Variant = TwitchLoggerManager.log_registry.get(scope)
		if not registered is TwitchLogger:
			return LogfamiLevel.OFF
		source = registered
	if not source.enabled:
		return LogfamiLevel.OFF
	if source.debug:
		return LogfamiLevel.Severity.DEBUG
	return LogfamiLevel.Severity.INFO


func _format_attributes(attributes: Dictionary) -> String:
	var keys: Array = attributes.keys()
	keys.erase(TwitchLogRecord.ATTRIBUTE_INSTANCE)
	if keys.is_empty():
		return ""
	keys.sort()
	var pairs: PackedStringArray = []
	for key: Variant in keys:
		pairs.append("%s=%s" % [key, attributes[key]])
	return " {%s}" % ", ".join(pairs)


func _print_rich(line: String) -> void:
	print_rich(line)
