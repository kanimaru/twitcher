class_name LogCapture
extends RefCounted
## Log handler for tests: collects every record it receives.
##
## [codeblock]
## var capture: LogCapture = LogCapture.new()
## TwitchLoggerManager.add_handler(capture.handle, TwitchLogLevel.Severity.TRACE)
## [/codeblock]

var records: Array[Dictionary] = []

var _mutex: Mutex = Mutex.new()


## Thread-safe, so tests can log from several threads at once.
func handle(record: Dictionary) -> void:
	_mutex.lock()
	records.append(record)
	_mutex.unlock()


func bodies() -> PackedStringArray:
	var result: PackedStringArray = []
	for record: Dictionary in records:
		result.append(record[TwitchLogRecord.BODY])
	return result


func last() -> Dictionary:
	if records.is_empty():
		return {}
	return records.back()
