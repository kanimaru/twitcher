extends TwitcherTest
## Unit tests for [LogfamiEscaper].

var control_params: Array = [
	["plain text", "plain text"],
	["", ""],
	["line\nbreak", "line\\nbreak"],
	["carriage\rreturn", "carriage\\rreturn"],
	["tab\there", "tab\\there"],
	["bell" + char(7), "bell\\u0007"],
	["delete" + char(0x7f), "delete\\u007f"],
	["separator" + char(0x2028), "separator\\u2028"],
	["unicode ✓ 日本語", "unicode ✓ 日本語"],
	["back\\slash", "back\\slash"],
]

var quoted_params: Array = [
	["plain", "plain"],
	["say \"hi\"", "say \\\"hi\\\""],
	["back\\slash", "back\\\\slash"],
	["new\nline", "new\\nline"],
]


func test_escape_control(params: Array = use_parameters(control_params)) -> void:
	var text: String = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiEscaper.escape_control(text), expected)


func test_escape_quoted(params: Array = use_parameters(quoted_params)) -> void:
	var text: String = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiEscaper.escape_quoted(text), expected)


func test_escaped_text_never_contains_a_line_break() -> void:
	var text: String = ""
	for code: int in range(0, 0x80):
		text += char(code)
	var escaped: String = LogfamiEscaper.escape_control(text)
	assert_false(escaped.contains("\n"))
	assert_false(escaped.contains("\r"))


func test_quote_if_needed(params: Array = use_parameters([
	["plain", "plain"],
	["", "\"\""],
	["4.7-stable (official)", "\"4.7-stable (official)\""],
	["a=b", "\"a=b\""],
	["say \"hi\"", "\"say \\\"hi\\\"\""],
	["日本語", "日本語"],
])) -> void:
	var value: String = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiEscaper.quote_if_needed(value), expected)
