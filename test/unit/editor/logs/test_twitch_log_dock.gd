extends TwitcherTest
## Unit tests for [TwitchLogDock].

const CONTEXT: String = "GutDockProbe"
const OTHER: String = "GutDockOther"

var _dock: TwitchLogDock


func before_each() -> void:
	super()
	_dock = TwitchLogDock.new()
	_dock.filter.min_level = LogfamiLevel.Severity.DEBUG
	add_child_autofree(_dock)


func after_each() -> void:
	for context: String in [CONTEXT, OTHER]:
		var key: String = TwitchLogContexts.setting_key(context)
		if ProjectSettings.has_setting(key):
			ProjectSettings.clear(key)
	super()


func test_collects_records_while_in_the_tree() -> void:
	var feed: TwitchLogFeed = _dock.feed
	assert_true(feed.is_running())

	remove_child(_dock)

	assert_false(feed.is_running())


func test_shows_the_records_of_enabled_contexts() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true)

	logger.i("first")
	logger.w("second")
	_dock.refresh()

	assert_eq(_dock.get_line_count(), 2)


func test_creates_a_row_per_context() -> void:
	TwitchLogger.new(CONTEXT)
	TwitchLogger.new(OTHER)

	_dock.refresh()

	assert_not_null(_dock.get_row(CONTEXT))
	assert_not_null(_dock.get_row(OTHER))
	assert_null(_dock.get_row("GutDockNeverLogged"))
	var names: PackedStringArray = _dock.get_context_names()
	assert_lt(names.find(OTHER), names.find(CONTEXT), "sorted")


func test_a_row_shows_the_mode_of_its_context() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true, true)

	_dock.refresh()
	assert_eq(_dock.get_row(CONTEXT).get_mode(), "debug")

	logger.debug = false
	_dock.refresh()
	assert_eq(_dock.get_row(CONTEXT).get_mode(), "info", "follows changes made elsewhere")


func test_picking_a_mode_switches_the_context() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT)
	_dock.refresh()

	_dock.get_row(CONTEXT).pick_mode("info")
	logger.i("now audible")
	_dock.refresh()

	assert_true(logger.enabled)
	assert_eq(_dock.get_line_count(), 1)

	_dock.get_row(CONTEXT).pick_mode("off")
	logger.i("silent again")
	_dock.refresh()
	assert_eq(_dock.get_line_count(), 1)


func test_hiding_a_context_filters_its_records_but_keeps_logging() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true)
	var other: TwitchLogger = TwitchLogger.new(OTHER, true)
	logger.i("hide me")
	other.i("keep me")
	_dock.refresh()

	_dock.get_row(CONTEXT).toggle_shown(false)
	_dock.refresh()

	assert_eq(_dock.get_line_count(), 1)
	assert_true(logger.enabled, "the mode stays")
	assert_eq(_dock.feed.buffer.size(), 2, "the buffer keeps the record")

	_dock.get_row(CONTEXT).toggle_shown(true)
	_dock.refresh()
	assert_eq(_dock.get_line_count(), 2)


func test_set_context_visible_updates_filter_and_row() -> void:
	TwitchLogger.new(CONTEXT)
	_dock.refresh()

	_dock.set_context_visible(CONTEXT, false)

	assert_true(_dock.filter.is_muted(CONTEXT))
	assert_false(_dock.get_row(CONTEXT).is_shown())


func test_a_row_created_later_respects_a_hidden_context() -> void:
	_dock.set_context_visible(CONTEXT, false)

	TwitchLogger.new(CONTEXT)
	_dock.refresh()

	assert_false(_dock.get_row(CONTEXT).is_shown())


func test_min_level_filters_the_output() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true, true)
	logger.d("debug")
	logger.i("info")
	logger.e("error")
	_dock.refresh()
	assert_eq(_dock.get_line_count(), 3)

	_dock.set_min_level(LogfamiLevel.Severity.WARN)
	_dock.refresh()

	assert_eq(_dock.get_line_count(), 1)


func test_query_filters_the_output() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true)
	logger.i("token refreshed")
	logger.i("connected")

	_dock.set_query("token")
	_dock.refresh()

	assert_eq(_dock.get_line_count(), 1)


func test_markup_in_messages_is_shown_literally() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true)
	logger.i("[b]not bold[/b]")
	_dock.refresh()

	assert_string_contains(_dock._output.get_parsed_text(), "[b]not bold[/b]")


