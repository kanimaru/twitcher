extends TwitcherTest
## Unit tests for [LogfamiRedactionRule].


func test_replaces_every_match() -> void:
	var rule: LogfamiRedactionRule = LogfamiRedactionRule.new("digits", "\\d+", "#")
	assert_eq(rule.apply("a1 b22 c333"), "a# b# c#")


func test_replacement_can_keep_capture_groups() -> void:
	var rule: LogfamiRedactionRule = LogfamiRedactionRule.new(
			"api_key", "(api_key=)\\S+", "$1[REDACTED]")
	assert_eq(rule.apply("url?api_key=abc&x=1"), "url?api_key=[REDACTED]")


func test_valid_rule() -> void:
	var rule: LogfamiRedactionRule = LogfamiRedactionRule.new("ok", "a+", "b")
	assert_true(rule.is_valid())
	assert_eq(rule.name, "ok")
