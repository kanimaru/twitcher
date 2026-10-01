extends TwitcherTest
## Unit tests for [TwitchLoggerManager].
##
## Every test starts with an empty handler list; [StaticStateGuard] restores the
## real one (with the console) afterwards.


class ReentrantHandler:
	extends RefCounted

	var calls: int = 0


	func handle(_record: Dictionary) -> void:
		calls += 1
		TwitchLoggerManager.dispatch(TwitchLogRecord.create(
				TwitchLogLevel.Severity.ERROR, "Nested", "logged while handling"))


class ScopeFilter:
	extends RefCounted

	func resolve(scope: String) -> int:
		if scope == "Wanted":
			return TwitchLogLevel.Severity.DEBUG
		return TwitchLogLevel.OFF


var _capture: LogCapture


func before_each() -> void:
	super()
	TwitchLoggerManager.clear_handlers()
	_capture = LogCapture.new()


func test_console_handler_is_installed_by_default() -> void:
	_guard.restore()
	var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
	assert_true(TwitchLoggerManager.has_handler(console.handle))


func test_dispatch_hands_the_record_to_the_handler() -> void:
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.INFO)
	var record: Dictionary = _record(TwitchLogLevel.Severity.INFO, "Scope", "hello")

	TwitchLoggerManager.dispatch(record)

	assert_eq(_capture.records.size(), 1)
	assert_same(_capture.last(), record, "handlers receive the record itself")


func test_min_level_filters_records() -> void:
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.WARN)

	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.INFO, "Scope", "info"))
	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.WARN, "Scope", "warn"))
	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.ERROR, "Scope", "error"))

	assert_eq(_capture.bodies(), PackedStringArray(["warn", "error"]))


func test_wants_reflects_the_handlers() -> void:
	assert_false(TwitchLoggerManager.wants("Scope", TwitchLogLevel.Severity.FATAL),
			"without handlers nothing is wanted")

	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.INFO)

	assert_true(TwitchLoggerManager.wants("Scope", TwitchLogLevel.Severity.INFO))
	assert_false(TwitchLoggerManager.wants("Scope", TwitchLogLevel.Severity.DEBUG))


func test_wants_is_true_when_any_handler_wants() -> void:
	var other: LogCapture = LogCapture.new()
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.ERROR)
	TwitchLoggerManager.add_handler(other.handle, TwitchLogLevel.Severity.DEBUG)

	assert_true(TwitchLoggerManager.wants("Scope", TwitchLogLevel.Severity.DEBUG))


func test_scoped_handler_filters_per_scope() -> void:
	var filter: ScopeFilter = ScopeFilter.new()
	TwitchLoggerManager.add_scoped_handler(_capture.handle, filter.resolve)

	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.DEBUG, "Wanted", "in"))
	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.FATAL, "Ignored", "out"))

	assert_eq(_capture.bodies(), PackedStringArray(["in"]))
	assert_true(TwitchLoggerManager.wants("Wanted", TwitchLogLevel.Severity.DEBUG))
	assert_false(TwitchLoggerManager.wants("Ignored", TwitchLogLevel.Severity.FATAL))


func test_adding_a_handler_twice_replaces_its_level() -> void:
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.ERROR)
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.DEBUG)

	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.DEBUG, "Scope", "once"))

	assert_eq(_capture.records.size(), 1, "the handler must be registered only once")


func test_remove_handler() -> void:
	TwitchLoggerManager.add_handler(_capture.handle)
	TwitchLoggerManager.remove_handler(_capture.handle)

	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.ERROR, "Scope", "gone"))

	assert_false(TwitchLoggerManager.has_handler(_capture.handle))
	assert_eq(_capture.records.size(), 0)


func test_remove_handler_keeps_the_others() -> void:
	var other: LogCapture = LogCapture.new()
	TwitchLoggerManager.add_handler(_capture.handle)
	TwitchLoggerManager.add_handler(other.handle)

	TwitchLoggerManager.remove_handler(_capture.handle)

	assert_true(TwitchLoggerManager.has_handler(other.handle))


func test_clear_handlers_removes_the_console_too() -> void:
	TwitchLoggerManager.install_console_handler()
	TwitchLoggerManager.clear_handlers()

	var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
	assert_false(TwitchLoggerManager.has_handler(console.handle))


