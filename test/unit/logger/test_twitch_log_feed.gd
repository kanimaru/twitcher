extends TwitcherTest
## Unit tests for [TwitchLogFeed].

const CONTEXT: String = "GutFeedProbe"

var _feed: TwitchLogFeed


func before_each() -> void:
	super()
	_feed = TwitchLogFeed.new()


func after_each() -> void:
	_feed.stop()
	super()


func test_handle_stores_the_record() -> void:
	var record: Dictionary = TwitchLogRecord.create(
			LogfamiLevel.Severity.WARN, "Scope", "careful", { "id": 7 })

	_feed.handle(record)

	var stored: LogfamiRecord = _feed.buffer.get_records()[0]
	assert_eq(stored.scope, "Scope")
	assert_eq(stored.body, "careful")
	assert_eq(stored.severity_number, LogfamiLevel.Severity.WARN)
	assert_eq(stored.attributes, { "id": 7 })


func test_the_buffer_respects_the_capacity() -> void:
	var small: TwitchLogFeed = TwitchLogFeed.new(1)
	small.handle(TwitchLogRecord.create(LogfamiLevel.Severity.INFO, "S", "one"))
	small.handle(TwitchLogRecord.create(LogfamiLevel.Severity.INFO, "S", "two"))

	assert_eq(small.buffer.size(), 1)
	assert_eq(small.buffer.get_records()[0].body, "two")


func test_start_and_stop_register_the_handler() -> void:
	assert_false(_feed.is_running())

	_feed.start()
	assert_true(_feed.is_running())
	assert_true(TwitchLoggerManager.has_handler(_feed.handle))

	_feed.stop()
	assert_false(_feed.is_running())
	assert_false(TwitchLoggerManager.has_handler(_feed.handle))


func test_starting_twice_registers_once() -> void:
	var count_before: int = TwitchLoggerManager.handler_count()

	_feed.start()
	_feed.start()

	assert_eq(TwitchLoggerManager.handler_count(), count_before + 1)


func test_stopping_a_stopped_feed_does_nothing() -> void:
	var count_before: int = TwitchLoggerManager.handler_count()
	_feed.stop()
	assert_eq(TwitchLoggerManager.handler_count(), count_before)


func test_receives_what_the_context_mode_allows() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT)
	_feed.start()

	logger.i("while off")
	assert_eq(_feed.buffer.size(), 0, "off")

	TwitchLogContexts.set_mode(CONTEXT, "info", false)
	logger.i("info is on")
	logger.d("debug is not")
	assert_eq(_feed.buffer.size(), 1, "info")

	TwitchLogContexts.set_mode(CONTEXT, "debug", false)
	logger.d("debug is on")
	assert_eq(_feed.buffer.size(), 2, "debug")
	assert_eq(_feed.buffer.get_records()[1].body, "debug is on")


func test_receives_nothing_after_stop() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true)
	_feed.start()
	_feed.stop()

	logger.i("unheard")

	assert_eq(_feed.buffer.size(), 0)
