extends TwitcherTest
## Unit tests for [LogfamiMemorySink].


func test_keeps_lines_records_and_header() -> void:
	var sink: LogfamiMemorySink = LogfamiMemorySink.new()
	var record: LogfamiRecord = LogfamiRecord.create(LogfamiLevel.Severity.INFO, "S", "b")

	sink.start_session(PackedStringArray(["# header"]))
	sink.write("line", record)

	assert_eq(sink.header, PackedStringArray(["# header"]))
	assert_eq(sink.lines, ["line"] as Array[String])
	assert_same(sink.records[0], record)


func test_counts_flushes_and_remembers_close() -> void:
	var sink: LogfamiMemorySink = LogfamiMemorySink.new()
	sink.flush()
	sink.flush()
	sink.close()
	assert_eq(sink.flush_count, 2)
	assert_true(sink.is_closed)
