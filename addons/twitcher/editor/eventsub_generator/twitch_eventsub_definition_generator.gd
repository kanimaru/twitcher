@tool
extends Twitcher

## Generates twitch_eventsub_definition.gd from the parsed subscription types list.
class_name TwitchEventsubDefinitionGenerator

const OUTPUT_PATH = "res://addons/twitcher/eventsub/twitch_eventsub_definition.gd"

## The addon names generated_eventsub payload scripts after the *event* they carry, not the
## subscription type string, so a handful of them can't be derived mechanically (e.g.
## channel.charity_campaign.donate -> charity_donation). Everything else follows the "channel."
## prefix staying as-is, deduped where Twitch's own type name repeats it
## (channel.channel_points_...). Kept in sync with EventSubScriptNameResolver on the C# side.
const OVERRIDES: Dictionary[String, String] = {
	"channel.charity_campaign.donate": "charity_donation",
	"channel.charity_campaign.start": "charity_campaign_start",
	"channel.charity_campaign.progress": "charity_campaign_progress",
	"channel.charity_campaign.stop": "charity_campaign_stop",
	"channel.hype_train.begin": "hype_train_begin",
	"channel.hype_train.progress": "hype_train_progress",
	"channel.hype_train.end": "hype_train_end",
	"channel.shared_chat.begin": "channel_shared_chat_session_begin",
	"channel.shared_chat.update": "channel_shared_chat_session_update",
	"channel.shared_chat.end": "channel_shared_chat_session_end",
	"channel.shield_mode.begin": "shield_mode",
	"channel.shield_mode.end": "shield_mode",
	"channel.goal.begin": "goals",
	"channel.goal.progress": "goals",
	"channel.goal.end": "goals",
	"user.whisper.message": "whisper_received",
	"channel.shoutout.create": "shoutout_create",
	"channel.shoutout.receive": "shoutout_received",
}


func generate(definitions: Array[TwitchEventsubDefinitionInfo]) -> void:
	# A failed fetch or a docs layout change leaves the parser with nothing. Writing that out would
	# replace the checked-in definitions with an empty stub, so bail instead.
	if definitions.is_empty():
		push_error("No subscription types were parsed - keeping the existing %s untouched." % OUTPUT_PATH)
		return

	for info: TwitchEventsubDefinitionInfo in definitions:
		info.script_name = _resolve_script_name(info.value)

	var ordered: Array[TwitchEventsubDefinitionInfo] = _preserve_existing_order(definitions)

	var code: String = _header_code()
	code += _enum_code(ordered)
	code += _fields_code()
	for info: TwitchEventsubDefinitionInfo in ordered:
		code += _static_var_code(info) + "\n"
	code += "\n"
	code += _dict_code("ALL", ordered, "Type.%s: %s", "## Returns all supported subscriptions")
	code += "\n"
	code += _dict_code("BY_NAME", ordered, "%s.value: %s", "## Returns all supported subscriptions by name")

	write_output_file(OUTPUT_PATH, code)
	print("Eventsub definitions regenerated, you can find them under: %s" % OUTPUT_PATH)


## Type is an exported enum on TwitchEventsubConfig, so Godot serializes it into .tres/.tscn files as
## a plain int. Reordering the enum would silently repoint every saved config at a different
## subscription type, so existing entries have to keep the ordinal they already have: keep the order
## from the file we're about to overwrite and append anything new at the bottom.
func _preserve_existing_order(definitions: Array[TwitchEventsubDefinitionInfo]) -> Array[TwitchEventsubDefinitionInfo]:
	var existing_order: Array[String] = _read_existing_enum_order()
	if existing_order.is_empty(): return definitions

	var remaining: Dictionary[String, TwitchEventsubDefinitionInfo] = {}
	for info: TwitchEventsubDefinitionInfo in definitions:
		remaining[_screaming_snake(info.enum_name)] = info

	var ordered: Array[TwitchEventsubDefinitionInfo] = []
	for name: String in existing_order:
		if remaining.has(name):
			ordered.append(remaining[name])
			remaining.erase(name)
		else:
			# Twitch dropping a subscription type shifts every ordinal after it - that needs a manual
			# migration decision, so make it loud rather than silently renumbering saved configs.
			push_warning("%s is gone from the Twitch docs; removing it shifts the enum ordinals of everything after it." % name)

	for info: TwitchEventsubDefinitionInfo in definitions:
		var name: String = _screaming_snake(info.enum_name)
		if remaining.has(name):
			ordered.append(info)
			remaining.erase(name)

	return ordered


