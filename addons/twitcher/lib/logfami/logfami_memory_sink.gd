@tool
class_name LogfamiMemorySink
extends LogfamiSink
## Keeps every line in memory. Meant for tests and in-game log viewers.

var lines: Array[String] = []
var records: Array[LogfamiRecord] = []
var header: PackedStringArray = []
var flush_count: int = 0
var is_closed: bool = false

var _mutex: Mutex = Mutex.new()


func write(line: String, record: LogfamiRecord) -> void:
	_mutex.lock()
	lines.append(line)
	records.append(record)
	_mutex.unlock()


func start_session(session_header: PackedStringArray) -> void:
	header = session_header


func flush() -> void:
	flush_count += 1


func close() -> void:
	is_closed = true
