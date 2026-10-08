extends TwitcherTest
## Unit tests for [TwitchLogDebuggerRelay].

const CONTEXT: String = "GutRelayProbe"

var _relay: TwitchLogDebuggerRelay
var _sent: Array[Array] = []


func before_each() -> void:
	super()
	_sent = []
	_relay = TwitchLogDebuggerRelay.new()
	_relay.sender = _collect


func after_each() -> void:
	_relay.stop()
	var key: String = TwitchLogContexts.setting_key(CONTEXT)
	if ProjectSettings.has_setting(key):
		ProjectSettings.clear(key)
	super()


func test_relay_sends_the_record_as_a_record_message() -> void:
	var record: Dictionary = TwitchLogRecord.create(
			LogfamiLevel.Severity.WARN, "Scope", "careful", { "id": 7 })

	_relay.relay(record)

	assert_eq(_sent.size(), 1)
	assert_eq(_sent[0][0], TwitchLogDebuggerRelay.RECORD_MESSAGE)
	var sent_record: Dictionary = _sent[0][1][0]
	assert_eq(sent_record[TwitchLogRecord.BODY], "careful")
	assert_eq(sent_record[TwitchLogRecord.ATTRIBUTES], { "id": 7 })


func test_the_sent_record_is_writable() -> void:
	_relay.relay(TwitchLogRecord.create(LogfamiLevel.Severity.INFO, "S", "b"))
	var sent_record: Dictionary = _sent[0][1][0]
	assert_false(sent_record.is_read_only())


func test_records_from_other_threads_wait_for_the_main_thread() -> void:
	var thread: Thread = Thread.new()
	thread.start(_relay.relay.bind(
			TwitchLogRecord.create(LogfamiLevel.Severity.INFO, "S", "from thread")))
	thread.wait_to_finish()
	assert_eq(_sent.size(), 0, "nothing sent from the foreign thread")

	_relay.flush()

	assert_eq(_sent.size(), 1)


func test_flush_sends_every_record_once() -> void:
	_relay.relay(TwitchLogRecord.create(LogfamiLevel.Severity.INFO, "S", "one"))
	_relay.flush()
	_relay.flush()
	assert_eq(_sent.size(), 1)


func test_set_mode_command_switches_the_context() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT)

	var handled: bool = _relay.handle_command(
			TwitchLogDebuggerRelay.SET_MODE_COMMAND, [CONTEXT, "debug"])

	assert_true(handled)
	assert_eq(TwitchLogContexts.mode_of(logger), "debug")


func test_unknown_or_incomplete_commands_are_not_handled() -> void:
	assert_false(_relay.handle_command("explode", [CONTEXT, "debug"]))
	assert_false(_relay.handle_command(TwitchLogDebuggerRelay.SET_MODE_COMMAND, [CONTEXT]))
	assert_eq(TwitchLogContexts.override_level(CONTEXT), TwitchLogContexts.NO_OVERRIDE)


func test_start_and_stop_register_the_handler_and_the_capture() -> void:
	_relay.start()
	assert_true(_relay.is_running())
	assert_true(TwitchLoggerManager.has_handler(_relay.relay))
	assert_true(EngineDebugger.has_capture(TwitchLogDebuggerRelay.CAPTURE))

	_relay.stop()
	assert_false(_relay.is_running())
	assert_false(TwitchLoggerManager.has_handler(_relay.relay))
	assert_false(EngineDebugger.has_capture(TwitchLogDebuggerRelay.CAPTURE))


func test_a_started_relay_receives_what_the_context_mode_allows() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT)
	_relay.start()

	logger.i("silent")
	assert_eq(_sent.size(), 0)

	TwitchLogContexts.set_mode(CONTEXT, "info", false)
	logger.i("audible")
	assert_eq(_sent.size(), 1)


func test_install_does_nothing_without_an_attached_editor() -> void:
	TwitchLogDebuggerRelay.install_if_attached()
	assert_false(TwitchLoggerManager.has_handler(TwitchLogDebuggerRelay.new().relay))
	assert_false(EngineDebugger.has_capture(TwitchLogDebuggerRelay.CAPTURE))


func _collect(message: String, data: Array) -> void:
	_sent.append([message, data])
