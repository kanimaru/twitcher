extends TwitcherTest
## Unit tests for [TwitchLogLevel].

## [code][level, expected text][/code], including numbers inside a severity's
## OpenTelemetry range and the edges around it.
var text_params: Array = [
	[TwitchLogLevel.Severity.TRACE, "TRACE"],
	[TwitchLogLevel.Severity.DEBUG, "DEBUG"],
	[TwitchLogLevel.Severity.INFO, "INFO"],
	[TwitchLogLevel.Severity.WARN, "WARN"],
	[TwitchLogLevel.Severity.ERROR, "ERROR"],
	[TwitchLogLevel.Severity.FATAL, "FATAL"],
	[4, "TRACE"],
	[10, "INFO"],
	[12, "INFO"],
	[24, "FATAL"],
	[0, ""],
	[25, ""],
	[TwitchLogLevel.OFF, ""],
]

## [code][setting value, expected threshold][/code].
var threshold_params: Array = [
	["off", TwitchLogLevel.OFF],
	["trace", TwitchLogLevel.Severity.TRACE],
	["debug", TwitchLogLevel.Severity.DEBUG],
	["info", TwitchLogLevel.Severity.INFO],
	["warn", TwitchLogLevel.Severity.WARN],
	["warning", TwitchLogLevel.Severity.WARN],
	["error", TwitchLogLevel.Severity.ERROR],
	["fatal", TwitchLogLevel.Severity.FATAL],
	["INFO", TwitchLogLevel.Severity.INFO],
	[" debug ", TwitchLogLevel.Severity.DEBUG],
	["verbose", TwitchLogLevel.OFF],
	["", TwitchLogLevel.OFF],
]


func test_severities_follow_open_telemetry_numbers() -> void:
	assert_eq(TwitchLogLevel.Severity.TRACE, 1)
	assert_eq(TwitchLogLevel.Severity.DEBUG, 5)
	assert_eq(TwitchLogLevel.Severity.INFO, 9)
	assert_eq(TwitchLogLevel.Severity.WARN, 13)
	assert_eq(TwitchLogLevel.Severity.ERROR, 17)
	assert_eq(TwitchLogLevel.Severity.FATAL, 21)


func test_off_is_above_every_severity() -> void:
	assert_gt(TwitchLogLevel.OFF, TwitchLogLevel.Severity.FATAL + 3)


## Twitcher and Logfami each define the levels, because Logfami must not
## reference Twitcher. The two copies must never drift apart.
func test_levels_match_logfami() -> void:
	assert_eq(TwitchLogLevel.Severity.keys(), LogfamiLevel.Severity.keys())
	assert_eq(TwitchLogLevel.Severity.values(), LogfamiLevel.Severity.values())
	assert_eq(TwitchLogLevel.OFF, LogfamiLevel.OFF)
	for text: String in ["off", "trace", "debug", "info", "warn", "warning", "error", "fatal"]:
		assert_eq(TwitchLogLevel.threshold_from_text(text),
				LogfamiLevel.threshold_from_text(text), text)


func test_to_text(params: Array = use_parameters(text_params)) -> void:
	var level: int = params[0]
	var expected: String = params[1]
	assert_eq(TwitchLogLevel.to_text(level), expected, "text of %d" % level)


func test_threshold_from_text(params: Array = use_parameters(threshold_params)) -> void:
	var text: String = params[0]
	var expected: int = params[1]
	assert_eq(TwitchLogLevel.threshold_from_text(text), expected, "threshold of '%s'" % text)
