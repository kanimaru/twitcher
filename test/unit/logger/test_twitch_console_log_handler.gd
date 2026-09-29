extends TwitcherTest
## Unit tests for [TwitchConsoleLogHandler].
##
## The console output existed before handlers did. The legacy formats below are
## copied from the TwitchLogger that printed directly, so any drift in how the
## Godot output looks fails here.

const LEGACY_INFO: String = "%s I[color=%s][%s%s] %s[/color]"
const LEGACY_ERROR: String = "%s E[b][color=%s][%s%s] %s[/color][/b]"
const LEGACY_DEBUG: String = "%s D[i][color=%s][%s%s] %s[/color][/i]"
const LEGACY_WARN: String = "%s [color=yellow]W[/color][color=%s][%s%s] %s[/color]"

var _handler: TwitchConsoleLogHandler
var _lines: PackedStringArray


func before_each() -> void:
	super()
	_lines = []
	_handler = TwitchConsoleLogHandler.new()
	_handler.printer = _collect


func test_formats_match_the_legacy_output(params: Array = use_parameters([
	[TwitchLogLevel.Severity.INFO, LEGACY_INFO],
	[TwitchLogLevel.Severity.WARN, LEGACY_WARN],
	[TwitchLogLevel.Severity.ERROR, LEGACY_ERROR],
	[TwitchLogLevel.Severity.FATAL, LEGACY_ERROR],
	[TwitchLogLevel.Severity.DEBUG, LEGACY_DEBUG],
	[TwitchLogLevel.Severity.TRACE, LEGACY_DEBUG],
])) -> void:
	var level: int = params[0]
	var legacy_format: String = params[1]
	var record: Dictionary = TwitchLogRecord.create(level, "TwitchAuth", "Token got authorized")

	var expected: String = legacy_format % [
		record[TwitchLogRecord.TICKS_MSEC], _legacy_color("TwitchAuth"), "TwitchAuth", "",
		"Token got authorized",
	]
	assert_eq(_handler.format(record), expected)


func test_instance_is_shown_like_the_legacy_suffix() -> void:
	var record: Dictionary = TwitchLogRecord.create(
			TwitchLogLevel.Severity.INFO, "TwitchIRC", "joined", { "instance": "main" })

	var expected: String = LEGACY_INFO % [
		record[TwitchLogRecord.TICKS_MSEC], _legacy_color("TwitchIRC"), "TwitchIRC", "-main",
		"joined",
	]
	assert_eq(_handler.format(record), expected)


func test_attributes_are_appended_sorted() -> void:
	var record: Dictionary = TwitchLogRecord.create(TwitchLogLevel.Severity.INFO, "TwitchAuth",
			"Token refreshed", { "scopes": 3, "expires_in": 3600, "instance": "bot" })

	assert_string_ends_with(_handler.format(record),
			"[TwitchAuth-bot] Token refreshed {expires_in=3600, scopes=3}[/color]")


func test_color_matches_the_legacy_algorithm() -> void:
	for text: String in ["TwitchAuth", "TwitchIRC", "Http", "", "日本語"]:
		assert_eq(TwitchConsoleLogHandler.color_for(text), _legacy_color(text), text)


func test_handle_sends_the_formatted_line_to_the_printer() -> void:
	var record: Dictionary = TwitchLogRecord.create(TwitchLogLevel.Severity.INFO, "Scope", "hi")
	_handler.handle(record)
	assert_eq(_lines, PackedStringArray([_handler.format(record)]))


func test_threshold_follows_the_registered_logger() -> void:
	var logger: TwitchLogger = TwitchLogger.new("GutConsoleProbe")

	logger.enabled = false
	assert_eq(_handler.threshold_for("GutConsoleProbe"), TwitchLogLevel.OFF, "disabled")

	logger.enabled = true
	logger.debug = false
	assert_eq(_handler.threshold_for("GutConsoleProbe"), TwitchLogLevel.Severity.INFO, "enabled")

	logger.debug = true
	assert_eq(_handler.threshold_for("GutConsoleProbe"), TwitchLogLevel.Severity.DEBUG, "debug")


func test_threshold_is_off_for_unknown_scopes() -> void:
	assert_eq(_handler.threshold_for("GutNeverRegistered"), TwitchLogLevel.OFF)


func test_threshold_is_off_for_registry_entries_that_are_not_loggers() -> void:
	TwitchLoggerManager.log_registry["GutNotALogger"] = "contamination"
	assert_eq(_handler.threshold_for("GutNotALogger"), TwitchLogLevel.OFF)


func _collect(line: String) -> void:
	_lines.append(line)


## The color algorithm as TwitchLogger shipped it before the handler existed.
func _legacy_color(text: String) -> String:
	var hash_value: int = text.hash()
	var r: float = clamp((hash_value & 0xff) * 1.5, 0, 255)
	var g: float = clamp(((hash_value >> 8) & 0xff) * 1.5, 0, 255)
	var b: float = clamp(((hash_value >> 16) & 0xff) * 1.5, 0, 255)
	return "#" + ("%02x" % r) + ("%02x" % g) + ("%02x" % b)
