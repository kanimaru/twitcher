@icon("./assets/chat-icon.svg")
extends Node

## Direct access to the chat for one specific channel
## Usefull when using multiple channels otherwise TwitchIRC has everything you need
## Partly deprecated will change to eventsub solution
class_name TwitchIrcChannel

## when a chat message in this channel got received
signal message_received(from_user: String, message: String, tags: TwitchTags.Message);

## Sent when the bot joins a channel or sends a PRIVMSG message.
signal user_state_received(tags: TwitchTags.Userstate)

## Sent when the bot joins a channel or when the channel’s chat settings change.
signal room_state_received(tags: TwitchTags.Roomstate)

## Called when the bot joined the channel or atleast get the channel informations.
signal has_joined();

## Called when thie bot left the channel.
signal has_left();

@export var twitch_service: TwitchService
@export var channel_name: String:
	get: return channel_name.to_lower();

var user_state: TwitchTags.Userstate;
var room_state: TwitchTags.Roomstate:
	set(val):
		room_state = val;
		if !joined && val != null:
			joined = true;
			has_joined.emit();

var joined: bool;
var irc: TwitchIRC;


func _enter_tree() -> void:
	_enter_channel()


func _enter_channel() -> void:
	if irc == null: return;
	irc.add_channel(self);


func _ready() -> void:
	irc = twitch_service.irc
	irc.received_privmsg.connect(_on_message_received);
	irc.received_roomstate.connect(_on_roomstate_received);
	irc.received_userstate.connect(_on_userstate_received);
	_enter_channel()


func _exit_tree() -> void:
	irc.remove_channel(self);


func _on_message_received(channel: String, from_user: String, message: String, tags: TwitchTags.PrivMsg):
	if channel_name != channel: return;
	var message_tag = TwitchTags.Message.from_priv_msg(tags);
	message_tag.badges = await _load_badges(message_tag.badges, message_tag.room_id)
	message_tag.emotes = await _load_emotes(message_tag.emotes)
	message_received.emit(from_user, message, message_tag);


func _load_badges(badges: String, room_id: String) -> Array[SpriteFrames]:
	var badge_composite : Array[String] = [];
	for badge in badges.split(",", false):
		badge_composite.append(badge);

	var result = await(twitch_service.get_badges(badge_composite, room_id))
	var sprite_frames : Array[SpriteFrames] = [];
	for sprite_frame in result.values():
		sprite_frames.append(sprite_frame);
	return sprite_frames;


func _load_emotes(emotes: String) -> Array[TwitchIRC.EmoteLocation]:
	var locations : Array[TwitchIRC.EmoteLocation] = [];
	var emotes_to_load : Array[String] = [];
	if emotes != null && emotes != "":
		for emote in emotes.split("/", false):
			var data : Array = emote.split(":");
			for d in data[1].split(","):
				var start_end = d.split("-");
				locations.append(TwitchIRC.EmoteLocation.new(data[0], int(start_end[0]), int(start_end[1])));
				emotes_to_load.append(data[0]);
	locations.sort_custom(Callable(TwitchIRC.EmoteLocation, "smaller"));

	var emotes_definition: Dictionary = await twitch_service.icon_loader.get_emotes(emotes_to_load);
	for emote_location: TwitchIRC.EmoteLocation in locations:
		emote_location.sprite_frames = emotes_definition[emote_location.id];

	return locations;


func _on_roomstate_received(channel: String, tags: TwitchTags.Roomstate):
	if channel != channel_name: return;
	room_state = tags;
	room_state_received.emit(room_state);


func _on_userstate_received(channel: String, tags: TwitchTags.Userstate):
	if channel != channel_name: return;
	user_state = tags;
	user_state_received.emit(user_state);


func chat(message: String) -> void:
	await is_joined();
	twitch_service.chat(message, channel_name);


func is_joined() -> void:
	if not joined: await has_joined;


func leave() -> void:
	room_state = null
	joined = false;
	has_left.emit();
