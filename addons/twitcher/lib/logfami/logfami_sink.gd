@tool
@abstract
class_name LogfamiSink
extends RefCounted
## Destination of formatted lines: a file, stdout, memory, a network service.
##
## Records are written on the thread that logged them, so every method may be
## called from several threads at once, also while [method start_session] or
## [method close] runs. A sink serializes its own output; the pipeline doesn't
## lock around it.


## Writes one formatted line. [param record] is passed along for sinks that
## act on the severity, e.g. to flush on errors.
@abstract func write(line: String, record: LogfamiRecord) -> void


## Called once by the pipeline before the first line, with the formatter so a
## sink can adapt (for example its file extension).
func configure(_formatter: LogfamiFormatter) -> void:
	pass


## Starts a session; [param header] are the formatter's session lines.
func start_session(_header: PackedStringArray) -> void:
	pass


func flush() -> void:
	pass


func close() -> void:
	pass
