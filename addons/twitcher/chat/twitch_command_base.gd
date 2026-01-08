@icon("res://addons/twitcher/assets/command-icon.svg")
@abstract
extends Twitcher

## A single command like !lurk 
class_name TwitchCommandBase

## Constant to convert from seconds to milliseconds
const S_TO_MS = 1000

static var ALL_COMMANDS: Array[TwitchCommandBase] = []

## Called when the command got received in the right format
signal command_received(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

## Called when the command got received in the wrong format
signal received_invalid_command(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

## Called when the command got received with not the right permissions
signal invalid_permission(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

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

## Name Command
@export var command: String
## Description for the user
@export_multiline var description: String

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

## The eventsub to listen for chatmessages
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
	

func _exit_tree() -> void:
	if eventsub != null:
		eventsub.event.disconnect(_on_event)
	ALL_COMMANDS.erase(self)


## TODO ADD REGEX to data
## CHECK REGEX in is should_handle pass it to data

func _on_event(type: StringName, data: Dictionary) -> void:
	if type == TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE.value:
		if where & WhereFlag.CHAT != WhereFlag.CHAT: return
		var message : String = data.message.text
		var username : String = data.chatter_user_login
		var channel_name : String = data.broadcaster_user_login
		var chat_message = TwitchChatMessage.from_json(data)
		var info: TwitchCommandInfo = TwitchCommandInfo.new(self, channel_name, username, chat_message, message)
		if not _should_handle(info): return
		_handle_command(info)
		
	if type == TwitchEventsubDefinition.USER_WHISPER_MESSAGE.value:
		if where & WhereFlag.WHISPER != WhereFlag.WHISPER: return
		var message : String = data.whisper.text
		var from_user : String = data.from_user_login
		var to_user : String = data.to_user_login
		var info: TwitchCommandInfo = TwitchCommandInfo.new(self, to_user, from_user, data, message)
		if not _should_handle(info): return
		_handle_command(info)


## Preflight check before the message gets actually parsed to save resources not to confuse with _can_handle_command
func _should_handle(info: TwitchCommandInfo) -> bool:
	if not listen_to_chatrooms.is_empty() && not listen_to_chatrooms.has(info.channel_name): return false
	if not allowed_users.is_empty() && not allowed_users.has(info.username): return false
	return true


func _has_permission(from_username: String, data: Variant) -> bool:
	# Handle Permission check
	var premission_required = permission_level != 0
	if premission_required:
		var user_perm_flags = _get_perm_flag_from_tags(data)
		if user_perm_flags & permission_level == 0:
			return false
	return true


func get_user_cooldown(from_username: String) -> bool:
	var current_user_cooldown: float = _user_cooldowns.get_or_add(from_username, 0)
	if current_user_cooldown >= Time.get_ticks_msec():
		var cooldown_left: float = (current_user_cooldown - Time.get_ticks_msec()) / 1000
		return cooldown_left
	return 0


func is_on_cooldown(from_username: String) -> bool:
	if user_cooldown > 0:
		var cooldown_left: float = get_user_cooldown(from_username)
		if cooldown_left > 0:
			return true
		_user_cooldowns.set(from_username, Time.get_ticks_msec() + (user_cooldown * S_TO_MS))
	return false


func get_globalcooldown() -> float:
	var cooldown_left: float = (_global_cooldown - Time.get_ticks_msec()) / 1000
	return cooldown_left


func is_on_globalcooldown() -> bool:
	if global_cooldown > 0:
		if _global_cooldown >= Time.get_ticks_msec():
			return true
		_global_cooldown = Time.get_ticks_msec() + (global_cooldown * S_TO_MS)
	return false
	

func _handle_command(info: TwitchCommandInfo) -> void:
	if _can_handle_command(info):
		command_received.emit(info.username, info, info.arguments)
	
	
## Checks if the parsed command can be handled
func _can_handle_command(info: TwitchCommandInfo) -> bool:
	if not _has_permission(info.username, info.data):
		invalid_permission.emit(info.from_username, info, info.arguments)
		return false
			
	if is_on_cooldown(info.username):
		var cooldown_left: float = get_user_cooldown(info.username)
		cooldown.emit(info.username, info, info.arguments, cooldown_left)
		return false
	
	if is_on_globalcooldown():
		var cooldown_left: float = get_globalcooldown()
		cooldown.emit(info.username, info, info.arguments, cooldown_left)
		return false
	return true


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
