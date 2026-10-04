extends TwitcherTest
## Unit tests for [LogfamiRecordFilter].

var _filter: LogfamiRecordFilter


func before_each() -> void:
	super()
	_filter = LogfamiRecordFilter.new()


func test_an_empty_filter_passes_every_record() -> void:
	assert_true(_filter.matches(_record(LogfamiLevel.Severity.TRACE, "Any", "text")))


func test_min_level_drops_lower_severities(params: Array = use_parameters([
	[LogfamiLevel.Severity.DEBUG, false],
	[LogfamiLevel.Severity.INFO, true],
	[LogfamiLevel.Severity.WARN, true],
	[LogfamiLevel.Severity.ERROR, true],
])) -> void:
	_filter.min_level = LogfamiLevel.Severity.INFO
	assert_eq(_filter.matches(_record(params[0], "Scope", "text")), params[1])


func test_muted_scopes_never_pass() -> void:
	_filter.mute("Noisy")
	assert_false(_filter.matches(_record(LogfamiLevel.Severity.ERROR, "Noisy", "text")))
	assert_true(_filter.matches(_record(LogfamiLevel.Severity.ERROR, "Quiet", "text")))


func test_mute_is_idempotent_and_unmute_restores() -> void:
	_filter.mute("Noisy")
	_filter.mute("Noisy")
	assert_eq(_filter.muted_scopes, PackedStringArray(["Noisy"]))

	_filter.unmute("Noisy")
	_filter.unmute("Noisy")
	assert_false(_filter.is_muted("Noisy"))


func test_set_muted_mirrors_mute_and_unmute() -> void:
	_filter.set_muted("Scope", true)
	assert_true(_filter.is_muted("Scope"))
	_filter.set_muted("Scope", false)
	assert_false(_filter.is_muted("Scope"))


func test_query_matches_the_body_case_insensitive() -> void:
	_filter.query = "TOKEN"
	assert_true(_filter.matches(_record(LogfamiLevel.Severity.INFO, "Auth", "Token refreshed")))
	assert_false(_filter.matches(_record(LogfamiLevel.Severity.INFO, "Auth", "Connected")))


func test_query_matches_scope_and_attributes() -> void:
	var record: LogfamiRecord = _record(
			LogfamiLevel.Severity.INFO, "TwitchIRC", "joined", { "channel": "kani" })

	_filter.query = "twitchirc"
	assert_true(_filter.matches(record), "scope")
	_filter.query = "channel=kani"
	assert_true(_filter.matches(record), "attribute")
	_filter.query = "other"
	assert_false(_filter.matches(record), "no match")


func test_every_term_has_to_occur() -> void:
	var record: LogfamiRecord = _record(LogfamiLevel.Severity.INFO, "Auth", "Token refreshed")

	_filter.query = "token refreshed"
	assert_true(_filter.matches(record))
	_filter.query = "token revoked"
	assert_false(_filter.matches(record))


func test_terms_with_a_leading_dash_must_not_occur() -> void:
	var record: LogfamiRecord = _record(LogfamiLevel.Severity.INFO, "Auth", "Token refreshed")

	_filter.query = "token -refreshed"
	assert_false(_filter.matches(record))
	_filter.query = "token -revoked"
	assert_true(_filter.matches(record))


func test_a_lone_dash_is_an_ordinary_term() -> void:
	_filter.query = "-"
	assert_true(_filter.matches(_record(LogfamiLevel.Severity.INFO, "S", "a - b")))
	assert_false(_filter.matches(_record(LogfamiLevel.Severity.INFO, "S", "ab")))


func test_extra_whitespace_in_the_query_is_ignored() -> void:
	_filter.query = "  token   "
	assert_true(_filter.matches(_record(LogfamiLevel.Severity.INFO, "S", "token")))


func test_all_conditions_have_to_hold() -> void:
	_filter.min_level = LogfamiLevel.Severity.WARN
	_filter.query = "token"
	_filter.mute("Muted")

	assert_true(_filter.matches(_record(LogfamiLevel.Severity.WARN, "Auth", "token")))
	assert_false(_filter.matches(_record(LogfamiLevel.Severity.INFO, "Auth", "token")), "level")
	assert_false(_filter.matches(_record(LogfamiLevel.Severity.WARN, "Muted", "token")), "scope")
	assert_false(_filter.matches(_record(LogfamiLevel.Severity.WARN, "Auth", "other")), "query")


func test_apply_keeps_the_order_of_the_passing_records() -> void:
	_filter.min_level = LogfamiLevel.Severity.INFO
	var first: LogfamiRecord = _record(LogfamiLevel.Severity.INFO, "S", "one")
	var dropped: LogfamiRecord = _record(LogfamiLevel.Severity.DEBUG, "S", "two")
	var last: LogfamiRecord = _record(LogfamiLevel.Severity.ERROR, "S", "three")

	var passed: Array[LogfamiRecord] = _filter.apply([first, dropped, last])

	assert_eq(passed.size(), 2)
	assert_same(passed[0], first)
	assert_same(passed[1], last)


func _record(level: int, scope: String, body: String,
		attributes: Dictionary = {}) -> LogfamiRecord:
	return LogfamiRecord.create(level, scope, body, attributes)
