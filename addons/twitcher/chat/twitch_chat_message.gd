extends Node

class_name TwitchChatMessage

enum FragmentType {
	text = 0,
	cheermote = 1,
	emote = 2,
	mention = 3
}

const FRAGMENT_TYPES = ["text", "cheermote", "emote", "mention"]

enum EmoteFormat {
	animated = 0,
	_static = 1
}

const EMOTE_FORMATES = ["animated", "static"]

enum MessageType {
	## Normal chat message
	text = 0,
	## The default reward where the message is highlighted
	channel_points_highlighted = 1,
	## Channel points were used to send this message in sub-only mode.
	channel_points_sub_only = 2,
	## when a new user is typing for the first time
	user_intro = 3,
	## When the power up message effect was used on this message
	power_ups_message_effect = 4,
	## When a gigantified emote was posted
	power_ups_gigantified_emote = 5
}

const MESSAGE_TYPES = ["text", "channel_points_highlighted", "channel_points_sub_only", "user_intro", "power_ups_message_effect", "power_ups_gigantified_emote"]

class Message:
	## The chat message in plain text.
	var text: String
	## Ordered list of chat message fragments.
	var fragments: Array[Fragment] = []


	static func from_json(d: Dictionary, twitch_service: TwitchService) -> Message:
		var result = Message.new()
		if d.has("text") and d["text"] != null:
			result.text = d["text"]
		if d.has("fragments") and d["fragments"] != null:
			for value in d["fragments"]:
				result.fragments.append(Fragment.from_json(value, twitch_service))
		return result


class Fragment:
	## The type of message fragment. See "TwitchChatMessage.FRAGMENT_TYPE_*"
	var type: MessageType
	## Message text in fragment.
	var text: String
	## Optional. Metadata pertaining to the cheermote.
	var cheermote: Cheermote
	## Optional. Metadata pertaining to the emote.
	var emote: Emote
	## Optional. Metadata pertaining to the mention.
	var mention: Mention


	static func from_json(d: Dictionary, twitch_service: TwitchService) -> Fragment:
		var result = Fragment.new()
		if d.has("type") and d["type"] != null:
			result.type = FragmentType[d["type"]]
		if d.has("text") and d["text"] != null:
			result.text = d["text"]
		if d.has("cheermote") and d["cheermote"] != null:
			result.cheermote = Cheermote.from_json(d["cheermote"], twitch_service)
		if d.has("emote") and d["emote"] != null:
			result.emote = Emote.from_json(d["emote"], twitch_service)
		if d.has("mention") and d["mention"] != null:
			result.mention = Mention.from_json(d["mention"])
		return result


class Mention:
	## The user ID of the mentioned user.
	var user_id: String
	## The user name of the mentioned user.
	var user_name: String
	## The user login of the mentioned user.
	var user_login: String


	static func from_json(d: Dictionary) -> Mention:
		var result = Mention.new()
		if d.has("user_id") and d["user_id"] != null:
			result.user_id = d["user_id"]
		if d.has("user_name") and d["user_name"] != null:
			result.user_name = d["user_name"]
		if d.has("user_login") and d["user_login"] != null:
			result.user_login = d["user_login"]
		return result


class Cheermote:
	## The name portion of the Cheermote string that you use in chat to cheer Bits. The full Cheermote string is the concatenation of {prefix} + {number of Bits}. For example, if the prefix is “Cheer” and you want to cheer 100 Bits, the full Cheermote string is Cheer100. When the Cheermote string is entered in chat, Twitch converts it to the image associated with the Bits tier that was cheered.
	var prefix: String
	## The amount of bits cheered.
	var bits: int
	## The tier level of the cheermote.
	var tier: int

	var _twitch_service: TwitchService


	func _init(twitch_service: TwitchService) -> void:
		_twitch_service = twitch_service


	func get_sprite_frames(cheermote_definition: TwitchCheermoteDefinition) -> SpriteFrames:
		var cheer_results = await _twitch_service.media_loader.get_cheer_tier(prefix, "%s" % tier, cheermote_definition.theme, cheermote_definition.type, cheermote_definition.scale)
		return cheer_results.spriteframes


	static func from_json(d: Dictionary, twitch_service: TwitchService) -> Cheermote:
		var result = Cheermote.new(twitch_service)
		if d.has("prefix") and d["prefix"] != null:
			result.prefix = d["prefix"]
		if d.has("bits") and d["bits"] != null:
			result.bits = d["bits"]
		if d.has("tier") and d["tier"] != null:
			result.tier = d["tier"]
		return result


