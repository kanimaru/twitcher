@tool
class_name LogfamiRecord
extends RefCounted
## One log entry, shaped after the OpenTelemetry log data model.
##
## [method from_dict] and [method to_dict] convert from and to the plain
## dictionary form other systems hand over (the same keys as the properties
## below). Missing keys fall back to defaults, so partial dictionaries work.

const TIME_UNIX_MS: String = "time_unix_ms"
const TICKS_MSEC: String = "ticks_msec"
const SEVERITY_NUMBER: String = "severity_number"
const SEVERITY_TEXT: String = "severity_text"
const BODY: String = "body"
const SCOPE: String = "scope"
const ATTRIBUTES: String = "attributes"
const THREAD_ID: String = "thread_id"

## Wall clock, UTC, milliseconds since epoch.
var time_unix_ms: int = 0
## Milliseconds since the engine started.
var ticks_msec: int = 0
## See [enum LogfamiLevel.Severity].
var severity_number: int = LogfamiLevel.Severity.INFO
var severity_text: String = "INFO"
var body: String = ""
## Which part of the program logged, e.g. a class or module name.
var scope: String = ""
## Structured extras of the entry.
var attributes: Dictionary = {}
## [method OS.get_thread_caller_id] of the logging thread.
var thread_id: int = 0


## Creates a record stamped with [param clock] and the calling thread.
static func create(level: int, record_scope: String, text: String,
		record_attributes: Dictionary = {}, clock: LogfamiClock = null) -> LogfamiRecord:
	var time_source: LogfamiClock = clock if clock != null else LogfamiClock.new()
	var record: LogfamiRecord = LogfamiRecord.new()
	record.time_unix_ms = time_source.now_unix_ms()
	record.ticks_msec = time_source.ticks_msec()
	record.severity_number = level
	record.severity_text = LogfamiLevel.to_text(level)
	record.body = text
	record.scope = record_scope
	record.attributes = record_attributes.duplicate(true)
	record.thread_id = OS.get_thread_caller_id()
	return record


static func from_dict(data: Dictionary) -> LogfamiRecord:
	var record: LogfamiRecord = LogfamiRecord.new()
	record.time_unix_ms = int(data.get(TIME_UNIX_MS, 0))
	record.ticks_msec = int(data.get(TICKS_MSEC, 0))
	record.severity_number = int(data.get(SEVERITY_NUMBER, LogfamiLevel.Severity.INFO))
	var default_text: String = LogfamiLevel.to_text(record.severity_number)
	record.severity_text = str(data.get(SEVERITY_TEXT, default_text))
	record.body = str(data.get(BODY, ""))
	record.scope = str(data.get(SCOPE, ""))
	var data_attributes: Variant = data.get(ATTRIBUTES, {})
	if data_attributes is Dictionary:
		record.attributes = (data_attributes as Dictionary).duplicate(true)
	record.thread_id = int(data.get(THREAD_ID, 0))
	return record


func to_dict() -> Dictionary:
	return {
		TIME_UNIX_MS: time_unix_ms,
		TICKS_MSEC: ticks_msec,
		SEVERITY_NUMBER: severity_number,
		SEVERITY_TEXT: severity_text,
		BODY: body,
		SCOPE: scope,
		ATTRIBUTES: attributes.duplicate(true),
		THREAD_ID: thread_id,
	}


## Deep copy, so processors can change a record without affecting other
## pipelines that receive the same one.
func copy() -> LogfamiRecord:
	return LogfamiRecord.from_dict(to_dict())
