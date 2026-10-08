@tool
class_name LogfamiRecordBuffer
extends RefCounted
## Keeps the latest records in memory, for in-game or in-editor log viewers.
##
## Once [member capacity] is reached, the oldest record makes room for the
## newest. Records may be added from any thread. A viewer polls [member version]
## to learn whether anything changed since it last drew, so the buffer needs no
## signals (which would fire on the logging thread).

## Records kept at most.
var capacity: int:
	set(value):
		capacity = maxi(1, value)
## Increases with every change; compare it to the one of the last redraw.
var version: int = 0

var _records: Array[LogfamiRecord] = []
var _mutex: Mutex = Mutex.new()


func _init(max_records: int = 2000) -> void:
	capacity = max_records


func add(record: LogfamiRecord) -> void:
	_mutex.lock()
	_records.append(record)
	while _records.size() > capacity:
		_records.pop_front()
	version += 1
	_mutex.unlock()


func clear() -> void:
	_mutex.lock()
	_records = []
	version += 1
	_mutex.unlock()


func size() -> int:
	_mutex.lock()
	var count: int = _records.size()
	_mutex.unlock()
	return count


## Copy of the records that pass [param filter], oldest first. Without a filter
## every record passes.
func get_records(filter: LogfamiRecordFilter = null) -> Array[LogfamiRecord]:
	_mutex.lock()
	var snapshot: Array[LogfamiRecord] = _records.duplicate()
	_mutex.unlock()
	if filter == null:
		return snapshot
	return filter.apply(snapshot)


## Every scope that has a record in the buffer, sorted.
func scopes() -> PackedStringArray:
	_mutex.lock()
	var seen: Dictionary[String, bool] = {}
	for record: LogfamiRecord in _records:
		seen[record.scope] = true
	_mutex.unlock()
	var sorted: PackedStringArray = PackedStringArray(seen.keys())
	sorted.sort()
	return sorted


## Merges two lists, each oldest first, into one ordered by
## [member LogfamiRecord.time_unix_ms]. On equal times [param first] comes first.
static func merge(first: Array[LogfamiRecord],
		second: Array[LogfamiRecord]) -> Array[LogfamiRecord]:
	var merged: Array[LogfamiRecord] = []
	var i: int = 0
	var j: int = 0
	while i < first.size() and j < second.size():
		if second[j].time_unix_ms < first[i].time_unix_ms:
			merged.append(second[j])
			j += 1
		else:
			merged.append(first[i])
			i += 1
	merged.append_array(first.slice(i))
	merged.append_array(second.slice(j))
	return merged
