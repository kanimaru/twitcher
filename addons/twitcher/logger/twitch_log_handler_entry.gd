@tool
class_name TwitchLogHandlerEntry
extends RefCounted
## A handler registered at [TwitchLoggerManager] together with its level filter.
##
## The filter is either one [member min_level] for every scope or, when
## [member level_resolver] is set, a threshold looked up per scope.

## [code]func(record: Dictionary) -> void[/code], see [TwitchLogRecord].
var handler: Callable
## Lowest severity the handler receives, see [enum TwitchLogLevel.Severity].
var min_level: int
## Optional [code]func(scope: String) -> int[/code] returning the threshold per
## scope. Takes precedence over [member min_level] when set.
var level_resolver: Callable


func _init(target: Callable, level: int, resolver: Callable = Callable()) -> void:
	handler = target
	min_level = level
	level_resolver = resolver


## Threshold for [param scope]. An invalidated resolver turns the handler off.
func threshold_for(scope: String) -> int:
	if level_resolver.is_null():
		return min_level
	if not level_resolver.is_valid():
		return TwitchLogLevel.OFF
	return level_resolver.call(scope)


func accepts(scope: String, level: int) -> bool:
	return level >= threshold_for(scope)


## False once the object behind the handler or resolver got freed.
func is_valid() -> bool:
	if not handler.is_valid():
		return false
	return level_resolver.is_null() or level_resolver.is_valid()
