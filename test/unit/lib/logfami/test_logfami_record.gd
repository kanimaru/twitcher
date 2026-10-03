extends TwitcherTest
## Unit tests for [LogfamiRecord].

## The dictionary contract Twitcher hands to its log handlers. Logfami has to
## read it without knowing Twitcher, so both sides are pinned to one fixture.
const CONTRACT_FIXTURE: String = "logger/record_contract.json"


func test_create_stamps_clock_level_and_thread() -> void:
	var clock: LogfamiFixedClock = LogfamiFixedClock.new(1_759_140_000_123, 42)
	var record: LogfamiRecord = LogfamiRecord.create(
			LogfamiLevel.Severity.WARN, "Shop", "Low stock", { "item": "sword" }, clock)

	assert_eq(record.time_unix_ms, 1_759_140_000_123)
	assert_eq(record.ticks_msec, 42)
	assert_eq(record.severity_number, LogfamiLevel.Severity.WARN)
	assert_eq(record.severity_text, "WARN")
	assert_eq(record.scope, "Shop")
	assert_eq(record.body, "Low stock")
	assert_eq(record.attributes, { "item": "sword" })
	assert_eq(record.thread_id, OS.get_thread_caller_id())


func test_keys_lists_every_to_dict_key_in_order() -> void:
	var record: LogfamiRecord = LogfamiRecord.create(LogfamiLevel.Severity.INFO, "Scope", "body")
	assert_eq(PackedStringArray(record.to_dict().keys()), LogfamiRecord.KEYS)


func test_create_copies_the_attributes() -> void:
	var attributes: Dictionary = { "nested": { "count": 1 } }
	var record: LogfamiRecord = LogfamiRecord.create(
			LogfamiLevel.Severity.INFO, "Scope", "body", attributes)
	attributes["nested"]["count"] = 2
	assert_eq(record.attributes["nested"]["count"], 1)


func test_dict_round_trip() -> void:
	var clock: LogfamiFixedClock = LogfamiFixedClock.new(5, 6)
	var record: LogfamiRecord = LogfamiRecord.create(
			LogfamiLevel.Severity.ERROR, "Scope", "body", { "key": [1, 2] }, clock)

	var restored: LogfamiRecord = LogfamiRecord.from_dict(record.to_dict())

	assert_eq(restored.to_dict(), record.to_dict())


func test_from_dict_fills_missing_keys_with_defaults() -> void:
	var record: LogfamiRecord = LogfamiRecord.from_dict({ "body": "only a body" })

	assert_eq(record.body, "only a body")
	assert_eq(record.severity_number, LogfamiLevel.Severity.INFO)
	assert_eq(record.severity_text, "INFO")
	assert_eq(record.scope, "")
	assert_eq(record.attributes, {})


func test_from_dict_derives_missing_severity_text() -> void:
	var record: LogfamiRecord = LogfamiRecord.from_dict({ "severity_number": 18 })
	assert_eq(record.severity_text, "ERROR")


func test_from_dict_ignores_attributes_that_are_not_a_dictionary() -> void:
	var record: LogfamiRecord = LogfamiRecord.from_dict({ "attributes": "broken" })
	assert_eq(record.attributes, {})


func test_reads_every_key_of_the_shared_record_contract() -> void:
	var contract: Dictionary = fixture_json(CONTRACT_FIXTURE)
	var keys: Dictionary = LogfamiRecord.new().to_dict()
	for key: String in contract:
		assert_true(keys.has(key), "Logfami must understand '%s'" % key)


func test_reads_a_twitcher_record() -> void:
	var source: Dictionary = TwitchLogRecord.create(
			LogfamiLevel.Severity.WARN, "TwitchAuth", "expired", { "instance": "bot" })

	var record: LogfamiRecord = LogfamiRecord.from_dict(source)

	assert_eq(record.severity_number, LogfamiLevel.Severity.WARN)
	assert_eq(record.scope, "TwitchAuth")
	assert_eq(record.body, "expired")
	assert_eq(record.attributes, { "instance": "bot" })
	assert_false(record.attributes.is_read_only(), "the copy must be writable for processors")


func test_copy_is_deep() -> void:
	var record: LogfamiRecord = LogfamiRecord.create(
			LogfamiLevel.Severity.INFO, "Scope", "body", { "nested": { "count": 1 } })

	var copied: LogfamiRecord = record.copy()
	copied.body = "changed"
	copied.attributes["nested"]["count"] = 2

	assert_eq(record.body, "body")
	assert_eq(record.attributes["nested"]["count"], 1)
