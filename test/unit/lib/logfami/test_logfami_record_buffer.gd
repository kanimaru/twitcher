extends TwitcherTest
## Unit tests for [LogfamiRecordBuffer].


func test_keeps_records_oldest_first() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new()
	var first: LogfamiRecord = _record("A", "one")
	var second: LogfamiRecord = _record("B", "two")

	buffer.add(first)
	buffer.add(second)

	var records: Array[LogfamiRecord] = buffer.get_records()
	assert_eq(buffer.size(), 2)
	assert_same(records[0], first)
	assert_same(records[1], second)


func test_drops_the_oldest_records_beyond_capacity() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new(2)
	for body: String in ["one", "two", "three"]:
		buffer.add(_record("A", body))

	var bodies: PackedStringArray = []
	for record: LogfamiRecord in buffer.get_records():
		bodies.append(record.body)
	assert_eq(bodies, PackedStringArray(["two", "three"]))


func test_capacity_is_at_least_one() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new(0)
	buffer.add(_record("A", "one"))
	buffer.add(_record("A", "two"))

	assert_eq(buffer.capacity, 1)
	assert_eq(buffer.size(), 1)


func test_lowering_the_capacity_applies_to_the_next_record() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new(5)
	for body: String in ["a", "b", "c"]:
		buffer.add(_record("A", body))

	buffer.capacity = 1
	buffer.add(_record("A", "d"))

	assert_eq(buffer.size(), 1)
	assert_eq(buffer.get_records()[0].body, "d")


func test_get_records_applies_the_filter() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new()
	buffer.add(_record("Quiet", "keep"))
	buffer.add(_record("Noisy", "drop"))
	var filter: LogfamiRecordFilter = LogfamiRecordFilter.new()
	filter.mute("Noisy")

	var records: Array[LogfamiRecord] = buffer.get_records(filter)

	assert_eq(records.size(), 1)
	assert_eq(records[0].body, "keep")


func test_get_records_returns_a_copy() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new()
	buffer.add(_record("A", "one"))

	buffer.get_records().clear()

	assert_eq(buffer.size(), 1)


func test_scopes_are_unique_and_sorted() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new()
	for scope: String in ["Zeta", "Alpha", "Zeta", "Mid"]:
		buffer.add(_record(scope, "text"))

	assert_eq(buffer.scopes(), PackedStringArray(["Alpha", "Mid", "Zeta"]))


func test_clear_removes_everything_and_changes_the_version() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new()
	buffer.add(_record("A", "one"))
	var version_before: int = buffer.version

	buffer.clear()

	assert_eq(buffer.size(), 0)
	assert_eq(buffer.scopes().size(), 0)
	assert_ne(buffer.version, version_before)


func test_version_changes_with_every_added_record() -> void:
	var buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new(1)
	var versions: Array[int] = [buffer.version]
	for body: String in ["a", "b"]:
		buffer.add(_record("A", body))
		versions.append(buffer.version)

	assert_eq(versions.size(), 3)
	assert_ne(versions[0], versions[1])
	assert_ne(versions[1], versions[2], "also when the buffer is full")


func test_merge_orders_by_time_and_keeps_the_first_list_first_on_ties() -> void:
	var a1: LogfamiRecord = _timed(10, "a1")
	var a2: LogfamiRecord = _timed(30, "a2")
	var b1: LogfamiRecord = _timed(10, "b1")
	var b2: LogfamiRecord = _timed(20, "b2")
	var b3: LogfamiRecord = _timed(40, "b3")

	var merged: Array[LogfamiRecord] = LogfamiRecordBuffer.merge([a1, a2], [b1, b2, b3])

	var bodies: PackedStringArray = []
	for record: LogfamiRecord in merged:
		bodies.append(record.body)
	assert_eq(bodies, PackedStringArray(["a1", "b1", "b2", "a2", "b3"]))


func test_merge_with_an_empty_list_returns_the_other() -> void:
	var only: LogfamiRecord = _timed(1, "only")
	var empty: Array[LogfamiRecord] = []

	assert_eq(LogfamiRecordBuffer.merge([only], empty).size(), 1)
	assert_eq(LogfamiRecordBuffer.merge(empty, [only]).size(), 1)
	assert_eq(LogfamiRecordBuffer.merge(empty, empty).size(), 0)


func _timed(time_unix_ms: int, body: String) -> LogfamiRecord:
	var record: LogfamiRecord = _record("S", body)
	record.time_unix_ms = time_unix_ms
	return record


func _record(scope: String, body: String) -> LogfamiRecord:
	return LogfamiRecord.create(LogfamiLevel.Severity.INFO, scope, body)
