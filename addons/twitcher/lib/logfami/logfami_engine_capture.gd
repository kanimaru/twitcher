@tool
class_name LogfamiEngineCapture
extends Logger
## Forwards the engine's own output to Logfami: [method @GlobalScope.push_error],
## [method @GlobalScope.push_warning], script and shader errors and, when
## [member capture_messages] is on, [method @GlobalScope.print] output too.
## [codeblock]
## var capture: LogfamiEngineCapture = LogfamiEngineCapture.new(logfami)
## capture.install()
## [/codeblock]
## Records use the scope [constant SCOPE] and carry the source location as
## OpenTelemetry [code]code.*[/code] attributes. Output Logfami produces while
## writing (a sink warning, a stdout line) is dropped instead of looping.

const SCOPE: String = "godot"

const _TYPE_NAMES: Dictionary[int, String] = {
	ERROR_TYPE_ERROR: "error",
	ERROR_TYPE_WARNING: "warning",
	ERROR_TYPE_SCRIPT: "script",
	ERROR_TYPE_SHADER: "shader",
}

var logfami: Logfami
## Also forwards printed messages. Off by default: other loggers print their
## own lines, which would end up twice in the log.
var capture_messages: bool = false

var _is_installed: bool = false


func _init(target: Logfami, messages: bool = false) -> void:
	logfami = target
	capture_messages = messages


## Registers at the engine via [method OS.add_logger]. Calling it twice is fine.
func install() -> void:
	if _is_installed:
		return
	OS.add_logger(self)
	_is_installed = true


func uninstall() -> void:
	if not _is_installed:
		return
	OS.remove_logger(self)
	_is_installed = false


func is_installed() -> bool:
	return _is_installed


func _log_error(function: String, file: String, line: int, code: String, rationale: String,
		_editor_notify: bool, error_type: int,
		_script_backtraces: Array[ScriptBacktrace]) -> void:
	var level: int = LogfamiLevel.Severity.ERROR
	if error_type == ERROR_TYPE_WARNING:
		level = LogfamiLevel.Severity.WARN
	var message: String = rationale if rationale != "" else code
	logfami.log_message(level, SCOPE, message, {
		"code.function": function,
		"code.filepath": file,
		"code.lineno": line,
		"error.type": _TYPE_NAMES.get(error_type, str(error_type)),
	})


func _log_message(message: String, error: bool) -> void:
	if not capture_messages:
		return
	var level: int = LogfamiLevel.Severity.ERROR if error else LogfamiLevel.Severity.INFO
	logfami.log_message(level, SCOPE, message.strip_edges(false, true))
