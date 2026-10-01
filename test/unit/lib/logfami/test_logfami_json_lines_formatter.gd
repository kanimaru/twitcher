extends TwitcherTest
## Unit tests for [LogfamiJsonLinesFormatter].

const GoldenRecords: GDScript = preload("res://test/fixtures/logfami/golden_records.gd")


func test_matches_the_golden_file() -> void:
	var actual: PackedStringArray = GoldenRecords.render(LogfamiJsonLinesFormatter.new())
	var expected: PackedStringArray = GoldenLines.read("logfami/expected.jsonl")
	assert_eq(GoldenLines.first_difference(actual, expected), "")


func test_every_line_is_valid_json() -> void:
	for line: String in GoldenRecords.render(LogfamiJsonLinesFormatter.new()):
		assert_false(line.contains("\n"), line)
		assert_typeof(JSON.parse_string(line), TYPE_DICTIONARY, line)


func test_body_round_trips_through_json() -> void:
	var formatter: LogfamiJsonLinesFormatter = LogfamiJsonLinesFormatter.new()
	var record: LogfamiRecord = GoldenRecords.records()[1]

	var parsed: Dictionary = JSON.parse_string(formatter.format(record, LogfamiResource.new()))

	assert_eq(parsed["body"], record.body, "injected line breaks survive as data")


func test_include_resource_adds_it_to_every_line() -> void:
	var formatter: LogfamiJsonLinesFormatter = LogfamiJsonLinesFormatter.new()
	formatter.include_resource = true
	var record: LogfamiRecord = GoldenRecords.records()[0]

	var parsed: Dictionary = JSON.parse_string(formatter.format(record, GoldenRecords.resource()))

	assert_eq(parsed["resource"]["service.name"], "Golden")


func test_resource_is_left_out_by_default() -> void:
	var record: LogfamiRecord = GoldenRecords.records()[0]
	var line: String = LogfamiJsonLinesFormatter.new().format(record, GoldenRecords.resource())
	assert_false((JSON.parse_string(line) as Dictionary).has("resource"))


func test_file_extension() -> void:
	assert_eq(LogfamiJsonLinesFormatter.new().file_extension(), "jsonl")
