@tool
extends Twitcher

## Directly response to the command with a predefined message
class_name TwitchCommandRespond

## The message that will be responded
@export_multiline var respond_message: String
## Should the bot be used to send the answer
@export var use_bot: bool = true


func _enter_tree() -> void:
	update_configuration_warnings()
	var parent: Node = get_parent()
	if parent.has_signal(&"command_received"):
		parent.command_received.connect(_on_command_received)


func _exit_tree() -> void:
	var parent: Node = get_parent()
	if parent.has_signal(&"command_received"):
		parent.command_received.disconnect(_on_command_received)


func _on_command_received(_from_username: String, info: TwitchCommandInfo, _args: PackedStringArray) -> void:
	var chat_message: TwitchChatMessage = info.original_message
	if use_bot:
		TwitchBot.chat(respond_message, chat_message.message_id)
	else:
		TwitchService.chat(respond_message, chat_message.message_id)


func _get_configuration_warnings() -> PackedStringArray:
	var parent: Node = get_parent()
	if not parent.has_signal(&"command_received"):
		return ["Parent must be a TwitchCommand type!"]
	return []
