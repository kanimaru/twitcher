@icon("./assets/command-icon.svg")
extends Twitcher

# Untested yet
## A single command like !lurk 
class_name TwitchCommand

static var command_prefixes : Array[String] = ["!"]

## Called when the command got received in the right format
signal command_received(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

## Called when the command got received in the wrong format
signal received_invalid_command(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

## Name Command
@export var command: String
## Optional names of commands
@export var aliases: Array[String]
## Description for the user
@export_multiline var description: String

## Minimal amount of argument 0 means no argument needed
@export var args_min: int = 0
## Max amount of arguments -1 means infinite
@export var args_max: int = -1
## Wich role of user is allowed to use it
@export var permission_level : TwitchCommandHandler.PermissionFlag = TwitchCommandHandler.PermissionFlag.EVERYONE
## Where is it allowed to use chat or whisper or both
@export var where : TwitchCommandHandler.WhereFlag = TwitchCommandHandler.WhereFlag.CHAT
## All allowed users empty array means everyone
@export var allowed_users: Array[String] = []
## All chatrooms where the command listens to
@export var listen_to_chatrooms : Array[String] = []

## The eventsub to listen for chatmessages
@export var eventsub: TwitchEventsub

static func create(
		eventsub: TwitchEventsub,
		cmd_name : String,
		callable : Callable,
		min_args : int = 0,
		max_args : int = 0,
		permission_level : int = TwitchCommandHandler.PermissionFlag.EVERYONE,
		where : int = TwitchCommandHandler.WhereFlag.CHAT,
		listen_to_chatrooms : Array[String] = []) -> TwitchCommand:
	var command := TwitchCommand.new()
	command.eventsub = eventsub
	command.command = cmd_name
	command.command_received.connect(callable)
	command.args_min = min_args
	command.args_max = max_args
	command.permission_level = permission_level
	command.where = where
	return command


func _enter_tree() -> void:
	eventsub.event.connect(_on_event)


func _exit_tree() -> void:
	eventsub.event.disconnect(_on_event)


func _on_event(type: StringName, data: Dictionary) -> void:
	if type != TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE.value:
		if where & TwitchCommandHandler.WhereFlag.CHAT != TwitchCommandHandler.WhereFlag.CHAT: return
		var message : String = data.message.text
		var username : String = data.chatter_user_name
		var channel_name : String = data.broadcaster_user_name
		if not _should_handle(message, username): return
		var chat_message = TwitchChatMessage.from_json(data)
		_handle_command(username, message, channel_name, chat_message)
		
	if type != TwitchEventsubDefinition.USER_WHISPER_MESSAGE.value:
		if where & TwitchCommandHandler.WhereFlag.WHISPER != TwitchCommandHandler.WhereFlag.WHISPER: return
		var message : String = data.whisper.text
		var from_user : String = data.from_user_login
		if not _should_handle(message, from_user): return
		_handle_command(from_user, message, data.to_user_login, data)


func add_alias(alias: String) -> void:
	aliases.append(alias)


func _should_handle(message: String, username: String) -> bool:
	if not allowed_users.is_empty() && not allowed_users.has(username): return false
	if not command_prefixes.has(message.left(1)): return false

	# remove the command symbol in front
	message = message.right(-1)
	var split : PackedStringArray = message.split(" ", true, 1)
	var current_command := split[0]
	if current_command != command && not aliases.has(current_command): return false
	return true


func _handle_command(from_username: String, raw_message: String, to_user: String, data: Variant) -> void:	
	# remove the command symbol in front
	raw_message = raw_message.right(-1)
	var cmd_msg = raw_message.split(" ", true, 1)
	var message = ""
	var arg_array : PackedStringArray = []
	var command = cmd_msg[0]
	var info = TwitchCommandInfo.new(self, to_user, from_username, arg_array, data)
	if cmd_msg.size() > 1:
		message = cmd_msg[1]
		arg_array.append_array(message.split(" "))
		var to_less_arguments = arg_array.size() < args_min
		var to_much_arguments = arg_array.size() > args_max
		if to_much_arguments && args_max != -1 || to_less_arguments:
			received_invalid_command.emit(from_username, info, arg_array)
			return
		var premission_required = permission_level != 0
		if premission_required:
			var user_perm_flags = _get_perm_flag_from_tags(data)
			if user_perm_flags & permission_level == 0:
				received_invalid_command.emit(from_username, info, arg_array)
				return
	if arg_array.size() == 0:
		if args_min > 0:
			received_invalid_command.emit(from_username, info, arg_array)
			return

		var empty_args: Array[String] = []
		if args_max > 0:
			command_received.emit(from_username, info, empty_args)
		else:
			command_received.emit(from_username, info, empty_args)
	else:
		command_received.emit(from_username, info, arg_array)


func _get_perm_flag_from_tags(data : Variant) -> int:
	var flag: int = 0
	if data is TwitchChatMessage:
		var message: TwitchChatMessage = data as TwitchChatMessage
		for badge in message.badges:
			match badge.set_id:
				"broadcaster": flag += TwitchCommandHandler.PermissionFlag.STREAMER
				"vip": flag += TwitchCommandHandler.PermissionFlag.VIP
				"moderator": flag += TwitchCommandHandler.PermissionFlag.MOD
				"subscriber": flag += TwitchCommandHandler.PermissionFlag.SUB
	return flag
