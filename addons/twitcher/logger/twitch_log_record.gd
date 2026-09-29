@tool
class_name TwitchLogRecord
extends RefCounted
## Builds the records [TwitchLoggerManager] hands to its handlers.
##
## A record is a plain, read-only [Dictionary], so a handler doesn't need any
## Twitcher class to consume it. The shape follows the OpenTelemetry log data
## model:
## [codeblock]
## {
##     "time_unix_ms": int,       # wall clock, UTC, milliseconds since epoch
##     "ticks_msec": int,         # Time.get_ticks_msec() when the record was made
##     "severity_number": int,    # see TwitchLogLevel.Severity
##     "severity_text": String,   # "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"
##     "body": String,            # the message
##     "scope": String,           # context name of the logger, e.g. "TwitchAuth"
##     "attributes": Dictionary,  # structured extras, "instance" holds the suffix
##     "thread_id": int,          # OS.get_thread_caller_id() of the caller
## }
## [/codeblock]
## The keys are a public contract: new keys may be added, existing ones are
## never renamed or removed.

const TIME_UNIX_MS: String = "time_unix_ms"
const TICKS_MSEC: String = "ticks_msec"
const SEVERITY_NUMBER: String = "severity_number"
const SEVERITY_TEXT: String = "severity_text"
const BODY: String = "body"
const SCOPE: String = "scope"
const ATTRIBUTES: String = "attributes"
const THREAD_ID: String = "thread_id"

## Every key a record carries.
const KEYS: PackedStringArray = [
	TIME_UNIX_MS,
	TICKS_MSEC,
	SEVERITY_NUMBER,
	SEVERITY_TEXT,
	BODY,
	SCOPE,
	ATTRIBUTES,
	THREAD_ID,
]

## Attribute holding the instance name set via [method TwitchLogger.set_suffix].
const ATTRIBUTE_INSTANCE: String = "instance"


## Creates a read-only record. [param attributes] is copied, so later changes
## to the passed dictionary don't leak into the record.
static func create(level: int, scope: String, body: String,
		attributes: Dictionary = {}) -> Dictionary:
	var own_attributes: Dictionary = attributes.duplicate(true)
	own_attributes.make_read_only()
	var record: Dictionary = {
		TIME_UNIX_MS: int(Time.get_unix_time_from_system() * 1000.0),
		TICKS_MSEC: Time.get_ticks_msec(),
		SEVERITY_NUMBER: level,
		SEVERITY_TEXT: TwitchLogLevel.to_text(level),
		BODY: body,
		SCOPE: scope,
		ATTRIBUTES: own_attributes,
		THREAD_ID: OS.get_thread_caller_id(),
	}
	record.make_read_only()
	return record
