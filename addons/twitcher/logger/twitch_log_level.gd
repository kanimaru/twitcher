@tool
class_name TwitchLogLevel
extends RefCounted
## Log severities, numbered after the OpenTelemetry SeverityNumber.
##
## The gaps between the values are intentional: OpenTelemetry reserves four
## numbers per severity (INFO covers 9 to 12) so finer grades fit in later
## without renumbering. Thresholds are plain [int]s so handlers outside of
## Twitcher can pass them without referencing this class.

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
	"error": Severity.ERROR,
	"fatal": Severity.FATAL,
}


## Returns the OpenTelemetry severity text, e.g. [code]"INFO"[/code] for any
## number between 9 and 12. Numbers outside of 1 to 24 return an empty string.
static func to_text(level: int) -> String:
	return _TEXT_BY_SEVERITY.get(base_of(level), "")


## Returns the base severity of the range [param level] falls in, e.g.
## [constant Severity.INFO] for 10. Numbers outside of 1 to 24 return -1.
static func base_of(level: int) -> int:
	if level < Severity.TRACE or level > Severity.FATAL + 3:
		return -1
	return floori((level - 1) / 4.0) * 4 + 1


## Parses a threshold like the values of the [code]twitcher/logs/*[/code]
## settings ([code]"off"[/code], [code]"info"[/code], [code]"debug"[/code], …).
## Case-insensitive; unknown values turn logging off.
static func threshold_from_text(text: String) -> int:
	return _THRESHOLD_BY_TEXT.get(text.strip_edges().to_lower(), OFF)
