extends TwitcherTest
## Unit tests for [LogfamiLevel].

var text_params: Array = [
	[LogfamiLevel.Severity.TRACE, "TRACE"],
	[LogfamiLevel.Severity.DEBUG, "DEBUG"],
	[LogfamiLevel.Severity.INFO, "INFO"],
	[LogfamiLevel.Severity.WARN, "WARN"],
	[LogfamiLevel.Severity.ERROR, "ERROR"],
	[LogfamiLevel.Severity.FATAL, "FATAL"],
	[11, "INFO"],
	[24, "FATAL"],
	[0, ""],
	[25, ""],
]

var threshold_params: Array = [
	["off", LogfamiLevel.OFF],
	["trace", LogfamiLevel.Severity.TRACE],
	["DEBUG", LogfamiLevel.Severity.DEBUG],
	[" info ", LogfamiLevel.Severity.INFO],
	["warn", LogfamiLevel.Severity.WARN],
	["warning", LogfamiLevel.Severity.WARN],
	["error", LogfamiLevel.Severity.ERROR],
	["fatal", LogfamiLevel.Severity.FATAL],
	["chatty", LogfamiLevel.OFF],
]

var syslog_params: Array = [
	[LogfamiLevel.Severity.TRACE, 7],
	[LogfamiLevel.Severity.DEBUG, 7],
	[LogfamiLevel.Severity.INFO, 6],
	[LogfamiLevel.Severity.WARN, 4],
	[LogfamiLevel.Severity.ERROR, 3],
	[LogfamiLevel.Severity.FATAL, 2],
	[18, 3],
	[0, 7],
]


func test_to_text(params: Array = use_parameters(text_params)) -> void:
	var level: int = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiLevel.to_text(level), expected, "text of %d" % level)


func test_threshold_from_text(params: Array = use_parameters(threshold_params)) -> void:
	var text: String = params[0]
	var expected: int = params[1]
	assert_eq(LogfamiLevel.threshold_from_text(text), expected, "threshold of '%s'" % text)


func test_to_syslog(params: Array = use_parameters(syslog_params)) -> void:
	var level: int = params[0]
	var expected: int = params[1]
	assert_eq(LogfamiLevel.to_syslog(level), expected, "syslog of %d" % level)


func test_off_is_above_every_severity() -> void:
	assert_gt(LogfamiLevel.OFF, LogfamiLevel.Severity.FATAL + 3)