class Emote:
	## An ID that uniquely identifies this emote.
	var id: String
	## An ID that identifies the emote set that the emote belongs to.
	var emote_set_id: String
	## The ID of the broadcaster who owns the emote.
	var owner_id: String
	## The formats that the emote is available in. For example, if the emote is available only as a static PNG, the array contains only static. But if the emote is available as a static PNG and an animated GIF, the array contains static and animated. See: "TwitchChatMessage.EMOTE_TYPE_*"
	var format: Array[EmoteFormat] = []

	var _twitch_service: TwitchService


	func _init(twitch_service: TwitchService) -> void:
		_twitch_service = twitch_service

	## Resolves the spriteframes from this emote. Check `format` for possible formats.
	## Format: Defaults to animated when not available it uses static
	## Scale: 1, 2, 3
	func get_sprite_frames(format: String = "", scale: int = 1, dark: bool = true) -> SpriteFrames:
		var definition: TwitchEmoteDefinition = TwitchEmoteDefinition.new(id)
		if dark: definition.theme_dark()
		else: definition.theme_light()
		match scale:
			1: definition.scale_1()
			2: definition.scale_2()
			3: definition.scale_3()
			_: definition.scale_1()
		var emotes = await _twitch_service.media_loader.get_emotes_by_definition([definition])
		return emotes[definition]


	static func from_json(d: Dictionary, twitch_service: TwitchService) -> Emote:
		var result = Emote.new(twitch_service)
		if d.has("id") and d["id"] != null:
			result.id = d["id"]
		if d.has("emote_set_id") and d["emote_set_id"] != null:
			result.emote_set_id = d["emote_set_id"]
		if d.has("owner_id") and d["owner_id"] != null:
			result.owner_id = d["owner_id"]
		if d.has("format") and d["format"] != null:
			for format in d["format"]:
				if format == "static":
					result.format.append(EmoteFormat._static)
				elif format == "animated":
					result.format.append(EmoteFormat.animated)
		return result




class Badge:
	## An ID that identifies this set of chat badges. For example, Bits or Subscriber.
	var set_id: String
	## An ID that identifies this version of the badge. The ID can be any value. For example, for Bits, the ID is the Bits tier level, but for World of Warcraft, it could be Alliance or Horde.
	var id: String
	## Contains metadata related to the chat badges in the badges tag. Currently, this tag contains metadata only for subscriber badges, to indicate the number of months the user has been a subscriber.
	var info: String

	static func from_json(d: Dictionary) -> Badge:
		var result = Badge.new()
		if d.has("set_id") and d["set_id"] != null:
			result.set_id = d["set_id"]
		if d.has("id") and d["id"] != null:
			result.id = d["id"]
		if d.has("info") and d["info"] != null:
			result.info = d["info"]
		return result



class Cheer:
	## The amount of Bits the user cheered.
	var bits: int


	static func from_json(d: Dictionary) -> Cheer:
		var result = Cheer.new()
		if d.has("bits") and d["bits"] != null:
			result.bits = d["bits"]
		return result

