@tool
class_name LogfamiResource
extends RefCounted
## Describes who produces the logs: the program, its version and where it runs.
##
## Keys follow the OpenTelemetry semantic conventions where one exists
## ([code]service.name[/code], [code]service.version[/code],
## [code]os.type[/code], [code]process.pid[/code]). The values are the same for
## every record of a session, so formatters usually write them once per file.

const SERVICE_NAME: String = "service.name"
const SERVICE_VERSION: String = "service.version"
const GODOT_VERSION: String = "godot.version"
const OS_TYPE: String = "os.type"
const PROCESS_PID: String = "process.pid"
const RUNTIME: String = "runtime"

const RUNTIME_EDITOR: String = "editor"
const RUNTIME_HEADLESS: String = "headless"
const RUNTIME_GAME: String = "game"

var attributes: Dictionary = {}


func _init(resource_attributes: Dictionary = {}) -> void:
	attributes = resource_attributes.duplicate(true)


## Detects the attributes of the running program. Reads the project settings
## but never writes them.
static func detect() -> LogfamiResource:
	var name: String = str(ProjectSettings.get_setting("application/config/name", ""))
	var version: String = str(ProjectSettings.get_setting("application/config/version", ""))
	return LogfamiResource.new({
		SERVICE_NAME: name if name != "" else "godot-app",
		SERVICE_VERSION: version,
		GODOT_VERSION: str(Engine.get_version_info().get("string", "")),
		OS_TYPE: OS.get_name().to_lower(),
		PROCESS_PID: OS.get_process_id(),
		RUNTIME: detect_runtime(),
	})


## [constant RUNTIME_EDITOR], [constant RUNTIME_HEADLESS] or
## [constant RUNTIME_GAME].
static func detect_runtime() -> String:
	if Engine.is_editor_hint():
		return RUNTIME_EDITOR
	if DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server"):
		return RUNTIME_HEADLESS
	return RUNTIME_GAME


## Returns a copy with [param key] set to [param value].
func with_attribute(key: String, value: Variant) -> LogfamiResource:
	var copied: LogfamiResource = LogfamiResource.new(attributes)
	copied.attributes[key] = value
	return copied


func get_attribute(key: String, default: Variant = null) -> Variant:
	return attributes.get(key, default)
