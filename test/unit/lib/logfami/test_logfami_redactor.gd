extends TwitcherTest
## Unit tests for [LogfamiRedactor].
##
## The default rules decide whether a log file people send in for support leaks
## credentials, so they are pinned case by case: what must be masked, and
## everyday messages that must survive untouched.

## [code][input, expected][/code] for the default rules.
var default_params: Array = [
	# Authorization headers.
	["Authorization: Bearer 0123456789abcdefghijklmnopqrst",
			"Authorization: Bearer [REDACTED]"],
	["header OAuth abc123def456", "header OAuth [REDACTED]"],
	# Twitch IRC password.
	["PASS oauth:abcdef0123456789", "PASS oauth:[REDACTED]"],
	# key=value, query strings and JSON.
	["access_token=abc123&scope=chat", "access_token=[REDACTED]&scope=chat"],
	["#access_token=abc123&token_type=bearer", "#access_token=[REDACTED]&token_type=bearer"],
	["refresh_token: xyz789", "refresh_token: [REDACTED]"],
	["{\"access_token\":\"abc\",\"expires_in\":3600}",
			"{\"access_token\":\"[REDACTED]\",\"expires_in\":3600}"],
	["{\"client_secret\": \"s3cr3t\"}", "{\"client_secret\": \"[REDACTED]\"}"],
	["password=hunter2", "password=[REDACTED]"],
	["token=abc", "token=[REDACTED]"],
	# OAuth authorization code in a redirect URL.
	["GET /callback?code=abc123&state=xyz", "GET /callback?code=[REDACTED]&state=xyz"],
	# Everyday messages stay as they are.
	["Token got authorized", "Token got authorized"],
	["OAuth settings are invalid", "OAuth settings are invalid"],
	["Bearer token missing", "Bearer token missing"],
	["Couldn't get frame delays, return code is: 1",
			"Couldn't get frame delays, return code is: 1"],
	["Message couldn't be sent cause of [msg_rejected]: blocked",
			"Message couldn't be sent cause of [msg_rejected]: blocked"],
	["https://api.twitch.tv/helix/users?login=kani_dev",
			"https://api.twitch.tv/helix/users?login=kani_dev"],
]


func test_default_rules(params: Array = use_parameters(default_params)) -> void:
	var text: String = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiRedactor.with_defaults().redact(text), expected)


func test_generic_secrets_are_opt_in() -> void:
	var text: String = "token is 0123456789abcdefghijklmnopqrst"
	assert_eq(LogfamiRedactor.with_defaults().redact(text), text)
	assert_eq(LogfamiRedactor.with_defaults(true).redact(text), "token is [REDACTED]")


func test_generic_secrets_need_letters_and_digits() -> void:
	var redactor: LogfamiRedactor = LogfamiRedactor.with_defaults(true)
	var only_letters: String = "abcdefghijklmnopqrstuvwxyzabcdefgh"
	assert_eq(redactor.redact(only_letters), only_letters)


func test_sensitive_keys_mask_whole_values() -> void:
	var redactor: LogfamiRedactor = LogfamiRedactor.with_defaults()
	assert_true(redactor.is_sensitive_key("refresh_token"))
	assert_true(redactor.is_sensitive_key("Client-Secret"))
	assert_true(redactor.is_sensitive_key("AUTHORIZATION"))
	assert_false(redactor.is_sensitive_key("expires_in"))


func test_process_redacts_body_and_attributes() -> void:
	var record: LogfamiRecord = LogfamiRecord.create(LogfamiLevel.Severity.INFO, "Auth",
			"PASS oauth:abc123", {
				"access_token": "abc",
				"expires_in": 3600,
				"url": "/cb?code=xyz",
				"nested": { "Password": "hunter2", "list": ["token=abc", 1] },
			})

	var processed: LogfamiRecord = LogfamiRedactor.with_defaults().process(record)

	assert_eq(processed.body, "PASS oauth:[REDACTED]")
	assert_eq(processed.attributes, {
		"access_token": "[REDACTED]",
		"expires_in": 3600,
		"url": "/cb?code=[REDACTED]",
		"nested": { "Password": "[REDACTED]", "list": ["token=[REDACTED]", 1] },
	})


func test_redactor_without_rules_changes_nothing() -> void:
	var record: LogfamiRecord = LogfamiRecord.create(
			LogfamiLevel.Severity.INFO, "Auth", "token=abc", { "token": "abc" })

	var processed: LogfamiRecord = LogfamiRedactor.new().process(record)

	assert_eq(processed.body, "token=abc")
	assert_eq(processed.attributes, { "token": "abc" })


func test_rules_run_in_order() -> void:
	var redactor: LogfamiRedactor = LogfamiRedactor.new()
	redactor.add_rule(LogfamiRedactionRule.new("a_to_b", "a", "b"))
	redactor.add_rule(LogfamiRedactionRule.new("b_to_c", "b", "c"))
	assert_eq(redactor.redact("a"), "c")


func test_secrets_never_reach_the_sink() -> void:
	var sink: LogfamiMemorySink = LogfamiMemorySink.new()
	var pipeline: LogfamiPipeline = LogfamiPipeline.new(LogfamiTextFormatter.new(), sink)
	pipeline.add_processor(LogfamiRedactor.with_defaults())
	var record: LogfamiRecord = LogfamiRecord.create(LogfamiLevel.Severity.ERROR, "Http",
			"problems with result\n> body: {\"refresh_token\":\"r3fr3sh\"}", {},
			LogfamiFixedClock.new())

	pipeline.emit(record, LogfamiResource.new())

	assert_eq(sink.lines, [
		"1970-01-01T00:00:00.000Z ERROR [Http] problems with result\\n> body: "
				+ "{\"refresh_token\":\"[REDACTED]\"}",
	] as Array[String])
	assert_false(sink.lines[0].contains("r3fr3sh"))
