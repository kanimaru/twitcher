extends TwitcherTest
## Unit tests for [LogfamiStdoutSink].

var _sink: LogfamiStdoutSink
var _out: Array[String]
var _err: Array[String]


func before_each() -> void:
	super()
	_out = []
	_err = []
	_sink = LogfamiStdoutSink.new()
	_sink.printer = _collect_out
	_sink.error_printer = _collect_err


func test_header_and_lines_go_to_stdout() -> void:
	_sink.start_session(PackedStringArray(["header"]))
	_sink.write("info", _record(LogfamiLevel.Severity.INFO))
	_sink.write("error", _record(LogfamiLevel.Severity.ERROR))

	assert_eq(_out, ["header", "info", "error"] as Array[String])
	assert_eq(_err.size(), 0)


func test_errors_can_go_to_stderr() -> void:
	_sink.errors_to_stderr = true

	_sink.write("warn", _record(LogfamiLevel.Severity.WARN))
	_sink.write("error", _record(LogfamiLevel.Severity.ERROR))
	_sink.write("fatal", _record(LogfamiLevel.Severity.FATAL))

	assert_eq(_out, ["warn"] as Array[String])
	assert_eq(_err, ["error", "fatal"] as Array[String])


func test_stderr_level_is_configurable() -> void:
	_sink.errors_to_stderr = true
	_sink.stderr_level = LogfamiLevel.Severity.WARN
	_sink.write("warn", _record(LogfamiLevel.Severity.WARN))
	assert_eq(_err, ["warn"] as Array[String])


func test_default_printers_are_set() -> void:
	var sink: LogfamiStdoutSink = LogfamiStdoutSink.new()
	assert_true(sink.printer.is_valid())
	assert_true(sink.error_printer.is_valid())


func _collect_out(line: String) -> void:
	_out.append(line)


func _collect_err(line: String) -> void:
	_err.append(line)


func _record(level: int) -> LogfamiRecord:
	return LogfamiRecord.create(level, "Scope", "body")
