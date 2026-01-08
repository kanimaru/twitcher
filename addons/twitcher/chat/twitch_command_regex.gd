@tool
@icon("res://addons/twitcher/assets/command-icon.svg")
extends TwitchCommandBase

## A command that applies a regex to every message (be carefully for the performance regex can be
## imperformant)
class_name TwitchCommandRegex

## The regex result information
const META_REGEX_RESULT: StringName = &"twitch_command_regex_regex_result"

## Regex it will listen for and trigger
@export var regex_to_listen: String:
	set = _update_regex_to_listen

var _regex : RegEx


func _update_regex_to_listen(val: String) -> void:
	regex_to_listen = val
	if val:
		var pattern = val
		if case_insensitive: pattern = "(?i)" + pattern
		_regex = RegEx.create_from_string(pattern)
		
	update_configuration_warnings()


func _should_handle(info: TwitchCommandInfo) -> bool:
	if not super._should_handle(info): return false
	
	# Save it to use it later for arguments
	var result = _regex.search(info.text_message)
	info.set_meta(META_REGEX_RESULT, result)
	if not result: return false
	return true
	
	

func _handle_command(info: TwitchCommandInfo) -> void:
	if not _can_handle_command(info):
		received_invalid_command.emit(info.username, info, info.arguments)
		return
		
	var result: RegExMatch = info.get_meta(META_REGEX_RESULT)
	if result:
		for group in result.get_group_count() + 1:
			info.arguments.append(result.get_string(group))
		command_received.emit(info.username, info, info.arguments)


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if not regex_to_listen:
		result.append("Regex is required that this command works.")
	if _regex and not _regex.is_valid():
		result.append("The regex is invalid.")
	return result
		
