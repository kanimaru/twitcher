extends TwitcherTest
## Unit tests for [LogfamiTextFormatter].

const GoldenRecords: GDScript = preload("res://test/fixtures/logfami/golden_records.gd")


func test_matches_the_golden_file() -> void:
	var actual: PackedStringArray = GoldenRecords.render(LogfamiTextFormatter.new())
	var expected: PackedStringArray = GoldenLines.read("logfami/expected.log")
	assert_eq(GoldenLines.first_difference(actual, expected), "")


func test_every_record_is_one_line() -> void:
	for line: String in GoldenRecords.render(LogfamiTextFormatter.new()):
		assert_false(line.contains("\n"), line)


func test_instance_attribute_can_be_disabled() -> void:
	var formatter: LogfamiTextFormatter = LogfamiTextFormatter.new()
	formatter.instance_attribute = ""
	var record: LogfamiRecord = LogfamiRecord.create(LogfamiLevel.Severity.INFO, "Auth", "hi",
			{ "instance": "main" }, LogfamiFixedClock.new())

	assert_eq(formatter.format(record, LogfamiResource.new()),
			"1970-01-01T00:00:00.000Z INFO  [Auth] hi {instance=main}")


func test_unknown_severity_shows_its_number() -> void:
	var record: LogfamiRecord = LogfamiRecord.create(42, "S", "odd", {}, LogfamiFixedClock.new())
	assert_eq(LogfamiTextFormatter.new().format(record, LogfamiResource.new()),
			"1970-01-01T00:00:00.000Z 42    [S] odd")


func test_header_without_resource_attributes() -> void:
	var header: PackedStringArray = LogfamiTextFormatter.new().header(LogfamiResource.new(), 0)
	assert_eq(header, PackedStringArray(["# session.start 1970-01-01T00:00:00.000Z"]))


func test_file_extension() -> void:
	assert_eq(LogfamiTextFormatter.new().file_extension(), "log")
