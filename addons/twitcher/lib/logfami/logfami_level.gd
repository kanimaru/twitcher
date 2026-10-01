@tool
class_name LogfamiLevel
extends RefCounted
## Log severities, numbered after the OpenTelemetry SeverityNumber.
##
## OpenTelemetry reserves four numbers per severity (INFO covers 9 to 12), so
## records from other systems with finer grades map onto these without loss.
## Thresholds are plain [int]s; [constant OFF] accepts nothing.

enum Severity {
	TRACE = 1,
	DEBUG = 5,
	INFO = 9,
	WARN = 13,
	ERROR = 17,
	FATAL = 21,
}

## Threshold that accepts no severity at all.
const OFF: int = 100

const _TEXT_BY_SEVERITY: Dictionary[int, String] = {
	Severity.TRACE: "TRACE",
	Severity.DEBUG: "DEBUG",
	Severity.INFO: "INFO",
	Severity.WARN: "WARN",
	Severity.ERROR: "ERROR",
	Severity.FATAL: "FATAL",
}

const _THRESHOLD_BY_TEXT: Dictionary[String, int] = {
	"off": OFF,
	"trace": Severity.TRACE,
	"debug": Severity.DEBUG,
	"info": Severity.INFO,
	"warn": Severity.WARN,
	"warning": Severity.WARN,
	"error": Severity.ERROR,
	"fatal": Severity.FATAL,
}

## RFC 5424 syslog severity per base severity.
const _SYSLOG_BY_SEVERITY: Dictionary[int, int] = {
	Severity.TRACE: 7,
	Severity.DEBUG: 7,
	Severity.INFO: 6,
	Severity.WARN: 4,
	Severity.ERROR: 3,
	Severity.FATAL: 2,
}


## Returns the base severity of the range [param level] falls in, e.g.
## [constant Severity.INFO] for 10. Numbers outside of 1 to 24 return -1.
static func base_of(level: int) -> int:
	if level < Severity.TRACE or level > Severity.FATAL + 3:
		return -1
	return floori((level - 1) / 4.0) * 4 + 1


## OpenTelemetry severity text, e.g. [code]"INFO"[/code] for 9 to 12. Numbers
## outside of 1 to 24 return an empty string.
static func to_text(level: int) -> String:
	return _TEXT_BY_SEVERITY.get(base_of(level), "")


## Parses a threshold like [code]"info"[/code] or [code]"off"[/code].
## Case-insensitive; unknown values turn logging off.
static func threshold_from_text(text: String) -> int:
	return _THRESHOLD_BY_TEXT.get(text.strip_edges().to_lower(), OFF)


## RFC 5424 syslog severity (2 critical … 7 debug). Out of range returns 7.
static func to_syslog(level: int) -> int:
	return _SYSLOG_BY_SEVERITY.get(base_of(level), 7)
