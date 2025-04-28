@icon("res://addons/twitcher/assets/command-icon.svg")
extends TwitchCommand

class_name TwitchCommandHelp

## Used to determine the Sender User if empty and to send the message back
@export var twitch_api: TwitchAPI
## Sender User that will send the answers on the command. Can be empty then the current user will be used
@export var sender_user: TwitchUser

var _current_user: TwitchUser


func _ready() -> void:
	if command == "": command = "help"
	
	command_received.connect(_on_command_receive)
	if twitch_api == null: twitch_api = TwitchAPI.instance
	if twitch_api == null: 
		push_error("Command is missing TwitchAPI to answer!")
		return
	
	var response: TwitchGetUsers.Response = await twitch_api.get_users(TwitchGetUsers.Opt.new())
	_current_user = response.data[0]
	if sender_user == null: sender_user = _current_user
	
	
func _on_command_receive(from_username: String, info: TwitchCommandInfo, args: PackedStringArray) -> void:
	if info.original_message is TwitchChatMessage:
		var help_message: String = _generate_help_message(args, false)
		var chat_message: TwitchChatMessage = info.original_message as TwitchChatMessage
		var message_body: TwitchSendChatMessage.Body = TwitchSendChatMessage.Body.new()
		message_body.broadcaster_id = chat_message.broadcaster_user_id
		message_body.sender_id = sender_user.id
		message_body.message = help_message
		message_body.reply_parent_message_id = chat_message.message_id
		twitch_api.send_chat_message(message_body)
	else:
		var help_message: String = _generate_help_message(args, true)
		var message: Dictionary = info.original_message
		if message["to_user_id"] != _current_user.id:
			push_error("Can't answer the whisper message receiver is not the user that will be used as sender!")
			return
		var message_body: TwitchSendWhisper.Body = TwitchSendWhisper.Body.new()
		message_body.message = help_message
		twitch_api.send_whisper(message_body, message["to_user_id"], message["from_user_id"])
		
		
func _generate_help_message(args: Array[String], whisper_only: bool) -> String:
	var message: String = ""
	var show_details: bool = not args.is_empty()
		
	for command in TwitchCommand.ALL_COMMANDS:
		if command == self: continue
		var should_be_added: bool = command.where == TwitchCommand.WhereFlag.ANYWHERE \
			|| command.where == TwitchCommand.WhereFlag.WHISPER && whisper_only \
			|| command.where == TwitchCommand.WhereFlag.CHAT && not whisper_only
	
		if not args.is_empty():
			should_be_added = should_be_added && _is_command_in_args(command, args)
		
		if should_be_added:
			if show_details:
				message += "[%s%s - %s] " % [command.command_prefixes[0], command.command, command.description]
			else:
				message += "%s%s, " % [command.command_prefixes[0], command.command]
	
	if message == "":
		return "No commands registered"
	elif not show_details:
		message = message.trim_suffix(", ")
		message = "List of all Commands: %s | You can use '!help COMMAND' for details!" % message
	return message
	

func _is_command_in_args(command: TwitchCommand, args: Array[String]) -> bool:
	for arg in args:
		if command.command == arg:
			return true
		if command.aliases.has(arg):
			return true
	return false
		
