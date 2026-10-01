extends TwitcherTest
## Unit tests for [Logfami], the entry point of the library.


## Sink that logs again while writing, like a sink reporting its own failure
## through a logger that feeds back into Logfami.
class EchoSink:
	extends LogfamiSink

	var logfami: Logfami
	var lines: Array[String] = []


	func write(line: String, _record: LogfamiRecord) -> void:
		lines.append(line)
		logfami.log_message(LogfamiLevel.Severity.ERROR, "Echo", "written: " + line)


class HeaderFormatter:
	extends LogfamiFormatter

	func format(record: LogfamiRecord, _resource: LogfamiResource) -> String:
		return record.body


	func header(_resource: LogfamiResource, started_unix_ms: int) -> PackedStringArray:
		return PackedStringArray(["session %d" % started_unix_ms])


class BodyFormatter:
	extends LogfamiFormatter

	func format(record: LogfamiRecord, _resource: LogfamiResource) -> String:
		return "%s|%s|%s" % [record.severity_text, record.scope, record.body]


var _clock: LogfamiFixedClock
var _logfami: Logfami
var _sink: LogfamiMemorySink


func before_each() -> void:
	super()
	_clock = LogfamiFixedClock.new(1_000, 0)
	_logfami = Logfami.new(LogfamiResource.new({ "service.name": "test" }), _clock)
	_sink = LogfamiMemorySink.new()
	_logfami.add_pipeline(LogfamiPipeline.new(BodyFormatter.new(), _sink))


func test_defaults_to_the_detected_resource_and_system_clock() -> void:
	var logfami: Logfami = Logfami.new()
	assert_true(logfami.resource.attributes.has(LogfamiResource.SERVICE_NAME))
	assert_not_null(logfami.clock)


func test_log_reaches_the_pipeline() -> void:
	_logfami.log_message(LogfamiLevel.Severity.INFO, "Shop", "bought", { "id": 1 })

	assert_eq(_sink.lines, ["INFO|Shop|bought"] as Array[String])
	assert_eq(_sink.records[0].attributes, { "id": 1 })
	assert_eq(_sink.records[0].time_unix_ms, 1_000, "records are stamped with Logfami's clock")


func test_add_pipeline_starts_its_session() -> void:
	var header_sink: LogfamiMemorySink = LogfamiMemorySink.new()
	_logfami.add_pipeline(LogfamiPipeline.new(HeaderFormatter.new(), header_sink))
	assert_eq(header_sink.header, PackedStringArray(["session 1000"]))


func test_every_pipeline_receives_the_record() -> void:
	var second: LogfamiMemorySink = LogfamiMemorySink.new()
	_logfami.add_pipeline(LogfamiPipeline.new(BodyFormatter.new(), second))

	_logfami.log_message(LogfamiLevel.Severity.INFO, "Shop", "bought")

	assert_eq(_sink.lines.size(), 1)
	assert_eq(second.lines.size(), 1)


func test_remove_pipeline() -> void:
	var pipeline: LogfamiPipeline = _logfami.get_pipelines()[0]
	_logfami.remove_pipeline(pipeline)
	_logfami.log_message(LogfamiLevel.Severity.INFO, "Shop", "bought")
	assert_eq(_sink.lines.size(), 0)


func test_min_level_is_the_lowest_pipeline_level() -> void:
	assert_eq(_logfami.min_level(), LogfamiLevel.Severity.INFO)
	_logfami.add_pipeline(LogfamiPipeline.new(
			BodyFormatter.new(), LogfamiMemorySink.new(), LogfamiLevel.Severity.DEBUG))
	assert_eq(_logfami.min_level(), LogfamiLevel.Severity.DEBUG)


func test_min_level_without_pipelines_is_off() -> void:
	var logfami: Logfami = Logfami.new(LogfamiResource.new(), _clock)
	assert_eq(logfami.min_level(), LogfamiLevel.OFF)


func test_wants() -> void:
	assert_true(_logfami.wants("Shop", LogfamiLevel.Severity.INFO))
	assert_false(_logfami.wants("Shop", LogfamiLevel.Severity.DEBUG))


func test_handler_accepts_record_dictionaries() -> void:
	var handler: Callable = _logfami.as_handler()

	handler.call({ "severity_number": 17, "scope": "TwitchIRC", "body": "lost" })

	assert_eq(_sink.lines, ["ERROR|TwitchIRC|lost"] as Array[String])


func test_triple_follows_the_set_logger_convention() -> void:
	var triple: Array[Callable] = _logfami.as_triple("Http")
	_logfami.get_pipelines()[0].min_level = LogfamiLevel.Severity.TRACE

	triple[0].call("failed")
	triple[1].call("sent")
	triple[2].call("bytes")

	assert_eq(_sink.lines, [
		"ERROR|Http|failed",
		"INFO|Http|sent",
		"DEBUG|Http|bytes",
	] as Array[String])


func test_triple_respects_the_pipeline_levels() -> void:
	var triple: Array[Callable] = _logfami.as_triple("Http")
	triple[2].call("debug is below info")
	assert_eq(_sink.lines.size(), 0)


func test_records_logged_while_writing_are_dropped() -> void:
	var echo: EchoSink = EchoSink.new()
	echo.logfami = _logfami
	_logfami.add_pipeline(LogfamiPipeline.new(BodyFormatter.new(), echo))

	_logfami.log_message(LogfamiLevel.Severity.INFO, "Shop", "bought")

	assert_eq(echo.lines, ["INFO|Shop|bought"] as Array[String], "no recursion")
	assert_eq(_sink.lines, ["INFO|Shop|bought"] as Array[String])


func test_logging_works_again_after_a_dropped_record() -> void:
	var echo: EchoSink = EchoSink.new()
	echo.logfami = _logfami
	_logfami.add_pipeline(LogfamiPipeline.new(BodyFormatter.new(), echo))

	_logfami.log_message(LogfamiLevel.Severity.INFO, "Shop", "first")
	_logfami.log_message(LogfamiLevel.Severity.INFO, "Shop", "second")

	assert_eq(echo.lines.size(), 2)


func test_flush_and_close_reach_every_pipeline() -> void:
	_logfami.flush()
	_logfami.close()
	assert_eq(_sink.flush_count, 1)
	assert_true(_sink.is_closed)


## The whole chain on the real filesystem: what a user would send in.
func test_end_to_end_writes_a_redacted_log_file() -> void:
	var config: LogfamiFileSinkConfig = LogfamiFileSinkConfig.new()
	config.directory = scratch_dir()
	config.base_name = "game"
	var sink: LogfamiFileSink = LogfamiFileSink.new(config)
	var pipeline: LogfamiPipeline = LogfamiPipeline.new(LogfamiTextFormatter.new(), sink)
	pipeline.add_processor(LogfamiRedactor.with_defaults())
	var resource: LogfamiResource = LogfamiResource.new({ "service.name": "Game" })
	var logfami: Logfami = Logfami.new(resource, LogfamiFixedClock.new(0))
	logfami.add_pipeline(pipeline)

	logfami.log_message(LogfamiLevel.Severity.INFO, "IRC", "PASS oauth:abc123")
	logfami.log_message(LogfamiLevel.Severity.WARN, "Chat", "evil\nfake line")
	logfami.close()

	assert_eq(FileAccess.get_file_as_string(sink.get_file_path()), "\n".join([
		"# session.start 1970-01-01T00:00:00.000Z service.name=Game",
		"1970-01-01T00:00:00.000Z INFO  [IRC] PASS oauth:[REDACTED]",
		"1970-01-01T00:00:00.000Z WARN  [Chat] evil\\nfake line",
		"",
	]))