class Reply:
	## An ID that uniquely identifies the parent message that this message is replying to.
	var parent_message_id: String
	## The message body of the parent message.
	var parent_message_body: String
	## User ID of the sender of the parent message.
	var parent_user_id: String
	## User name of the sender of the parent message.
	var parent_user_name: String
	## User login of the sender of the parent message.
	var parent_user_login: String
	## An ID that identifies the parent message of the reply thread.
	var thread_message_id: String
	## User ID of the sender of the thread’s parent message.
	var thread_user_id: String
	## User name of the sender of the thread’s parent message.
	var thread_user_name: String
	## User login of the sender of the thread’s parent message.
	var thread_user_login: String

	static func from_json(d: Dictionary) -> Reply:
		var result = Reply.new()
		if d.has("parent_message_id") and d["parent_message_id"] != null:
			result.parent_message_id = d["parent_message_id"]
		if d.has("parent_message_body") and d["parent_message_body"] != null:
			result.parent_message_body = d["parent_message_body"]
		if d.has("parent_user_id") and d["parent_user_id"] != null:
			result.parent_user_id = d["parent_user_id"]
		if d.has("parent_user_name") and d["parent_user_name"] != null:
			result.parent_user_name = d["parent_user_name"]
		if d.has("parent_user_login") and d["parent_user_login"] != null:
			result.parent_user_login = d["parent_user_login"]
		if d.has("thread_message_id") and d["thread_message_id"] != null:
			result.thread_message_id = d["thread_message_id"]
		if d.has("thread_user_id") and d["thread_user_id"] != null:
			result.thread_user_id = d["thread_user_id"]
		if d.has("thread_user_name") and d["thread_user_name"] != null:
			result.thread_user_name = d["thread_user_name"]
		if d.has("thread_user_login") and d["thread_user_login"] != null:
			result.thread_user_login = d["thread_user_login"]
		return result


## The broadcaster user ID.
var broadcaster_user_id: String
## The broadcaster display name.
var broadcaster_user_name: String
## The broadcaster login.
var broadcaster_user_login: String
## The user ID of the user that sent the message.
var chatter_user_id: String
## The user name of the user that sent the message.
var chatter_user_name: String
## The user login of the user that sent the message.
var chatter_user_login: String
## A UUID that identifies the message.
var message_id: String
## The structured chat message.
var message: Message
## The type of message.
var message_type: MessageType
## List of chat badges.
var badges: Array[Badge] = []
## Optional. Metadata if this message is a cheer.
var cheer: Cheer
## The color of the user’s name in the chat room. This is a hexadecimal RGB color code in the form, #<RGB>;. This tag may be empty if it is never set.
var color: String
## Optional. Metadata if this message is a reply.
var reply: Reply
## Optional. The ID of a channel points custom reward that was redeemed.
var channel_points_custom_reward_id: String
## Optional. The broadcaster user ID of the channel the message was sent from. Is null when the message happens in the same channel as the broadcaster. Is not null when in a shared chat session, and the action happens in the channel of a participant other than the broadcaster.
var source_broadcaster_user_id: String
## Optional. The user name of the broadcaster of the channel the message was sent from. Is null when the message happens in the same channel as the broadcaster. Is not null when in a shared chat session, and the action happens in the channel of a participant other than the broadcaster.
var source_broadcaster_user_name: String
## Optional. The login of the broadcaster of the channel the message was sent from. Is null when the message happens in the same channel as the broadcaster. Is not null when in a shared chat session, and the action happens in the channel of a participant other than the broadcaster.
var source_broadcaster_user_login: String
## Optional. The UUID that identifies the source message from the channel the message was sent from. Is null when the message happens in the same channel as the broadcaster. Is not null when in a shared chat session, and the action happens in the channel of a participant other than the broadcaster.
var source_message_id: String
## Optional. The list of chat badges for the chatter in the channel the message was sent from. Is null when the message happens in the same channel as the broadcaster. Is not null when in a shared chat session, and the action happens in the channel of a participant other than the broadcaster.
var source_badges: Array[Badge] = []

var _twitch_service: TwitchService

func _init(twitch_service: TwitchService) -> void:
	_twitch_service = twitch_service

