extends RefCounted

## Direct access to the chat for one specific channel
## Usefull when using multiple channels otherwise TwitchIRC has everything you need
class_name TwitchChannel

## When the channel state got updated like (see https://dev.twitch.tv/docs/irc/tags/#roomstate-tags)
signal update(tags: Dictionary);
## when a chat message in this channel got received
signal message_received(senderdata : TwitchSenderData, msg: String);

signal joined();

var channel_name: String;
var data: Dictionary = {};
var irc: TwitchIRC;
var already_joined: bool;

func _init(channel: String, twitch_irc: TwitchIRC):
	channel_name = channel;
	irc = twitch_irc

func update_state(command: String, tags: Dictionary):
	if command == "ROOMSTATE" && !already_joined:
		already_joined = true;
		joined.emit();

	for key in tags:
		data[key] = tags[key];
	update.emit(tags);

func handle_message_received(senderdata : TwitchSenderData, message : String):
	message_received.emit(senderdata, message);

func chat(message: String) -> void:
	irc.chat(message, channel_name);

func is_joined():
	if not already_joined: await joined;
