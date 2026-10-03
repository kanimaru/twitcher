@tool
class_name TwitchLogHandlerEntry
extends RefCounted
## A handler registered at [TwitchLoggerManager] together with its level filter.
##
## The filter is either one [member min_level] for every scope or, when
## [member level_resolver] is set, a threshold looked up per scope and logger.

## [code]func(record: Dictionary) -> void[/code], see [TwitchLogRecord].
var handler: Callable
## Lowest severity the handler receives, see [enum LogfamiLevel.Severity].
var min_level: int
## Optional [code]func(scope: String, logger: TwitchLogger) -> int[/code]
## returning the threshold; [code]logger[/code] is null for records dispatched
## without one. Takes precedence over [member min_level] when set.
var level_resolver: Callable


## True for a lambda: a custom callable that isn't a bound method of its object.
static func is_lambda(callable: Callable) -> bool:
	if not callable.is_custom():
		return false
	var owner: Object = callable.get_object()
	return owner == null or not owner.has_method(callable.get_method())


func _init(target: Callable, level: int, resolver: Callable = Callable()) -> void:
	handler = target
	min_level = level
	level_resolver = resolver


## Threshold for [param scope] as emitted by [param logger]. An invalidated
## resolver turns the handler off.
func threshold_for(scope: String, logger: TwitchLogger = null) -> int:
	if level_resolver.is_null():
		return min_level
	if not level_resolver.is_valid():
		return LogfamiLevel.OFF
	return level_resolver.call(scope, logger)


func accepts(scope: String, level: int, logger: TwitchLogger = null) -> bool:
	return level >= threshold_for(scope, logger)


## False once the object behind the handler or resolver got freed.
func is_valid() -> bool:
	if not handler.is_valid():
		return false
	return level_resolver.is_null() or level_resolver.is_valid()


## True when the handler or the resolver is a lambda, see
## [method TwitchLoggerManager.remove_lambda_handlers].
func has_lambda() -> bool:
	return is_lambda(handler) or is_lambda(level_resolver)
