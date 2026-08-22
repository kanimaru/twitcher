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
	for info in definitions:
		info.script_name = _resolve_script_name(info.value)

	var code: String = _header_code()
	code += _enum_code(definitions)
	code += _fields_code()
	for info in definitions:
		code += _static_var_code(info) + "\n"
	code += "\n"
	code += _dict_code("ALL", definitions, "Type.%s: %s", "## Returns all supported subscriptions")
	code += "\n"
	code += _dict_code("BY_NAME", definitions, "%s.value: %s", "## Returns all supported subscriptions by name")

	write_output_file(OUTPUT_PATH, code)
	print("Eventsub definitions regenerated, you can find them under: %s" % OUTPUT_PATH)


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

class_name TwitchEventsubDefinition

## All supported subscriptions should be used in comination with get_all method as index.
"""


func _enum_code(definitions: Array[TwitchEventsubDefinitionInfo]) -> String:
	var code: String = "enum Type {\n"
	for info in definitions:
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


func _init(typ: Type, val: StringName, ver: StringName, cond: Array[StringName], scps: Array[StringName], doc_link: String, script_name: String):
	type = typ
	value = val
	version = ver
	conditions = cond
	scopes = scps
	documentation_link = doc_link
	response_script = load("res://addons/twitcher/generated_eventsub/twitch_es_%s.gd" % script_name)

## Get a human readable name of it
func get_readable_name() -> String:
	return "%s (v%s)" % [value, version]


"""


func _static_var_code(info: TwitchEventsubDefinitionInfo) -> String:
	var name: String = _screaming_snake(info.enum_name)
	var conditions: String = _string_name_array_code(info.conditions)
	var scopes: String = _string_name_array_code(info.scopes)
	return "static var %s := TwitchEventsubDefinition.new(Type.%s, &\"%s\", &\"%s\", %s, %s, \"%s\", \"%s\")" % [
		name, name, info.value, info.version, conditions, scopes, info.documentation_link, info.script_name
	]


func _dict_code(dict_name: String, definitions: Array[TwitchEventsubDefinitionInfo], entry_format: String, doc: String) -> String:
	var value_type: String = "TwitchEventsubDefinition.Type" if dict_name == "ALL" else "StringName"
	var code: String = "%s\nstatic var %s: Dictionary[%s, TwitchEventsubDefinition] = {\n" % [
		doc, dict_name, value_type
	]
	for info in definitions:
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
