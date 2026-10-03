extends TwitcherTest
## Unit tests for [TwitchLogRecord].
##
## The record is the contract between Twitcher and every external log handler,
## so its keys and value types are pinned against a fixture. A change that
## breaks handlers shows up here first.

const CONTRACT_FIXTURE: String = "logger/record_contract.json"


func test_record_matches_the_contract_fixture() -> void:
	var contract: Dictionary = fixture_json(CONTRACT_FIXTURE)
	var record: Dictionary = TwitchLogRecord.create(
			LogfamiLevel.Severity.INFO, "Scope", "body", { "key": "value" })

	var expected_keys: Array = contract.keys()
	expected_keys.sort()
	var actual_keys: Array = record.keys()
	actual_keys.sort()
	assert_eq(actual_keys, expected_keys, "record keys must match the contract")

	for key: String in contract:
		assert_eq(type_string(typeof(record.get(key))), contract[key], "type of '%s'" % key)


func test_keys_constant_lists_every_record_key() -> void:
	var record: Dictionary = TwitchLogRecord.create(LogfamiLevel.Severity.INFO, "Scope", "body")
	var expected: Array = Array(TwitchLogRecord.KEYS)
	expected.sort()
	var actual: Array = record.keys()
	actual.sort()
	assert_eq(actual, expected)


func test_record_carries_the_given_values() -> void:
	var record: Dictionary = TwitchLogRecord.create(
			LogfamiLevel.Severity.WARN, "TwitchAuth", "Token expired", { "expires_in": 0 })

	assert_eq(record[TwitchLogRecord.SEVERITY_NUMBER], LogfamiLevel.Severity.WARN)
	assert_eq(record[TwitchLogRecord.SEVERITY_TEXT], "WARN")
	assert_eq(record[TwitchLogRecord.SCOPE], "TwitchAuth")
	assert_eq(record[TwitchLogRecord.BODY], "Token expired")
	assert_eq(record[TwitchLogRecord.ATTRIBUTES], { "expires_in": 0 })
	assert_eq(record[TwitchLogRecord.THREAD_ID], OS.get_thread_caller_id())


func test_timestamps_are_current() -> void:
	var before_ms: int = int(Time.get_unix_time_from_system() * 1000.0)
	var record: Dictionary = TwitchLogRecord.create(LogfamiLevel.Severity.INFO, "Scope", "body")
	var after_ms: int = int(Time.get_unix_time_from_system() * 1000.0)

	assert_between(record[TwitchLogRecord.TIME_UNIX_MS], before_ms, after_ms)
	assert_almost_eq(record[TwitchLogRecord.TICKS_MSEC], Time.get_ticks_msec(), 1000)


func test_record_and_attributes_are_read_only() -> void:
	var record: Dictionary = TwitchLogRecord.create(
			LogfamiLevel.Severity.INFO, "Scope", "body", { "key": "value" })

	assert_true(record.is_read_only(), "handlers must not be able to change a shared record")
	var attributes: Dictionary = record[TwitchLogRecord.ATTRIBUTES]
	assert_true(attributes.is_read_only(), "nor its attributes")


func test_attributes_are_copied() -> void:
	var attributes: Dictionary = { "nested": { "count": 1 } }
	var record: Dictionary = TwitchLogRecord.create(
			LogfamiLevel.Severity.INFO, "Scope", "body", attributes)

	attributes["added"] = true
	attributes["nested"]["count"] = 2

	var recorded: Dictionary = record[TwitchLogRecord.ATTRIBUTES]
	assert_false(recorded.has("added"), "later changes must not leak into the record")
	assert_eq(recorded["nested"]["count"], 1, "the copy must be deep")


func test_passed_attributes_stay_writable() -> void:
	var attributes: Dictionary = { "key": "value" }
	TwitchLogRecord.create(LogfamiLevel.Severity.INFO, "Scope", "body", attributes)
	assert_false(attributes.is_read_only(), "the caller's dictionary must not be locked")
