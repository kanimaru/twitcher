@icon("./assets/command-icon.svg")
extends Node

class_name TwitchCommand

static var command_prefixes : Array[String] = ["!"];

## Called when the command got received in the right format
signal command_received(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

## Called when the command got received in the wrong format
signal received_invalid_command(from_username: String, info: TwitchCommandInfo, args: PackedStringArray);

# Name Command
@export var command: String
# Optional names of commands
@export var aliases: Array[String]
# Description for the user
@export_multiline var description: String

# Minimal amount of argument 0 means no argument needed
@export var args_min: int = 0
# Max amount of arguments -1 means infinite
@export var args_max: int = -1
# Wich role of user is allowed to use it
@export var permission_level : TwitchCommandHandler.PermissionFlag = TwitchCommandHandler.PermissionFlag.EVERYONE
# Where is it allowed to use chat or whisper or both
@export var where : TwitchCommandHandler.WhereFlag = TwitchCommandHandler.WhereFlag.CHAT
# All allowed users empty array means everyone
@export var allowed_users: Array[String] = []

@export var irc: TwitchIRC

static func create(
		irc: TwitchIRC,
		cmd_name : String,
		callable : Callable,
		min_args : int = 0,
		max_args : int = 0,
		permission_level : int = TwitchCommandHandler.PermissionFlag.EVERYONE,
		where : int = TwitchCommandHandler.WhereFlag.CHAT) -> TwitchCommand:
	var command := TwitchCommand.new()
	command.irc = irc
	command.command = cmd_name
	# TODO: TEST THIS ONE probably buggy
	command.command_received.connect(on_command_recreived.bind(callable))
	command.args_min = min_args
	command.args_max = max_args
	command.permission_level = permission_level
	command.where = where
	return command


static func on_command_recreived(from_username: String, info: TwitchCommandInfo, args: PackedStringArray, callable: Callable):
	callable.call(info)


func _enter_tree() -> void:
	irc.received_privmsg.connect(handle_chat_command)
	irc.received_whisper.connect(handle_whisper_command)


func _exit_tree() -> void:
	irc.received_privmsg.disconnect(handle_chat_command)
	irc.received_whisper.disconnect(handle_whisper_command)


func add_alias(alias: String) -> void:
	aliases.append(alias)


func _should_handle(message: String, username: String) -> bool:
	if not allowed_users.is_empty() && not allowed_users.has(username): return false
	if not command_prefixes.has(message.left(1)): return false

	# remove the command symbol in front
	message = message.right(-1);
	var split : PackedStringArray = message.split(" ", true, 1)
	var current_command := split[0]
	if current_command != command && not aliases.has(current_command): return false
	return true


## Handles all the commands that will be send in chat rooms
func handle_chat_command(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg) -> void:
	if where & TwitchCommandHandler.WhereFlag.CHAT != TwitchCommandHandler.WhereFlag.CHAT: return
	if not _should_handle(message, username): return
	_handle_command(message, channel_name, username, tags);


## Handles all the commands that will be send in whisper message
func handle_whisper_command(from_user: String, to_user: String, message: String, tags: TwitchTags.Whisper) -> void:
	if where & TwitchCommandHandler.WhereFlag.WHISPER != TwitchCommandHandler.WhereFlag.WHISPER: return
	if not _should_handle(message, from_user): return
	_handle_command(message, "", from_user, tags);


func _handle_command(raw_message: String, channel_name: String, username: String, tags: Variant) -> void:
	# remove the command symbol in front
	raw_message = raw_message.right(-1);
	var cmd_msg = raw_message.split(" ", true, 1);
	var message = "";
	var arg_array : PackedStringArray = PackedStringArray();
	var info = TwitchCommandInfo.new(command, self, message, channel_name, username, tags, arg_array);
	if (cmd_msg.size() > 1):
		message = cmd_msg[1];
		arg_array.append_array(message.split(" "));
		var to_less_arguments = arg_array.size() < args_min;
		var to_much_arguments = arg_array.size() > args_max;
		if(to_much_arguments && args_max != -1 || to_less_arguments):
			received_invalid_command.emit(channel_name, username, null, arg_array, tags);
			return
		var premission_required = permission_level != 0
		if(premission_required):
			var user_perm_flags = _get_perm_flag_from_tags(tags)
			if(user_perm_flags & permission_level == 0):
				received_invalid_command.emit(username, info, arg_array);
				return
	if(arg_array.size() == 0):
		if (args_min > 0):
			received_invalid_command.emit(username, info, arg_array);
			return

		var empty_args: Array[String] = []
		if (args_max > 0):
			command_received.emit(username, info, empty_args)
		else:
			command_received.emit(username, info, empty_args)
	else:
		command_received.emit(username, info, arg_array)


func _get_perm_flag_from_tags(tags : Variant) -> int:
	var flag: int = 0
	var badges = tags.get("badges")
	if(badges != null):
		for badge in badges.split(","):
			if(badge.begins_with("vip")):
				flag += TwitchCommandHandler.PermissionFlag.VIP
			if(badge.begins_with("broadcaster")):
				flag += TwitchCommandHandler.PermissionFlag.STREAMER
	if(tags.get("mod", "0") == "1"):
		flag += TwitchCommandHandler.PermissionFlag.MOD
	if(tags.get("subscriber", "0") == "1"):
		flag += TwitchCommandHandler.PermissionFlag.SUB
	return flag
