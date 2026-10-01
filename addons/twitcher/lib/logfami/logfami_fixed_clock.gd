@tool
class_name LogfamiFixedClock
extends LogfamiClock
## Clock that only moves when told to, for reproducible log output.

var unix_ms: int
var ticks: int


func _init(start_unix_ms: int = 0, start_ticks: int = 0) -> void:
	unix_ms = start_unix_ms
	ticks = start_ticks


func now_unix_ms() -> int:
	return unix_ms


func ticks_msec() -> int:
	return ticks


## Moves both the wall clock and the ticks forward.
func advance(milliseconds: int) -> void:
	unix_ms += milliseconds
	ticks += milliseconds