func test_install_console_handler_is_idempotent() -> void:
	TwitchLoggerManager.install_console_handler()
	TwitchLoggerManager.install_console_handler()

	var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
	var count: int = 0
	for entry: TwitchLogHandlerEntry in TwitchLoggerManager._handlers:
		if entry.handler == console.handle:
			count += 1
	assert_eq(count, 1)


func test_records_logged_while_handling_are_dropped() -> void:
	var reentrant: ReentrantHandler = ReentrantHandler.new()
	TwitchLoggerManager.add_handler(reentrant.handle, TwitchLogLevel.Severity.TRACE)
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.TRACE)

	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.INFO, "Scope", "outer"))

	assert_eq(reentrant.calls, 1, "the nested record must not recurse")
	assert_eq(_capture.bodies(), PackedStringArray(["outer"]))


func test_dispatch_works_again_after_a_dropped_nested_record() -> void:
	var reentrant: ReentrantHandler = ReentrantHandler.new()
	TwitchLoggerManager.add_handler(reentrant.handle, TwitchLogLevel.Severity.TRACE)

	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.INFO, "Scope", "first"))
	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.INFO, "Scope", "second"))

	assert_eq(reentrant.calls, 2)


func test_handlers_of_freed_objects_are_removed() -> void:
	var node: Node = Node.new()
	TwitchLoggerManager.add_handler(node.set_name)
	TwitchLoggerManager.add_handler(_capture.handle)
	node.free()

	TwitchLoggerManager.dispatch(_record(TwitchLogLevel.Severity.INFO, "Scope", "still works"))

	assert_eq(TwitchLoggerManager._handlers.size(), 1, "the stale entry must be pruned")
	assert_eq(_capture.bodies(), PackedStringArray(["still works"]))


func test_dispatch_from_threads() -> void:
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.TRACE)
	var threads: Array[Thread] = []
	for index: int in 4:
		var thread: Thread = Thread.new()
		thread.start(_dispatch_many.bind(index))
		threads.append(thread)
	for thread: Thread in threads:
		thread.wait_to_finish()

	assert_eq(_capture.records.size(), 4 * 50)


func test_register_enables_the_logger_from_its_setting() -> void:
	ProjectSettings.set_setting("twitcher/logs/GutRegisterProbe", "debug")
	var logger: TwitchLogger = TwitchLogger.new("GutRegisterProbe")

	assert_true(logger.enabled)
	assert_true(logger.debug)
	assert_same(TwitchLoggerManager.log_registry["GutRegisterProbe"], logger)
	ProjectSettings.clear("twitcher/logs/GutRegisterProbe")


func _dispatch_many(index: int) -> void:
	for count: int in 50:
		TwitchLoggerManager.dispatch(
				_record(TwitchLogLevel.Severity.INFO, "Thread%d" % index, str(count)))


func _record(level: int, scope: String, body: String) -> Dictionary:
	return TwitchLogRecord.create(level, scope, body)


## Godot frees a lambda with its script before static variables at shutdown; a
## lambda still registered then crashes the game on quit.
func test_lambda_handlers_are_removed_on_shutdown() -> void:
	var lambda: Callable = func(_record: Dictionary) -> void:
		pass
	TwitchLoggerManager.add_handler(lambda)
	TwitchLoggerManager.add_handler(_capture.handle)

	TwitchLoggerManager._remove_lambda_handlers()

	assert_false(TwitchLoggerManager.has_handler(lambda), "lambdas must go before shutdown")
	assert_true(TwitchLoggerManager.has_handler(_capture.handle), "methods are safe and stay")


func test_scoped_handlers_with_lambda_resolvers_are_removed_on_shutdown() -> void:
	var resolver: Callable = func(_scope: String) -> int:
		return TwitchLogLevel.Severity.INFO
	TwitchLoggerManager.add_scoped_handler(_capture.handle, resolver)

	TwitchLoggerManager._remove_lambda_handlers()

	assert_false(TwitchLoggerManager.has_handler(_capture.handle))


func test_adding_a_lambda_watches_the_tree_shutdown() -> void:
	var lambda: Callable = func(_record: Dictionary) -> void:
		pass
	TwitchLoggerManager.add_handler(lambda)

	var remove_lambdas: Callable = Callable(TwitchLoggerManager, &"_remove_lambda_handlers")
	assert_true(get_tree().root.tree_exiting.is_connected(remove_lambdas))
