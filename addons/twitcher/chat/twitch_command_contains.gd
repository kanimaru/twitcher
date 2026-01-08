@tool
@icon("res://addons/twitcher/assets/command-icon.svg")
extends TwitchCommandBase

## A command that checks for chat messages to contains specific words or phrases.
## Arguments are the words / phrases that was found.
class_name TwitchCommandContains

## Words or phrases that triggers this command
@export var contains: Array[String] = []:
	set = _update_contains

## When all words / phrases from contains should match
@export var match_all: bool

## Matches on full words instead of somewhere in the string
@export var match_word: bool
	
func _update_contains(val: Array[String]) -> void:
	contains = val
	update_configuration_warnings()


func _handle_command(info: TwitchCommandInfo) -> void:
	if not _can_handle_command(info):
		return
		
	var matches_found: bool = false
	var message = info.text_message
	
	# Handle the case where the list is empty (usually implies no match possible)
	if contains.is_empty():
		matches_found = false
	else:
		matches_found = true if match_all else false
		for contain in contains:
			var is_current_match: bool = false
			if match_word:
				var regex = RegEx.new()
				var pattern = "\\b" + RegexUtil.escape(contain) + "\\b"
				if case_insensitive: pattern = "(?i)" + pattern
				regex.compile(pattern)
				is_current_match = regex.search(message) != null
			else:
				if case_insensitive:
					is_current_match = message.findn(contain) != -1
				else:
					is_current_match = message.contains(contain)
			
			if is_current_match: info.arguments.append(contain)
			
			if match_all:
				if not is_current_match:
					matches_found = false
					break
			else:
				if is_current_match:
					matches_found = true
					break

	if matches_found:
		command_received.emit(info.username, info, info.arguments)


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if contains.is_empty():
		result.append("You need words or phrases in contains.")
	return result
