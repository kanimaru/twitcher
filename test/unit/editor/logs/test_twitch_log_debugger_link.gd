extends TwitcherTest
## Unit tests for [TwitchLogDebuggerLink].

var _link: TwitchLogDebuggerLink


func before_each() -> void:
	super()
	_link = TwitchLogDebuggerLink.new()


func test_stores_records_of_the_game() -> void:
	var record: Dictionary = TwitchLogRecord.create(
			LogfamiLevel.Severity.ERROR, "GameScope", "boom", { "code": 3 })

	var handled: bool = _link.capture(TwitchLogDebuggerRelay.RECORD_MESSAGE, [record])

	assert_true(handled)
	var stored: LogfamiRecord = _link.game_buffer.get_records()[0]
	assert_eq(stored.scope, "GameScope")
	assert_eq(stored.body, "boom")
	assert_eq(stored.severity_number, LogfamiLevel.Severity.ERROR)
	assert_eq(stored.attributes, { "code": 3 })


func test_ignores_other_messages() -> void:
	assert_false(_link.capture("twitcher_log:other", []))
	assert_eq(_link.game_buffer.size(), 0)


func test_malformed_record_messages_are_swallowed() -> void:
	assert_true(_link.capture(TwitchLogDebuggerRelay.RECORD_MESSAGE, []))
	assert_true(_link.capture(TwitchLogDebuggerRelay.RECORD_MESSAGE, ["text"]))
	assert_eq(_link.game_buffer.size(), 0)


func test_without_a_session_no_game_runs_and_no_mode_is_sent() -> void:
	assert_false(_link.is_game_running())
	assert_eq(_link.send_mode("Any", "info"), 0)


func test_modes_reach_only_active_sessions() -> void:
	var running: FakeSession = autofree(FakeSession.new())
	var stopped: FakeSession = autofree(FakeSession.new())
	stopped.active = false
	_link.add_session(1, running)
	_link.add_session(2, stopped)

	assert_true(_link.is_game_running())
	assert_eq(_link.send_mode("TwitchAuth", "debug"), 1)
	assert_eq(running.sent, [[TwitchLogDebuggerRelay.SET_MODE_MESSAGE, ["TwitchAuth", "debug"]]])
	assert_eq(stopped.sent.size(), 0)


func test_a_stopped_game_is_not_running() -> void:
	var session: FakeSession = autofree(FakeSession.new())
	_link.add_session(1, session)
	session.active = false
	assert_false(_link.is_game_running())


func test_a_starting_game_clears_the_buffer_unless_told_otherwise() -> void:
	_link.game_buffer.add(LogfamiRecord.create(LogfamiLevel.Severity.INFO, "S", "old"))

	_link.clear_on_start = false
	_link.on_session_started()
	assert_eq(_link.game_buffer.size(), 1)

	_link.clear_on_start = true
	_link.on_session_started()
	assert_eq(_link.game_buffer.size(), 0)


class FakeSession extends Object:
	var active: bool = true
	var sent: Array = []

	func is_active() -> bool:
		return active

	func send_message(message: String, data: Array) -> void:
		sent.append([message, data])
