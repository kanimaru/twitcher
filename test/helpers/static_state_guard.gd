## Snapshots and restores every piece of process-global state that Twitcher
## mutates, so that test suites stay isolated from one another.
##
## Twitcher leaks static state aggressively: singleton [code]instance[/code]
## vars, static logger callables installed via [code]set_logger[/code] cascades,
## a process-wide HTTP server port registry, and a handful of static registries
## that are never cleared. Without this guard, suites pass in isolation and
## fail when run together — the worst possible failure mode.
##
## Usage is handled for you by [TwitcherTest]; you only need to touch this
## directly if you are writing a test that does not extend that base class.
##
## [codeblock]
## var guard := StaticStateGuard.new()
## guard.snapshot()
## # ... mutate the world ...
## guard.restore()
## [/codeblock]
##
## Adding a new entry: append to [member _SLOTS]. Each slot names a script to
## preload and a static property on it. Slots whose script fails to load are
## skipped silently, so this file does not break when Twitcher is refactored.
class_name StaticStateGuard
extends RefCounted

## Static properties restored verbatim between tests.
##
## [code]path[/code] is a [code]res://[/code] script path, [code]prop[/code] the
## static property name on it. [code]deep[/code] marks containers that must be
## duplicated on capture — otherwise we would snapshot a live reference and
## "restoring" would be a no-op.
const _SLOTS: Array[Dictionary] = [
	# --- singleton instances (set in _enter_tree, cleared in _exit_tree) ---
	{path = "res://addons/twitcher/twitch_service.gd", prop = "instance", deep = false},
	{path = "res://addons/twitcher/generated/twitch_api.gd", prop = "instance", deep = false},
	{path = "res://addons/twitcher/eventsub/twitch_eventsub.gd", prop = "instance", deep = false},
	{path = "res://addons/twitcher/chat/twitch_chat.gd", prop = "instance", deep = false},
	{path = "res://addons/twitcher/chat/twitch_bot.gd", prop = "instance", deep = false},
	{path = "res://addons/twitcher/media/twitch_media_loader.gd", prop = "instance", deep = false},

	# --- static registries that are never evicted by production code ---
	{path = "res://addons/twitcher/chat/twitch_command_base.gd", prop = "ALL_COMMANDS", deep = true},
	{path = "res://addons/twitcher/chat/twitch_auto_message.gd", prop = "all_rotational_messages", deep = true},
	{path = "res://addons/twitcher/reward/twitch_redeem_listener.gd", prop = "_open_tracked_redemptions", deep = true},
	{path = "res://addons/twitcher/lib/http/http_server.gd", prop = "_servers", deep = true},
	{path = "res://addons/twitcher/logger/twitch_logger_manager.gd", prop = "log_registry", deep = true},
	{path = "res://addons/twitcher/logger/twitch_logger_manager.gd", prop = "_handlers", deep = true},

	# --- logger callables, installed by the set_logger cascade ---
	# TwitchAuth._init() alone rewrites the first three of these.
	{path = "res://addons/twitcher/lib/http/buffered_http_client.gd", prop = "logger", deep = true},
	{path = "res://addons/twitcher/lib/http/http_server.gd", prop = "logger", deep = true},
	{path = "res://addons/twitcher/lib/http/websocket_client.gd", prop = "logger", deep = true},
	{path = "res://addons/twitcher/lib/oOuch/oauth.gd", prop = "logger", deep = true},
	{path = "res://addons/twitcher/lib/oOuch/oauth_token_handler.gd", prop = "logger", deep = true},
	{path = "res://addons/twitcher/lib/oOuch/oauth_token.gd", prop = "logger", deep = true},
]

## ProjectSettings keys matching these prefixes are captured and restored.
## Every [code]TwitchLogger.new()[/code] writes one of these as a side effect of
## construction, so merely referencing a Twitcher class mutates project settings.
const _SETTING_PREFIXES: PackedStringArray = ["twitcher/"]

var _values: Array[Variant] = []
var _scripts: Array[Variant] = []
var _settings: Dictionary[String, Variant] = {}
var _has_snapshot := false


## Captures the current value of every slot. Safe to call repeatedly; each call
## discards the previous snapshot.
func snapshot() -> void:
	_values.clear()
	_scripts.clear()
	_settings.clear()

	for slot: Dictionary in _SLOTS:
		var script: Variant = _load(slot["path"])
		_scripts.append(script)
		if script == null:
			_values.append(null)
			continue
		var value: Variant = script.get(slot["prop"])
		_values.append(_copy(value) if slot["deep"] else value)

	for prefix: String in _SETTING_PREFIXES:
		for key: String in _project_setting_keys(prefix):
			_settings[key] = ProjectSettings.get_setting(key)

	_has_snapshot = true


## Restores every captured value. A no-op if [method snapshot] was never called,
## so an aborted test cannot corrupt state by restoring nothing over something.
func restore() -> void:
	if not _has_snapshot:
		return

	for i: int in _SLOTS.size():
		var script: Variant = _scripts[i]
		if script == null:
			continue
		var slot: Dictionary = _SLOTS[i]
		script.set(slot["prop"], _copy(_values[i]) if slot["deep"] else _values[i])

	for key: String in _settings:
		ProjectSettings.set_setting(key, _settings[key])


## Names of the slots this guard is currently tracking. Used by the meta-test
## that asserts the guard has not silently stopped covering a script.
func tracked_slots() -> PackedStringArray:
	var out := PackedStringArray()
	for i: int in _SLOTS.size():
		if _scripts.is_empty() or _scripts[i] != null:
			out.append("%s::%s" % [_SLOTS[i]["path"].get_file(), _SLOTS[i]["prop"]])
	return out


func _load(path: String) -> Variant:
	if not ResourceLoader.exists(path):
		return null
	return load(path)


## Duplicates containers one level deep. Arrays and Dictionaries are the only
## mutable-by-reference types in the slot table; everything else is either a
## value type or an object we deliberately want to hold by reference.
func _copy(value: Variant) -> Variant:
	if value is Array:
		return (value as Array).duplicate()
	if value is Dictionary:
		return (value as Dictionary).duplicate()
	return value


func _project_setting_keys(prefix: String) -> PackedStringArray:
	var out := PackedStringArray()
	for info: Dictionary in ProjectSettings.get_property_list():
		var name: String = info["name"]
		if name.begins_with(prefix):
			out.append(name)
	return out