func test_clear_empties_the_output() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true)
	logger.i("something")
	_dock.refresh()

	_dock.clear()
	_dock.refresh()

	assert_eq(_dock.get_line_count(), 0)
	assert_eq(_dock.feed.buffer.size(), 0)


func test_set_all_modes_switches_every_known_context() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT)
	var other: TwitchLogger = TwitchLogger.new(OTHER)
	_dock.refresh()

	_dock.set_all_modes("debug")

	assert_eq(TwitchLogContexts.mode_of(logger), "debug")
	assert_eq(TwitchLogContexts.mode_of(other), "debug")
	assert_eq(_dock.get_row(CONTEXT).get_mode(), "debug")

	_dock.set_all_modes("off")
	assert_false(logger.enabled)


func test_game_records_are_merged_and_tagged_by_origin() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true)
	logger.i("from the editor")
	_dock.game_buffer.add(_game_record("GutDockGame", "from the game"))
	_dock.refresh()

	assert_eq(_dock.get_line_count(), 2)
	var text: String = _dock._output.get_parsed_text()
	assert_string_contains(text, "E ")
	assert_string_contains(text, "G ")


func test_the_source_selector_limits_the_records() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true)
	logger.i("from the editor")
	_dock.game_buffer.add(_game_record("GutDockGame", "from the game"))

	_dock.set_source(TwitchLogDock.SOURCE_GAME)
	_dock.refresh()
	assert_eq(_dock.get_line_count(), 1)
	assert_string_contains(_dock._output.get_parsed_text(), "from the game")

	_dock.set_source(TwitchLogDock.SOURCE_EDITOR)
	_dock.refresh()
	assert_eq(_dock.get_line_count(), 1)
	assert_string_contains(_dock._output.get_parsed_text(), "from the editor")


func test_unknown_sources_are_ignored() -> void:
	_dock.set_source("Phone")
	_dock.game_buffer.add(_game_record("GutDockGame", "from the game"))
	_dock.refresh()
	assert_eq(_dock.get_line_count(), 1)


func test_contexts_of_the_game_get_a_row() -> void:
	_dock.game_buffer.add(_game_record("GutDockGameOnly", "hi"))

	_dock.refresh()

	assert_not_null(_dock.get_row("GutDockGameOnly"))


func test_hiding_a_context_hides_its_game_records_too() -> void:
	_dock.game_buffer.add(_game_record("GutDockGameOnly", "hi"))
	_dock.refresh()

	_dock.get_row("GutDockGameOnly").toggle_shown(false)
	_dock.refresh()

	assert_eq(_dock.get_line_count(), 0)


func test_clear_empties_the_game_records_as_well() -> void:
	_dock.game_buffer.add(_game_record("GutDockGame", "hi"))
	_dock.clear()
	assert_eq(_dock.game_buffer.size(), 0)


func test_modes_are_passed_on_to_the_running_game() -> void:
	var session: FakeSession = FakeSession.new()
	var link: TwitchLogDebuggerLink = TwitchLogDebuggerLink.new()
	link.add_session(1, session)
	_dock.debugger = link
	TwitchLogger.new(CONTEXT)
	_dock.refresh()

	_dock.get_row(CONTEXT).pick_mode("info")

	assert_eq(TwitchLogContexts.get_mode(CONTEXT), "info", "applied in the editor")
	assert_eq(session.sent, [[TwitchLogDebuggerRelay.SET_MODE_MESSAGE, [CONTEXT, "info"]]])


func test_set_all_modes_reaches_the_game_for_every_context() -> void:
	var session: FakeSession = FakeSession.new()
	var link: TwitchLogDebuggerLink = TwitchLogDebuggerLink.new()
	link.add_session(1, session)
	_dock.debugger = link
	TwitchLogger.new(CONTEXT)
	_dock.refresh()

	_dock.set_all_modes("debug")

	var contexts: Array[String] = []
	for sent: Array in session.sent:
		contexts.append(sent[1][0])
	assert_true(contexts.has(CONTEXT))


func _game_record(scope: String, body: String) -> LogfamiRecord:
	return LogfamiRecord.create(LogfamiLevel.Severity.INFO, scope, body)


class FakeSession extends Object:
	var active: bool = true
	var sent: Array = []

	func is_active() -> bool:
		return active

	func send_message(message: String, data: Array) -> void:
		sent.append([message, data])
