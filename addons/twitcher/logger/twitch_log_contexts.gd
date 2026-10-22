@tool
class_name TwitchLogContexts
extends RefCounted
## The per-context console switches: which Twitcher component prints which
## messages, stored as [code]twitcher/logs/<Context>[/code] in the project
## settings with the values [code]off[/code], [code]info[/code] and
## [code]debug[/code].
##
## The Project Settings and the log dock edit the same values. [method set_mode]
## applies a change to the running logger right away, so no restart is needed.

const SETTING_PREFIX: String = "twitcher/logs/"
const MODE_OFF: String = "off"
const MODE_INFO: String = "info"
const MODE_DEBUG: String = "debug"
const MODES: Array[String] = [MODE_OFF, MODE_INFO, MODE_DEBUG]
## Returned by [method override_level] for contexts without a runtime mode.
const NO_OVERRIDE: int = -1

## Modes picked at runtime by [method set_mode]. They win over the flags of every
## logger of the context: contexts may have several loggers (Twitcher has two for
## "Http"), but the registry only knows the last one.
static var _overrides: Dictionary[String, String] = {}


static func setting_key(context: String) -> String:
	return SETTING_PREFIX + context


## The setting of [param context], registered with its default on first use.
static func property_for(context: String) -> TwitchProperty:
	var property: TwitchProperty = TwitchProperty.new(setting_key(context), MODE_OFF)
	property.as_select(MODES)
	return property


## The mode [param logger] currently runs in.
static func mode_of(logger: TwitchLogger) -> String:
	if not logger.enabled:
		return MODE_OFF
	if logger.debug:
		return MODE_DEBUG
	return MODE_INFO


## Switches [param logger] to [param mode]. Unknown modes are ignored.
static func apply(logger: TwitchLogger, mode: String) -> void:
	if not MODES.has(mode):
		return
	logger.set_enabled(mode != MODE_OFF)
	logger.debug = mode == MODE_DEBUG


## The threshold a [param mode] stands for, see [enum LogfamiLevel.Severity].
static func level_of(mode: String) -> int:
	match mode:
		MODE_DEBUG:
			return LogfamiLevel.Severity.DEBUG
		MODE_INFO:
			return LogfamiLevel.Severity.INFO
		_:
			return LogfamiLevel.OFF


## The threshold picked at runtime for [param context] by [method set_mode],
## [constant NO_OVERRIDE] when nobody did.
static func override_level(context: String) -> int:
	if not _overrides.has(context):
		return NO_OVERRIDE
	return level_of(_overrides[context])


## The mode of [param context]: what [method set_mode] picked, else the running
## logger, as code may have switched it on without the setting. Contexts without
## a logger fall back to their setting.
static func get_mode(context: String) -> String:
	if _overrides.has(context):
		return _overrides[context]
	var registered: Variant = TwitchLoggerManager.log_registry.get(context)
	if registered is TwitchLogger:
		return mode_of(registered)
	var stored: String = str(ProjectSettings.get_setting(setting_key(context), MODE_OFF))
	return stored if MODES.has(stored) else MODE_OFF


## Stores [param mode] for [param context] and applies it to its running loggers.
## In the editor the project settings are saved when [param persist] is set.
## Returns false for an unknown mode or an empty context.
static func set_mode(context: String, mode: String, persist: bool = true) -> bool:
	if context.is_empty() or not MODES.has(mode):
		return false
	property_for(context).set_val(mode)
	_overrides[context] = mode
	var registered: Variant = TwitchLoggerManager.log_registry.get(context)
	if registered is TwitchLogger:
		apply(registered, mode)
	if persist and Engine.is_editor_hint():
		ProjectSettings.save()
	return true


## Every context that has a logger or a setting, sorted. Settings of contexts
## whose component isn't loaded yet show up as well.
static func known_contexts() -> PackedStringArray:
	var seen: Dictionary[String, bool] = {}
	for context: Variant in TwitchLoggerManager.log_registry:
		seen[str(context)] = true
	for property: Dictionary in ProjectSettings.get_property_list():
		var context: String = _context_of_setting(property)
		if context != "":
			seen[context] = true
	var sorted: PackedStringArray = PackedStringArray(seen.keys())
	sorted.sort()
	return sorted


## The context a setting belongs to, empty for every other setting. Sub groups
## ([code]file/level[/code]) and settings of other types ([code]capture_engine[/code])
## are no contexts.
static func _context_of_setting(property: Dictionary) -> String:
	var name: String = property.get("name", "")
	if not name.begins_with(SETTING_PREFIX):
		return ""
	var context: String = name.trim_prefix(SETTING_PREFIX)
	if context.contains("/") or property.get("type", TYPE_NIL) != TYPE_STRING:
		return ""
	return context if MODES.has(str(ProjectSettings.get_setting(name, ""))) else ""
