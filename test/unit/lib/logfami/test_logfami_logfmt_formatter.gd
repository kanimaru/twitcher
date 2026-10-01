extends TwitcherTest
## Unit tests for [LogfamiLogfmtFormatter].

const GoldenRecords: GDScript = preload("res://test/fixtures/logfami/golden_records.gd")

var quote_params: Array = [
	["plain", "plain"],
	["", "\"\""],
	["two words", "\"two words\""],
	["a=b", "\"a=b\""],
	["say \"hi\"", "\"say \\\"hi\\\"\""],
	["new\nline", "\"new\\nline\""],
	["back\\slash", "back\\slash"],
	["日本語", "日本語"],
]

var key_params: Array = [
	["service.name", "service.name"],
	["with space", "with_space"],
	["a=b", "a_b"],
	["", "_"],
]


func test_matches_the_golden_file() -> void:
	var actual: PackedStringArray = GoldenRecords.render(LogfamiLogfmtFormatter.new())
	var expected: PackedStringArray = GoldenLines.read("logfami/expected.logfmt")
	assert_eq(GoldenLines.first_difference(actual, expected), "")


func test_every_record_is_one_line() -> void:
	for line: String in GoldenRecords.render(LogfamiLogfmtFormatter.new()):
		assert_false(line.contains("\n"), line)


func test_quote(params: Array = use_parameters(quote_params)) -> void:
	var value: String = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiLogfmtFormatter.quote(value), expected)


func test_clean_key(params: Array = use_parameters(key_params)) -> void:
	var key: String = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiLogfmtFormatter.clean_key(key), expected)
