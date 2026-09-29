@tool
class_name TwitchConsoleLogHandler
extends RefCounted
## Prints log records to the Godot output in the classic Twitcher look.
##
## Which contexts print is configured per logger under
## [code]twitcher/logs/<Context>[/code] ([code]off[/code], [code]info[/code],
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


func _init() -> void:
	printer = _print_rich


## Deterministic color for a context name, so every context keeps its color
## across sessions.
static func color_for(text: String) -> String:
	var hash_value: int = text.hash()
	var red: int = clampi(int((hash_value & 0xff) * BRIGHTEN_FACTOR), 0, 255)
	var green: int = clampi(int(((hash_value >> 8) & 0xff) * BRIGHTEN_FACTOR), 0, 255)
	var blue: int = clampi(int(((hash_value >> 16) & 0xff) * BRIGHTEN_FACTOR), 0, 255)
	return "#%02x%02x%02x" % [red, green, blue]


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
	var values: Array = [record[TwitchLogRecord.TICKS_MSEC], color_for(scope), name, text]
	if level >= TwitchLogLevel.Severity.ERROR:
		return _ERROR_FORMAT % values
	if level >= TwitchLogLevel.Severity.WARN:
		return _WARN_FORMAT % values
	if level >= TwitchLogLevel.Severity.INFO:
		return _INFO_FORMAT % values
	return _DEBUG_FORMAT % values


## Threshold for [param scope], taken from the logger registered under that
## context: off when disabled, debug when debugging, otherwise info.
func threshold_for(scope: String) -> int:
	var registered: Variant = TwitchLoggerManager.log_registry.get(scope)
	if not registered is TwitchLogger:
		return TwitchLogLevel.OFF
	var logger: TwitchLogger = registered
	if not logger.enabled:
		return TwitchLogLevel.OFF
	if logger.debug:
		return TwitchLogLevel.Severity.DEBUG
	return TwitchLogLevel.Severity.INFO


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
