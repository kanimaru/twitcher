@tool
class_name TwitchSeenMessages
extends RefCounted

## Remembers message ids for a while, to drop the duplicates Twitch sends when it isn't sure a
## message arrived.
##
## Ids expire in the order they were remembered, so expiring only ever looks at the oldest ones.
## That keeps every call cheap no matter how many ids are remembered, where scanning all of them
## per message adds up on busy channels.

## Smallest number of expired entries before the order list gets compacted.
const _COMPACT_THRESHOLD: int = 1024

## How long an id is remembered, in milliseconds.
var window_msec: int
## Upper bound of remembered ids. The oldest are forgotten early when it's exceeded, so a burst
## can't grow the memory without limit.
var max_size: int

## Key: message id, Value: [method Time.get_ticks_msec] when it was remembered.
var _seen: Dictionary[String, int] = {}
## Remembered ids, oldest first. Entries before [member _head] are expired.
var _order: Array[String] = []
var _head: int = 0


func _init(window: int = 600000, maximum: int = 10000) -> void:
	window_msec = window
	max_size = maximum


## Remembers [param message_id]. Returns false if it was already remembered, meaning the message
## is a duplicate.
func remember(message_id: String, now_msec: int) -> bool:
	expire(now_msec)
	if _seen.has(message_id):
		return false
	_seen[message_id] = now_msec
	_order.append(message_id)
	expire(now_msec)
	return true


func has(message_id: String) -> bool:
	return _seen.has(message_id)


func size() -> int:
	return _seen.size()


## Forgets the ids that are older than [member window_msec] and the oldest ones beyond
## [member max_size].
func expire(now_msec: int) -> void:
	while _head < _order.size():
		var oldest: String = _order[_head]
		var is_outdated: bool = now_msec - _seen[oldest] > window_msec
		if not is_outdated and _seen.size() <= max_size:
			break
		_seen.erase(oldest)
		_head += 1
	_compact()


## Key: message id, Value: [method Time.get_ticks_msec] when it was remembered.
func to_dictionary() -> Dictionary[String, int]:
	return _seen.duplicate()


## Drops the expired part of the order list once it makes up at least half of it, so the list
## doesn't grow forever while removing from its front stays cheap.
func _compact() -> void:
	if _head < _COMPACT_THRESHOLD or _head * 2 < _order.size():
		return
	_order = _order.slice(_head)
	_head = 0
