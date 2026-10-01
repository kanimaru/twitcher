@tool
class_name LogfamiStdoutSink
extends LogfamiSink
## Prints lines to standard output, for headless servers and containers where
## a log collector reads stdout (twelve-factor app). Pair it with
## [LogfamiJsonLinesFormatter] and [member LogfamiJsonLinesFormatter.include_resource].
##
## Godot buffers stdout when it isn't a terminal; enable the project setting
## [code]application/run/flush_stdout_on_print[/code] so lines reach the
## collector right away. [method @GlobalScope.print] is thread-safe, so this
## sink needs no lock of its own.

## Sends records at [member stderr_level] and above to stderr instead.
var errors_to_stderr: bool = false
var stderr_level: int = LogfamiLevel.Severity.ERROR
## Receives stdout lines. Defaults to [method @GlobalScope.print].
var printer: Callable
## Receives stderr lines. Defaults to [method @GlobalScope.printerr].
var error_printer: Callable


func _init() -> void:
	printer = _print
	error_printer = _print_error


func start_session(header: PackedStringArray) -> void:
	for line: String in header:
		printer.call(line)


func write(line: String, record: LogfamiRecord) -> void:
	var is_error: bool = record != null and record.severity_number >= stderr_level
	if errors_to_stderr and is_error:
		error_printer.call(line)
	else:
		printer.call(line)


func _print(line: String) -> void:
	print(line)


func _print_error(line: String) -> void:
	printerr(line)
