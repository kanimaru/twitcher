@tool
@abstract
class_name LogfamiFormatter
extends RefCounted
## Turns a record into exactly one line of text.
##
## Implementations must never return a line containing a line break: one
## record, one line, so a log can't be forged by injecting newlines.


## Formats [param record]; [param resource] describes the producing program.
@abstract func format(record: LogfamiRecord, resource: LogfamiResource) -> String


## Lines written at the start of every file or stream, describing the session.
func header(_resource: LogfamiResource, _started_unix_ms: int) -> PackedStringArray:
	return PackedStringArray()


## File extension matching the format, without the dot.
func file_extension() -> String:
	return "log"
