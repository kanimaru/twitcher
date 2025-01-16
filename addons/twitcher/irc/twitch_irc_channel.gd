@icon("./assets/chat-icon.svg")
extends Node

## Direct access to the chat for one specific channel
## Usefull when using multiple channels otherwise TwitchIRC has everything you need
## Deprecated Eventsub solution is prefred with `TwitchChat` Node!
## This one exists only for tracking user join and leave events.
class_name TwitchIrcChannel

static var _log: TwitchLogger = TwitchLogger.new("TwitchIrcChannel")

## when a chat message in this channel got received
signal message_received(from_user: String, message: String, tags: TwitchTags.Message)

## Sent when the bot joins a channel or sends a PRIVMSG message.
signal user_state_received(tags: TwitchTags.Userstate)

## Sent when the bot joins a channel or when the channel’s chat settings change.
signal room_state_received(tags: TwitchTags.Roomstate)

## Called when the bot joined the channel or atleast get the channel informations.
signal has_joined()

## Called when thie bot left the channel.
signal has_left()

@export var twitch_service: TwitchService
@export var channel_name: StringName:
	set = _update_channel_name,
	get = _get_channel_name

var user_state: TwitchTags.Userstate
var room_state: TwitchTags.Roomstate:
	set(val):
		room_state = val
		if !joined && val != null:
			joined = true
			has_joined.emit()

var joined: bool
var irc: TwitchIRC


func _enter_tree() -> void:
	_enter_channel()


func _get_channel_name() -> StringName:
	return channel_name.to_lower()


func _update_channel_name(new_name: StringName) -> void:
	if channel_name != "": irc.remove_channel(self)
	channel_name = new_name
	_enter_channel()


func _enter_channel() -> void:
	if irc == null: return
	if channel_name == &"":
		_log.e("No channel is specified to join. The channel name can be set on the TwitchIrcChannel node.")
		return
	irc.add_channel(self)


func _ready() -> void:
	irc = twitch_service.irc
	irc.received_privmsg.connect(_on_message_received)
	irc.received_roomstate.connect(_on_roomstate_received)
	irc.received_userstate.connect(_on_userstate_received)
	_enter_channel()


func _exit_tree() -> void:
	irc.remove_channel(self)


func _on_message_received(channel: StringName, from_user: String, message: String, tags: TwitchTags.PrivMsg):
	if channel_name != channel: return
	var message_tag = TwitchTags.Message.from_priv_msg(tags)
	await message_tag.load_sprites(twitch_service)
	message_received.emit(from_user, message, message_tag)


func _on_roomstate_received(channel: StringName, tags: TwitchTags.Roomstate):
	if channel != channel_name: return
	room_state = tags
	room_state_received.emit(room_state)


func _on_userstate_received(channel: StringName, tags: TwitchTags.Userstate):
	if channel != channel_name: return
	user_state = tags
	user_state_received.emit(user_state)


func chat(message: String) -> void:
	await is_joined()
	irc.chat(message, channel_name)


func is_joined() -> void:
	if not joined: await has_joined


func leave() -> void:
	room_state = null
	joined = false
	has_left.emit()
