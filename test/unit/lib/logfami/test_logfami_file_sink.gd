extends TwitcherTest
## Unit tests for [LogfamiFileSink], against the in-memory backend.

const HEADER: PackedStringArray = ["# session.start"]

var _backend: LogfamiMemoryFileBackend
var _config: LogfamiFileSinkConfig


func before_each() -> void:
	super()
	_backend = LogfamiMemoryFileBackend.new()
	_config = LogfamiFileSinkConfig.new()
	_config.directory = "user://logs"
	_config.base_name = "app"


func test_path_uses_the_formatter_extension() -> void:
	var sink: LogfamiFileSink = _sink()
	assert_eq(sink.get_file_path(), "user://logs/app.log")
	sink.configure(LogfamiJsonLinesFormatter.new())
	assert_eq(sink.get_file_path(), "user://logs/app.jsonl")


func test_configured_extension_wins() -> void:
	_config.extension = "txt"
	var sink: LogfamiFileSink = _sink()
	sink.configure(LogfamiJsonLinesFormatter.new())
	assert_eq(sink.get_file_path(), "user://logs/app.txt")


func test_absolute_path_is_globalized() -> void:
	var sink: LogfamiFileSink = _sink()
	assert_eq(sink.get_absolute_file_path(), ProjectSettings.globalize_path(sink.get_file_path()))
	assert_false(sink.get_absolute_file_path().begins_with("user://"))


func test_session_starts_with_the_header() -> void:
	var sink: LogfamiFileSink = _sink()
	sink.start_session(HEADER)
	sink.write("line", _record(LogfamiLevel.Severity.INFO))

	assert_true(_backend.directories.has("user://logs"))
	assert_eq(_backend.lines_of("user://logs/app.log"),
			PackedStringArray(["# session.start", "line"]))


func test_previous_session_is_moved_aside() -> void:
	_backend.files["user://logs/app.log"] = PackedStringArray(["last session"])

	_sink().start_session(HEADER)

	assert_eq(_backend.lines_of("user://logs/app.1.log"), PackedStringArray(["last session"]))
	assert_eq(_backend.lines_of("user://logs/app.log"), HEADER)


func test_without_rotate_on_start_the_file_is_appended() -> void:
	_config.rotate_on_start = false
	_backend.files["user://logs/app.log"] = PackedStringArray(["last session"])

	_sink().start_session(HEADER)

	assert_eq(_backend.lines_of("user://logs/app.log"),
			PackedStringArray(["last session", "# session.start"]))


func test_appended_lines_count_towards_the_rotation_limit() -> void:
	_config.rotate_on_start = false
	_config.max_lines = 3
	_backend.files["user://logs/app.log"] = PackedStringArray(["old 1", "old 2"])
	var sink: LogfamiFileSink = _sink()
	sink.start_session(PackedStringArray())

	sink.write("new 1", _record(LogfamiLevel.Severity.INFO))
	sink.write("new 2", _record(LogfamiLevel.Severity.INFO))

	assert_eq(_backend.lines_of("user://logs/app.1.log"),
			PackedStringArray(["old 1", "old 2", "new 1"]), "rotated at 3 lines in total")
	assert_eq(_backend.lines_of("user://logs/app.log"), PackedStringArray(["new 2"]))


func test_existing_lines_are_counted_once_per_session_only_when_appending() -> void:
	_config.max_lines = 2
	var rotating: LogfamiFileSink = _sink()
	rotating.start_session(HEADER)
	for index: int in 5:
		rotating.write("line %d" % index, _record(LogfamiLevel.Severity.INFO))
	assert_eq(_backend.line_count_calls, 0, "a fresh file per session never reads the old one")

	_config.rotate_on_start = false
	var appending: LogfamiFileSink = _sink()
	appending.start_session(HEADER)
	for index: int in 5:
		appending.write("line %d" % index, _record(LogfamiLevel.Severity.INFO))
	assert_eq(_backend.line_count_calls, 1, "read once at start, not again on size rotations")


func test_config_is_read_once_at_construction() -> void:
	var sink: LogfamiFileSink = _sink()
	_config.directory = "user://elsewhere"
	_config.base_name = "other"
	_config.flush_policy = LogfamiFileSinkConfig.FlushPolicy.ON_LEVEL_OR_INTERVAL
	_config.flush_interval_lines = 1000
	sink.start_session(HEADER)

	sink.write("line", _record(LogfamiLevel.Severity.DEBUG))

	assert_eq(sink.get_file_path(), "user://logs/app.log", "later path changes are ignored")
	assert_eq(_backend.flushed_lines["user://logs/app.log"], 2, "still flushes every line")


func test_rotates_at_max_lines_and_repeats_the_header() -> void:
	_config.max_lines = 2
	var sink: LogfamiFileSink = _sink()
	sink.start_session(HEADER)

	for index: int in 5:
		sink.write("line %d" % index, _record(LogfamiLevel.Severity.INFO))

	assert_eq(_backend.lines_of("user://logs/app.2.log"),
			PackedStringArray(["# session.start", "line 0", "line 1"]))
	assert_eq(_backend.lines_of("user://logs/app.1.log"),
			PackedStringArray(["# session.start", "line 2", "line 3"]))
	assert_eq(_backend.lines_of("user://logs/app.log"),
			PackedStringArray(["# session.start", "line 4"]))


func test_never_keeps_more_than_max_files() -> void:
	_config.max_lines = 1
	_config.max_files = 3
	var sink: LogfamiFileSink = _sink()
	sink.start_session(HEADER)

	for index: int in 20:
		sink.write("line %d" % index, _record(LogfamiLevel.Severity.INFO))

	assert_eq(_backend.files.size(), 3)
	assert_eq(sink.get_existing_file_paths().size(), 3)