## Loads a chat message from Json decoded dictionary. TwitchService is optional in case images and badges should be load from the message.
static func from_json(d: Dictionary, twitch_service: TwitchService) -> TwitchChatMessage:
	var result = TwitchChatMessage.new(twitch_service)
	if d.has("broadcaster_user_id") and d["broadcaster_user_id"] != null:
		result.broadcaster_user_id = d["broadcaster_user_id"]
	if d.has("broadcaster_user_name") and d["broadcaster_user_name"] != null:
		result.broadcaster_user_name = d["broadcaster_user_name"]
	if d.has("broadcaster_user_login") and d["broadcaster_user_login"] != null:
		result.broadcaster_user_login = d["broadcaster_user_login"]
	if d.has("chatter_user_id") and d["chatter_user_id"] != null:
		result.chatter_user_id = d["chatter_user_id"]
	if d.has("chatter_user_name") and d["chatter_user_name"] != null:
		result.chatter_user_name = d["chatter_user_name"]
	if d.has("chatter_user_login") and d["chatter_user_login"] != null:
		result.chatter_user_login = d["chatter_user_login"]
	if d.has("message_id") and d["message_id"] != null:
		result.message_id = d["message_id"]
	if d.has("message") and d["message"] != null:
		result.message = Message.from_json(d["message"], twitch_service)
	if d.has("message_type") and d["message_type"] != null:
		result.message_type = MessageType[d["message_type"]]
	if d.has("badges") and d["badges"] != null:
		for value in d["badges"]:
			result.badges.append(Badge.from_json(value))
	if d.has("cheer") and d["cheer"] != null:
		result.cheer = Cheer.from_json(d["cheer"])
	if d.has("color") and d["color"] != null:
		result.color = d["color"]
	if d.has("reply") and d["reply"] != null:
		result.reply = Reply.from_json(d["reply"])
	if d.has("channel_points_custom_reward_id") and d["channel_points_custom_reward_id"] != null:
		result.channel_points_custom_reward_id = d["channel_points_custom_reward_id"]
	if d.has("source_broadcaster_user_id") and d["source_broadcaster_user_id"] != null:
		result.source_broadcaster_user_id = d["source_broadcaster_user_id"]
	if d.has("source_broadcaster_user_name") and d["source_broadcaster_user_name"] != null:
		result.source_broadcaster_user_name = d["source_broadcaster_user_name"]
	if d.has("source_broadcaster_user_login") and d["source_broadcaster_user_login"] != null:
		result.source_broadcaster_user_login = d["source_broadcaster_user_login"]
	if d.has("source_message_id") and d["source_message_id"] != null:
		result.source_message_id = d["source_message_id"]
	if d.has("source_badges") and d["source_badges"] != null:
		for value in d["source_badges"]:
			result.source_badges.append(Badge.from_json(value))
	return result


## Key: TwitchBadgeDefinition | Value: SpriteFrames
func get_badges(scale: int = 1) -> Dictionary:
	var definitions: Array[TwitchBadgeDefinition] = []
	for badge in badges:
		var badge_definition = TwitchBadgeDefinition.new(badge.set_id, badge.id, scale, broadcaster_user_id)
		definitions.append(badge_definition)
	var emotes = await _twitch_service.media_loader.get_badges(definitions)
	return emotes


## Key: TwitchBadgeDefinition | Value: SpriteFrames
func get_source_badges(scale: int = 1) -> Dictionary:
	var definitions: Array[TwitchBadgeDefinition] = []
	for badge in source_badges:
		var badge_definition = TwitchBadgeDefinition.new(badge.set_id, badge.id, scale, broadcaster_user_id)
		definitions.append(badge_definition)
	var emotes = await _twitch_service.media_loader.get_badges(definitions)
	return emotes

## Returns a the color of the user or the default when its not set never null
func get_color(default_color: String = "#AAAAAA") -> String:
	return default_color if color == null || color == "" else color
