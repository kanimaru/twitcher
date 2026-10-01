@tool
class_name LogfamiTime
extends RefCounted
## Timestamp formatting for log output.


## RFC 3339 in UTC with milliseconds, e.g. [code]2025-09-29T10:00:00.123Z[/code].
static func rfc3339(unix_ms: int) -> String:
	var seconds: int = floori(unix_ms / 1000.0)
	var milliseconds: int = unix_ms - seconds * 1000
	var date_time: String = Time.get_datetime_string_from_unix_time(seconds, false)
	return "%s.%03dZ" % [date_time, milliseconds]
