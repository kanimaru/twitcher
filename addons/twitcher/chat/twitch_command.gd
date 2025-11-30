@icon("res://addons/twitcher/assets/command-icon.svg")
extends Twitcher

# Untested yet
## A single command like !lurk 
class_name TwitchCommand

## Constant to convert from seconds to milliseconds
const S_TO_MS: int = 1000

static var ALL_COMMANDS: Array[TwitchCommand] = []

## Called when the command got received in the right format
signal command_received(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

## Called when the command got received in the wrong format
signal received_invalid_command(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

## Called when the user tries to use the command that is still on cooldown (remaining cooldown in seconds)
signal cooldown(from_username: String, info: TwitchCommandInfo, args: PackedStringArray, cooldown_remaining_in_s: float)

## Required permission to execute the command
enum PermissionFlag {
	EVERYONE = 0,
	VIP = 1,
	SUB = 2,
	MOD = 4,
	STREAMER = 8,
	MOD_STREAMER = 12, # Mods and the streamer
	NON_REGULAR = 15 # Everyone but regular viewers
}

## Where the command should be accepted
enum WhereFlag {
	CHAT = 1,
	WHISPER = 2,
	ANYWHERE = 3
}

@export var command_prefixes : Array[String] = ["!"]
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
@export var permission_level: PermissionFlag = PermissionFlag.EVERYONE
## Where is it allowed to use chat or whisper or both
@export var where: WhereFlag = WhereFlag.CHAT
## All allowed users empty array means everyone
@export var allowed_users: Array[String] = []
## All chatrooms where the command listens to
@export var listen_to_chatrooms: Array[String] = []
## Determines if the aliases and commands should be case sensitive or not
@export var case_insensitive: bool = true
## Cooldown per user
@export var user_cooldown: float = 0
## Global cooldown for the command
@export var global_cooldown: float = 0

## Eventsub to listen for the chat messages. (Can be empty will automatically look for first [TwitchEventsub] 
## in the scene tree)
@export var eventsub: TwitchEventsub

## Cooldowns per user Key: Username | Value: Time until it can be used again
var _user_cooldowns: Dictionary[String, float] = {}
## Time until it can be used again
var _global_cooldown: float

static func create(
		eventsub: TwitchEventsub,
		cmd_name: String,
		callable: Callable,
		min_args: int = 0,
		max_args: int = 0,
		permission_level: int = PermissionFlag.EVERYONE,
		where: int = WhereFlag.CHAT,
		allowed_users: Array[String] = [],
		listen_to_chatrooms: Array[String] = [],
		case_insensitive: bool = true) -> TwitchCommand:
	var command := TwitchCommand.new()
	command.eventsub = eventsub
	command.command = cmd_name
	command.command_received.connect(callable)
	command.args_min = min_args
	command.args_max = max_args
	command.permission_level = permission_level
	command.where = where
	command.allowed_users = allowed_users
	command.listen_to_chatrooms = listen_to_chatrooms
	command.case_insensitive = case_insensitive
	return command


func _enter_tree() -> void:
	if eventsub == null: eventsub = TwitchEventsub.instance
	if eventsub != null:
		eventsub.event.connect(_on_event)
	ALL_COMMANDS.append(self)
	
	for prefix: String in command_prefixes:
		if prefix.length() > 1:
			push_error("TwitchCommand supports only 1 character for command prefix. '%s' is used by %s" % [prefix, get_path()])


func _exit_tree() -> void:
	if eventsub != null:
		eventsub.event.disconnect(_on_event)
	ALL_COMMANDS.erase(self)


func _on_event(type: StringName, data: Dictionary) -> void:
	if type == TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE.value:
		if where & WhereFlag.CHAT != WhereFlag.CHAT: return
		var message : String = data.message.text
		var username : String = data.chatter_user_login
		var channel_name : String = data.broadcaster_user_login
		if not _should_handle(message, username, channel_name): return
		var chat_message = TwitchChatMessage.from_json(data)
		_handle_command(username, message, channel_name, chat_message)
		
	if type == TwitchEventsubDefinition.USER_WHISPER_MESSAGE.value:
		if where & WhereFlag.WHISPER != WhereFlag.WHISPER: return
		var message : String = data.whisper.text
		var from_user : String = data.from_user_login
		if not _should_handle(message, from_user, from_user): return
		_handle_command(from_user, message, data.to_user_login, data)


func add_alias(alias: String) -> void:
	aliases.append(alias)


func _should_handle(message: String, username: String, channel_name: String) -> bool:
	if not listen_to_chatrooms.is_empty() && not listen_to_chatrooms.has(channel_name): return false
	if not allowed_users.is_empty() && not allowed_users.has(username): return false
	if not command_prefixes.has(message.left(1)): return false

	# remove the command symbol in front
	message = message.right(-1)
	var split: PackedStringArray = message.split(" ", true, 1)
	var current_command: String = split[0] 
	var alias_compare_function: Callable = func(cmd) -> bool:
		if case_insensitive:
			return current_command.nocasecmp_to(cmd) == 0
		else:
			return current_command.casecmp_to(cmd) == 0
	
	var is_alias: bool = aliases.any(alias_compare_function)
	var is_command: bool = alias_compare_function.call(command)

	return is_command || is_alias
	


func _handle_command(from_username: String, raw_message: String, to_user: String, data: Variant) -> void:	
	# remove the command symbol in front
	raw_message = raw_message.right(-1)
	var cmd_msg = raw_message.split(" ", true, 1)
	var message = ""
	var arg_array : PackedStringArray = []
	var command = cmd_msg[0]
	var info = TwitchCommandInfo.new(self, to_user, from_username, arg_array, data)
	
	# Handle Permission check
	var premission_required = permission_level != 0
	if premission_required:
		var user_perm_flags = _get_perm_flag_from_tags(data)
		if user_perm_flags & permission_level == 0:
			received_invalid_command.emit(from_username, info, arg_array)
			return
	
	# Handle Argument parsing
	if cmd_msg.size() > 1:
		message = cmd_msg[1]
		arg_array.append_array(message.split(" ", false))
		var to_less_arguments = arg_array.size() < args_min
		var to_much_arguments = arg_array.size() > args_max
		if to_much_arguments && args_max != -1 || to_less_arguments:
			received_invalid_command.emit(from_username, info, arg_array)
			return
	if arg_array.size() == 0 && args_min > 0:
		received_invalid_command.emit(from_username, info, arg_array)
		return
		
	# Handle Cooldowns
	if user_cooldown > 0:
		var current_user_cooldown: float = _user_cooldowns.get_or_add(from_username, 0)
		if current_user_cooldown >= Time.get_ticks_msec():
			var cooldown_left: float = (current_user_cooldown - Time.get_ticks_msec()) / 1000
			cooldown.emit(from_username, info, arg_array, cooldown_left)
			return
		_user_cooldowns.set(from_username, Time.get_ticks_msec() + (user_cooldown * S_TO_MS))
	
	if global_cooldown > 0:
		if _global_cooldown >= Time.get_ticks_msec():
			var cooldown_left: float = (_global_cooldown - Time.get_ticks_msec()) / 1000
			cooldown.emit(from_username, info, arg_array, cooldown_left)
			return
		_global_cooldown = Time.get_ticks_msec() + (global_cooldown * S_TO_MS)
	
	# Executing the command
	if arg_array.size() == 0:
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
				"broadcaster": flag += PermissionFlag.STREAMER
				"vip": flag += PermissionFlag.VIP
				"moderator": flag += PermissionFlag.MOD
				"subscriber": flag += PermissionFlag.SUB
	return flag