## Reads the `enum Type { ... }` entries, in order, out of the file we're regenerating.
func _read_existing_enum_order() -> Array[String]:
	if not FileAccess.file_exists(OUTPUT_PATH): return []
	var file: FileAccess = FileAccess.open(OUTPUT_PATH, FileAccess.READ)
	if file == null: return []
	var text: String = file.get_as_text()
	file.close()

	var start: int = text.find("enum Type {")
	if start == -1: return []
	var end: int = text.find("}", start)
	if end == -1: return []

	var names: Array[String] = []
	for line: String in text.substr(start, end - start).split("\n"):
		var entry: String = line.strip_edges().trim_suffix(",")
		if entry.is_empty() or entry.begins_with("enum") or entry.begins_with("#"): continue
		names.append(entry)
	return names


func _resolve_script_name(value: String) -> String:
	if OVERRIDES.has(value): return OVERRIDES[value]
	# Twitch's own type name sometimes repeats "channel_" (e.g. channel.channel_points_custom_reward...),
	# but the addon's script names don't - safe to dedupe unconditionally.
	var candidate: String = value.replace(".", "_")
	if candidate.begins_with("channel_channel_"):
		candidate = "channel_" + candidate.substr("channel_channel_".length())
	return candidate


func _header_code() -> String:
	return """@tool
extends Object

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchEventsubDefinition

## All supported subscriptions should be used in comination with get_all method as index.
"""


func _enum_code(definitions: Array[TwitchEventsubDefinitionInfo]) -> String:
	var code: String = "enum Type {\n"
	for info: TwitchEventsubDefinitionInfo in definitions:
		code += "\t%s,\n" % _screaming_snake(info.enum_name)
	code += "}\n"
	return code


func _fields_code() -> String:
	return """
## The type of itself
var type: Type
## Name within Twitch
var value: StringName
## Version defined in Twitch
var version: StringName
## Keys of the conditions it need for setup
var conditions: Array[StringName]
## Possible scopes it needs (on some of them its more then needed)
var scopes: Array[StringName]
## Link to the twitch documentation
var documentation_link: String
## The actual script that represents the return value
var response_script: Script


func _init(typ: Type, val: StringName, ver: StringName, cond: Array[StringName], scps: Array[StringName], doc_link: String, resp_script: Script):
	type = typ
	value = val
	version = ver
	conditions = cond
	scopes = scps
	documentation_link = doc_link
	response_script = resp_script

## Get a human readable name of it
func get_readable_name() -> String:
	return "%s (v%s)" % [value, version]


"""


func _static_var_code(info: TwitchEventsubDefinitionInfo) -> String:
	var name: String = _screaming_snake(info.enum_name)
	var conditions: String = _string_name_array_code(info.conditions)
	var scopes: String = _string_name_array_code(info.scopes)
	return "static var %s := TwitchEventsubDefinition.new(Type.%s, &\"%s\", &\"%s\", %s, %s, \"%s\", %s)" % [
		name, name, info.value, info.version, conditions, scopes, info.documentation_link,
		_script_class_name(info.script_name)
	]


## generated_eventsub scripts follow twitch_es_<name>.gd -> `class_name TwitchES<Name>`, so the Script
## can be referenced by its global class name, the way the hand-written file did.
func _script_class_name(script_name: String) -> String:
	var result: String = "TwitchES"
	for word: String in script_name.split("_"):
		if word.is_empty(): continue
		result += word.substr(0, 1).to_upper() + word.substr(1)
	return result


func _dict_code(dict_name: String, definitions: Array[TwitchEventsubDefinitionInfo], entry_format: String, doc: String) -> String:
	var value_type: String = "TwitchEventsubDefinition.Type" if dict_name == "ALL" else "StringName"
	var code: String = "%s\nstatic var %s: Dictionary[%s, TwitchEventsubDefinition] = {\n" % [
		doc, dict_name, value_type
	]
	for info: TwitchEventsubDefinitionInfo in definitions:
		var name: String = _screaming_snake(info.enum_name)
		code += "\t" + (entry_format % [name, name]) + ",\n"
	code += "}\n"
	return code


func _string_name_array_code(values: Array[String]) -> String:
	if values.is_empty(): return "[]"
	var parts: PackedStringArray = []
	for value in values: parts.append("&\"%s\"" % value)
	return "[%s]" % ",".join(parts)


# Deliberately not String.to_snake_case().to_upper(): that splits a trailing version digit off its
# letter (e.g. "V2" -> "V_2"), but Twitch/Twitcher naming keeps them glued ("CHANNEL_MODERATE_V2").
func _screaming_snake(pascal_case_name: String) -> String:
	var result: String = ""
	for i in pascal_case_name.length():
		var c: String = pascal_case_name[i]
		if c == c.to_upper() and c != c.to_lower() and i > 0 and pascal_case_name[i - 1] != pascal_case_name[i - 1].to_upper():
			result += "_"
		result += c.to_upper()
	return result


func write_output_file(file_output: String, content: String) -> void:
	var file: FileAccess = FileAccess.open(file_output, FileAccess.WRITE)
	if file == null:
		var error_message: String = error_string(FileAccess.get_open_error())
		push_error("Failed to open output file: %s\n%s" % [file_output, error_message])
		return
	file.store_string(content)
	file.flush()
	file.close()
