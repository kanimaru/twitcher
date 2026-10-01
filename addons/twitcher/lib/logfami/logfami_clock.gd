@tool
class_name LogfamiClock
extends RefCounted
## Time source of Logfami. Swap in a [LogfamiFixedClock] for deterministic
## output in tests.


## Wall clock in milliseconds since the Unix epoch, UTC.
func now_unix_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)


## Milliseconds since the engine started.
func ticks_msec() -> int:
	return Time.get_ticks_msec()
