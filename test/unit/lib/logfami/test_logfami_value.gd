extends TwitcherTest
## Unit tests for [LogfamiValue].

var text_params: Array = [
	["plain", "plain"],
	[42, "42"],
	[2.5, "2.5"],
	[true, "true"],
	[null, "<null>"],
	[{ "b": 2, "a": 1 }, "{\"a\":1,\"b\":2}"],
	[[3, { "z": 1, "y": [2] }], "[3,{\"y\":[2],\"z\":1}]"],
	[{}, "{}"],
]


func test_to_text(params: Array = use_parameters(text_params)) -> void:
	var value: Variant = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiValue.to_text(value), expected)


func test_sorted_is_a_deep_copy() -> void:
	var source: Dictionary = { "b": { "d": 1, "c": 2 }, "a": [{ "f": 1, "e": 2 }] }

	var sorted: Dictionary = LogfamiValue.sorted(source)
	sorted["b"]["d"] = 99

	assert_eq(sorted.keys(), ["a", "b"])
	assert_eq((sorted["b"] as Dictionary).keys(), ["c", "d"])
	assert_eq((sorted["a"][0] as Dictionary).keys(), ["e", "f"])
	assert_eq(source["b"]["d"], 1, "the source must stay untouched")


func test_every_formatter_renders_a_container_the_same_way() -> void:
	var record: LogfamiRecord = LogfamiRecord.create(LogfamiLevel.Severity.INFO, "S", "b",
			{ "nested": { "b": 2, "a": 1 } }, LogfamiFixedClock.new())
	var resource: LogfamiResource = LogfamiResource.new()
	var expected: String = "{\"a\":1,\"b\":2}"
	var quoted: String = "nested=\"%s\"" % expected.replace("\"", "\\\"")

	assert_string_contains(LogfamiJsonLinesFormatter.new().format(record, resource),
			"\"nested\":%s" % expected)
	assert_string_contains(LogfamiTextFormatter.new().format(record, resource), quoted)
	assert_string_contains(LogfamiLogfmtFormatter.new().format(record, resource), quoted)
