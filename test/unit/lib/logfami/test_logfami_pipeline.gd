extends TwitcherTest
## Unit tests for [LogfamiPipeline].


## Formats as "<LEVEL> <scope>: <body>" and announces itself in the header.
class PlainFormatter:
	extends LogfamiFormatter

	func format(record: LogfamiRecord, _resource: LogfamiResource) -> String:
		return "%s %s: %s" % [record.severity_text, record.scope, record.body]


	func header(resource: LogfamiResource, started_unix_ms: int) -> PackedStringArray:
		return PackedStringArray(["start %d %s" % [started_unix_ms, resource.attributes]])


class UppercaseProcessor:
	extends LogfamiProcessor

	func process(record: LogfamiRecord) -> LogfamiRecord:
		record.body = record.body.to_upper()
		return record


class SuffixProcessor:
	extends LogfamiProcessor

	func process(record: LogfamiRecord) -> LogfamiRecord:
		record.body += "!"
		return record


class DropProcessor:
	extends LogfamiProcessor

	var seen: int = 0


	func process(_record: LogfamiRecord) -> LogfamiRecord:
		seen += 1
		return null


var _sink: LogfamiMemorySink
var _pipeline: LogfamiPipeline
var _resource: LogfamiResource


func before_each() -> void:
	super()
	_sink = LogfamiMemorySink.new()
	_pipeline = LogfamiPipeline.new(PlainFormatter.new(), _sink, LogfamiLevel.Severity.INFO)
	_resource = LogfamiResource.new({ "service.name": "test" })


func test_formats_and_writes_accepted_records() -> void:
	_pipeline.emit(_record(LogfamiLevel.Severity.INFO, "Shop", "bought"), _resource)
	assert_eq(_sink.lines, ["INFO Shop: bought"] as Array[String])


func test_filters_by_level() -> void:
	_pipeline.emit(_record(LogfamiLevel.Severity.DEBUG, "Shop", "hidden"), _resource)
	_pipeline.emit(_record(LogfamiLevel.Severity.ERROR, "Shop", "shown"), _resource)
	assert_eq(_sink.lines, ["ERROR Shop: shown"] as Array[String])


func test_include_scopes_limit_the_pipeline() -> void:
	_pipeline.include_scopes = PackedStringArray(["Shop"])
	assert_true(_pipeline.accepts("Shop", LogfamiLevel.Severity.INFO))
	assert_false(_pipeline.accepts("Bank", LogfamiLevel.Severity.INFO))


func test_exclude_scopes_win_over_include_scopes() -> void:
	_pipeline.include_scopes = PackedStringArray(["Shop"])
	_pipeline.exclude_scopes = PackedStringArray(["Shop"])
	assert_false(_pipeline.accepts("Shop", LogfamiLevel.Severity.FATAL))


func test_processors_run_in_order() -> void:
	_pipeline.add_processor(UppercaseProcessor.new()).add_processor(SuffixProcessor.new())
	_pipeline.emit(_record(LogfamiLevel.Severity.INFO, "Shop", "bought"), _resource)
	assert_eq(_sink.lines, ["INFO Shop: BOUGHT!"] as Array[String])


func test_a_processor_can_drop_the_record() -> void:
	var drop: DropProcessor = DropProcessor.new()
	_pipeline.add_processor(drop).add_processor(UppercaseProcessor.new())

	_pipeline.emit(_record(LogfamiLevel.Severity.INFO, "Shop", "bought"), _resource)

	assert_eq(drop.seen, 1)
	assert_eq(_sink.lines.size(), 0)


func test_processors_never_change_the_original_record() -> void:
	var record: LogfamiRecord = _record(LogfamiLevel.Severity.INFO, "Shop", "bought")
	_pipeline.add_processor(UppercaseProcessor.new())

	_pipeline.emit(record, _resource)

	assert_eq(record.body, "bought")


func test_start_hands_the_header_to_the_sink() -> void:
	_pipeline.start(_resource, 123)
	assert_eq(_sink.header, PackedStringArray(["start 123 { \"service.name\": \"test\" }"]))


func test_flush_and_close_reach_the_sink() -> void:
	_pipeline.flush()
	_pipeline.close()
	assert_eq(_sink.flush_count, 1)
	assert_true(_sink.is_closed)


func test_lines_from_threads_are_all_written() -> void:
	var threads: Array[Thread] = []
	for index: int in 4:
		var thread: Thread = Thread.new()
		thread.start(_emit_many.bind(index))
		threads.append(thread)
	for thread: Thread in threads:
		thread.wait_to_finish()
	assert_eq(_sink.lines.size(), 4 * 50)


func _emit_many(index: int) -> void:
	for count: int in 50:
		_pipeline.emit(_record(LogfamiLevel.Severity.INFO, "T%d" % index, str(count)), _resource)


func _record(level: int, scope: String, body: String) -> LogfamiRecord:
	return LogfamiRecord.create(level, scope, body)
