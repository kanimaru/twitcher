@tool
@abstract
class_name LogfamiProcessor
extends RefCounted
## Changes or drops records before a pipeline formats them, e.g. redaction.
##
## A processor receives a pipeline's own copy of the record, so changing it in
## place is safe.


## Returns the record to pass on, or [code]null[/code] to drop it.
@abstract func process(record: LogfamiRecord) -> LogfamiRecord
