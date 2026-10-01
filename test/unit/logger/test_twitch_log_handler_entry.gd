extends TwitcherTest
## Unit tests for [TwitchLogHandlerEntry].


class Target:
	extends RefCounted

	var threshold: int = TwitchLogLevel.Severity.WARN


	func handle(_record: Dictionary) -> void:
		pass


	func resolve(scope: String, logger: TwitchLogger) -> int:
		if logger != null and logger.debug:
			return TwitchLogLevel.Severity.TRACE
		if scope == "Loud":
			return TwitchLogLevel.Severity.DEBUG
		return threshold


func test_min_level_applies_to_every_scope() -> void:
	var target: Target = Target.new()
	var entry: TwitchLogHandlerEntry = TwitchLogHandlerEntry.new(
			target.handle, TwitchLogLevel.Severity.INFO)

	assert_eq(entry.threshold_for("Any"), TwitchLogLevel.Severity.INFO)
	assert_true(entry.accepts("Any", TwitchLogLevel.Severity.INFO))
	assert_true(entry.accepts("Any", TwitchLogLevel.Severity.ERROR))
	assert_false(entry.accepts("Any", TwitchLogLevel.Severity.DEBUG))


func test_resolver_overrides_min_level_per_scope() -> void:
	var target: Target = Target.new()
	var entry: TwitchLogHandlerEntry = TwitchLogHandlerEntry.new(
			target.handle, TwitchLogLevel.Severity.TRACE, target.resolve)

	assert_eq(entry.threshold_for("Loud"), TwitchLogLevel.Severity.DEBUG)
	assert_eq(entry.threshold_for("Quiet"), TwitchLogLevel.Severity.WARN)
	assert_false(entry.accepts("Quiet", TwitchLogLevel.Severity.INFO))


func test_resolver_receives_the_emitting_logger() -> void:
	var target: Target = Target.new()
	var entry: TwitchLogHandlerEntry = TwitchLogHandlerEntry.new(
			target.handle, TwitchLogLevel.Severity.TRACE, target.resolve)
	var logger: TwitchLogger = TwitchLogger.new("GutEntryProbe", true, true)

	assert_eq(entry.threshold_for("Quiet", logger), TwitchLogLevel.Severity.TRACE)
	assert_true(entry.accepts("Quiet", TwitchLogLevel.Severity.TRACE, logger))


func test_entry_is_valid_while_its_objects_live() -> void:
	var target: Target = Target.new()
	var entry: TwitchLogHandlerEntry = TwitchLogHandlerEntry.new(
			target.handle, TwitchLogLevel.Severity.INFO, target.resolve)
	assert_true(entry.is_valid())


func test_entry_turns_invalid_when_the_handler_is_freed() -> void:
	var node: Node = Node.new()
	var entry: TwitchLogHandlerEntry = TwitchLogHandlerEntry.new(
			node.queue_free, TwitchLogLevel.Severity.INFO)
	node.free()
	assert_false(entry.is_valid())


func test_invalid_resolver_turns_the_entry_off() -> void:
	var target: Target = Target.new()
	var node: Node = Node.new()
	var entry: TwitchLogHandlerEntry = TwitchLogHandlerEntry.new(
			target.handle, TwitchLogLevel.Severity.TRACE, node.get_name)
	node.free()

	assert_false(entry.is_valid())
	assert_eq(entry.threshold_for("Any"), TwitchLogLevel.OFF)


func test_is_lambda_tells_lambdas_from_methods() -> void:
	var target: Target = Target.new()
	var lambda: Callable = func(_record: Dictionary) -> void:
		pass

	assert_true(TwitchLogHandlerEntry.is_lambda(lambda), "lambda")
	assert_true(TwitchLogHandlerEntry.is_lambda(lambda.bind(1)), "bound lambda")
	assert_false(TwitchLogHandlerEntry.is_lambda(target.handle), "method")
	assert_false(TwitchLogHandlerEntry.is_lambda(target.handle.bind(1)), "bound method")
	assert_false(TwitchLogHandlerEntry.is_lambda(Callable(target, &"handle")), "by name")
	assert_false(TwitchLogHandlerEntry.is_lambda(Callable()), "null callable")


func test_has_lambda_covers_handler_and_resolver() -> void:
	var target: Target = Target.new()
	var lambda: Callable = func(_scope: String, _logger: TwitchLogger) -> int:
		return TwitchLogLevel.OFF

	var plain: TwitchLogHandlerEntry = TwitchLogHandlerEntry.new(
			target.handle, TwitchLogLevel.Severity.INFO, target.resolve)
	var with_lambda_resolver: TwitchLogHandlerEntry = TwitchLogHandlerEntry.new(
			target.handle, TwitchLogLevel.Severity.INFO, lambda)

	assert_false(plain.has_lambda())
	assert_true(with_lambda_resolver.has_lambda())
