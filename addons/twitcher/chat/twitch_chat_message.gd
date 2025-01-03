extends Node

class_name TwitchChatMessage

const FRAGMENT_TYPE_TEXT := "text"
const FRAGMENT_TYPE_CHEERMOTE := "cheermote"
const FRAGMENT_TYPE_EMOTE := "emote"
const FRAGMENT_TYPE_MENTION := "mention"

const EMOTE_TYPE_ANIMATED := "animated"
const EMOTE_TYPE_STATIC := "static"

const MESSAGE_TYPE_TEXT := "text"
const MESSAGE_TYPE_CHANNEL_POINTS_HIGHLIGHTED := "channel_points_highlighted"
const MESSAGE_TYPE_CHANNEL_POINTS_SUB_ONLY := "channel_points_sub_only"
const MESSAGE_TYPE_USER_INTRO := "user_intro"
const MESSAGE_TYPE_POWER_UPS_MESSAGE_EFFECT := "power_ups_message_effect"
const MESSAGE_TYPE_POWER_UPS_GIGANTIFIED_EMOTE := "power_ups_gigantified_emote"


class Message:
	## The chat message in plain text.
	var text: String
	## Ordered list of chat message fragments.
	var fragments: Array[Fragment]


	static func from_json(d: Dictionary) -> Message:
		var result = Message.new()
		if d.has("text") and d["text"] != null:
			result.text = d["text"]
		if d.has("fragments") and d["fragments"] != null:
			result.fragments = []
			for value in d["fragments"]:
				result.fragments.append(Fragment.from_json(value))
		return result


class Fragment:
	## The type of message fragment. See "TwitchChatMessage.FRAGMENT_TYPE_*"
	var type: String
	## Message text in fragment.
	var text: String
	## Optional. Metadata pertaining to the cheermote.
	var cheermote: Cheermote
	## Optional. Metadata pertaining to the emote.
	var emote: Emote
	## Optional. Metadata pertaining to the mention.
	var mention: Mention


	static func from_json(d: Dictionary) -> Fragment:
		var result = Fragment.new()
		if d.has("type") and d["type"] != null:
			result.type = d["type"]
		if d.has("text") and d["text"] != null:
			result.text = d["text"]
		if d.has("cheermote") and d["cheermote"] != null:
			result.cheermote = Cheermote.from_json(d["cheermote"])
		if d.has("emote") and d["emote"] != null:
			result.emote = Emote.from_json(d["emote"])
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


	static func from_json(d: Dictionary) -> Cheermote:
		var result = Cheermote.new()
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
	var format: Array[String]


	static func from_json(d: Dictionary) -> Emote:
		var result = Emote.new()
		if d.has("id") and d["id"] != null:
			result.id = d["id"]
		if d.has("emote_set_id") and d["emote_set_id"] != null:
			result.emote_set_id = d["emote_set_id"]
		if d.has("owner_id") and d["owner_id"] != null:
			result.owner_id = d["owner_id"]
		if d.has("format") and d["format"] != null:
			result.format = d["format"]
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
## The type of message. See: "TwitchChatMessage.MESSAGE_TYPE_*"
var message_type: String
## List of chat badges.
var badges: Array[Badge]
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
var source_badges: Array[Badge]


static func from_json(d: Dictionary) -> TwitchChatMessage:
	var result = TwitchChatMessage.new()
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
		result.message = Message.from_json(d["message"])
	if d.has("message_type") and d["message_type"] != null:
		result.message_type = d["message_type"]
	if d.has("badges") and d["badges"] != null:
		result.badges = []
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
		result.source_badges = []
		for value in d["source_badges"]:
			result.source_badges.append(Badge.from_json(value))
	return result
