extends TwitcherTest
## Unit tests for [LogfamiEngineCapture].

var _logfami: Logfami
var _sink: LogfamiMemorySink
var _capture: LogfamiEngineCapture


func before_each() -> void:
	super()
	_logfami = Logfami.new(LogfamiResource.new(), LogfamiFixedClock.new())
	_sink = LogfamiMemorySink.new()
	_logfami.add_pipeline(LogfamiPipeline.new(
			LogfamiTextFormatter.new(), _sink, LogfamiLevel.Severity.TRACE))
	_capture = LogfamiEngineCapture.new(_logfami)


func after_each() -> void:
	_capture.uninstall()
	super()


func test_errors_become_error_records_with_their_location() -> void:
	_capture._log_error("_ready", "res://player.gd", 12, "", "Player has no weapon",
			false, Logger.ERROR_TYPE_SCRIPT, [])

	var record: LogfamiRecord = _sink.records[0]
	assert_eq(record.severity_number, LogfamiLevel.Severity.ERROR)
	assert_eq(record.scope, LogfamiEngineCapture.SCOPE)
	assert_eq(record.body, "Player has no weapon")
	assert_eq(record.attributes, {
		"code.function": "_ready",
		"code.filepath": "res://player.gd",
		"code.lineno": 12,
		"error.type": "script",
	})


func test_warnings_become_warn_records() -> void:
	_capture._log_error("f", "a.gd", 1, "careful", "", false, Logger.ERROR_TYPE_WARNING, [])
	assert_eq(_sink.records[0].severity_number, LogfamiLevel.Severity.WARN)
	assert_eq(_sink.records[0].body, "careful", "the code is used without a rationale")


func test_messages_are_ignored_by_default() -> void:
	_capture._log_message("hello\n", false)
	assert_eq(_sink.records.size(), 0)


func test_messages_can_be_captured() -> void:
	_capture.capture_messages = true

	_capture._log_message("hello\n", false)
	_capture._log_message("oops\n", true)

	assert_eq(_sink.records[0].body, "hello", "the trailing newline of print is dropped")
	assert_eq(_sink.records[0].severity_number, LogfamiLevel.Severity.INFO)
	assert_eq(_sink.records[1].severity_number, LogfamiLevel.Severity.ERROR)


func test_install_is_idempotent() -> void:
	_capture.install()
	_capture.install()
	assert_true(_capture.is_installed())
	_capture.uninstall()
	_capture.uninstall()
	assert_false(_capture.is_installed())


func test_installed_capture_receives_push_warning() -> void:
	_capture.install()

	push_warning("logfami capture probe")

	assert_push_warning("logfami capture probe")
	assert_eq(_sink.records.size(), 1)
	assert_string_contains(_sink.records[0].body, "logfami capture probe")


## A stdout sink prints, and printing reaches the capture again: the line must
## be dropped instead of looping forever.
func test_printing_sinks_do_not_loop() -> void:
	var lines: Array[String] = []
	var stdout: LogfamiStdoutSink = LogfamiStdoutSink.new()
	stdout.printer = func(line: String) -> void:
		lines.append(line)
		_capture._log_message(line + "\n", false)
	_logfami.add_pipeline(LogfamiPipeline.new(LogfamiTextFormatter.new(), stdout))
	_capture.capture_messages = true

	_logfami.log_message(LogfamiLevel.Severity.INFO, "Game", "started")

	assert_eq(lines.size(), 2, "the session header and the record, nothing echoed")