func test_keeps_at_least_the_last_max_lines() -> void:
	_config.max_lines = 1000
	_config.max_files = 2
	var sink: LogfamiFileSink = _sink()
	sink.start_session(PackedStringArray())

	for index: int in 2500:
		sink.write(str(index), _record(LogfamiLevel.Severity.INFO))

	var kept: PackedStringArray = _backend.lines_of("user://logs/app.1.log")
	kept.append_array(_backend.lines_of("user://logs/app.log"))
	assert_gte(kept.size(), 1000)
	assert_eq(kept[kept.size() - 1], "2499", "the newest line is kept")


func test_every_line_policy_flushes_each_line() -> void:
	var sink: LogfamiFileSink = _sink()
	sink.start_session(HEADER)
	sink.write("a", _record(LogfamiLevel.Severity.DEBUG))
	sink.write("b", _record(LogfamiLevel.Severity.DEBUG))
	assert_eq(_backend.flushed_lines["user://logs/app.log"], 3)


func test_level_policy_flushes_on_warnings_and_intervals() -> void:
	_config.flush_policy = LogfamiFileSinkConfig.FlushPolicy.ON_LEVEL_OR_INTERVAL
	_config.flush_interval_lines = 3
	var sink: LogfamiFileSink = _sink()
	sink.start_session(HEADER)
	var path: String = "user://logs/app.log"

	sink.write("debug 1", _record(LogfamiLevel.Severity.DEBUG))
	assert_eq(_backend.flushed_lines[path], 1, "only the header is flushed")

	sink.write("warning", _record(LogfamiLevel.Severity.WARN))
	assert_eq(_backend.flushed_lines[path], 3, "warnings flush right away")

	sink.write("debug 2", _record(LogfamiLevel.Severity.DEBUG))
	sink.write("debug 3", _record(LogfamiLevel.Severity.DEBUG))
	assert_eq(_backend.flushed_lines[path], 3)
	sink.write("debug 4", _record(LogfamiLevel.Severity.DEBUG))
	assert_eq(_backend.flushed_lines[path], 6, "the interval flushes the rest")


func test_flush_and_close() -> void:
	_config.flush_policy = LogfamiFileSinkConfig.FlushPolicy.ON_LEVEL_OR_INTERVAL
	var sink: LogfamiFileSink = _sink()
	sink.start_session(HEADER)
	sink.write("debug", _record(LogfamiLevel.Severity.DEBUG))

	sink.flush()
	assert_eq(_backend.flushed_lines["user://logs/app.log"], 2)

	sink.close()
	assert_eq(_backend.open_path, "")
	sink.write("after close", _record(LogfamiLevel.Severity.ERROR))
	assert_false(_backend.lines_of("user://logs/app.log").has("after close"))


func test_writing_before_the_session_starts_one() -> void:
	var sink: LogfamiFileSink = _sink()
	sink.write("early", _record(LogfamiLevel.Severity.INFO))
	assert_eq(_backend.lines_of("user://logs/app.log"), PackedStringArray(["early"]))


func test_failing_directory_warns_once_and_drops_lines() -> void:
	_backend.fail_make_dir = true
	var sink: LogfamiFileSink = _sink()

	sink.start_session(HEADER)
	sink.write("lost", _record(LogfamiLevel.Severity.ERROR))

	assert_true(sink.has_failed())
	assert_eq(_backend.files.size(), 0)
	assert_push_warning("can't create the log directory")


func test_failing_open_warns_once() -> void:
	_backend.fail_open = true
	var sink: LogfamiFileSink = _sink()

	sink.start_session(HEADER)
	sink.write("lost", _record(LogfamiLevel.Severity.ERROR))
	sink.write("lost", _record(LogfamiLevel.Severity.ERROR))

	assert_true(sink.has_failed())
	assert_push_warning_count(1)


func test_failing_write_stops_the_sink() -> void:
	var sink: LogfamiFileSink = _sink()
	sink.start_session(HEADER)
	_backend.fail_write = true

	sink.write("lost", _record(LogfamiLevel.Severity.ERROR))
	_backend.fail_write = false
	sink.write("also dropped", _record(LogfamiLevel.Severity.ERROR))

	assert_true(sink.has_failed())
	assert_eq(_backend.lines_of("user://logs/app.log"), HEADER)
	assert_push_warning("can't write to")


func test_lines_from_threads_are_all_written_once() -> void:
	_config.max_lines = 0
	var sink: LogfamiFileSink = _sink()
	sink.start_session(PackedStringArray())
	var threads: Array[Thread] = []
	for index: int in 4:
		var thread: Thread = Thread.new()
		thread.start(_write_many.bind(sink, index))
		threads.append(thread)
	for thread: Thread in threads:
		thread.wait_to_finish()

	var lines: PackedStringArray = _backend.lines_of("user://logs/app.log")
	assert_eq(lines.size(), 4 * 250)
	assert_eq(lines.count("t0-0"), 1, "no line is written twice")


func _write_many(sink: LogfamiFileSink, index: int) -> void:
	for count: int in 250:
		sink.write("t%d-%d" % [index, count], _record(LogfamiLevel.Severity.INFO))


func _sink() -> LogfamiFileSink:
	return LogfamiFileSink.new(_config, _backend)


func _record(level: int) -> LogfamiRecord:
	return LogfamiRecord.create(level, "Scope", "body")
