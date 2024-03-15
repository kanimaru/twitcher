extends RefCounted

class_name TwitchTags

## A normal user
const USER_TYPE_NORMA := &""
## A Twitch administrator
const USER_TYPE_ADMIN := &"admin";
## A global moderator
const USER_TYPE_GLOBAL_MOD := &"global_mod";
## A Twitch employee
const USER_TYPE_STAFF := &"staff";

const MSG_ID_SUB := &"sub";
const MSG_ID_RESUB := &"resub";
const MSG_ID_SUBGIFT := &"subgift";
const MSG_ID_SUBMYSTERYGIFT := &"submysterygift";
const MSG_ID_GIFTPAIDUPGRADE := &"giftpaidupgrade";
const MSG_ID_REWARDGIFT := &"rewardgift";
const MSG_ID_ANONGIFTPAIDUPGRADE := &"anongiftpaidupgrade";
const MSG_ID_RAID := &"raid";
const MSG_ID_UNRAID := &"unraid";
const MSG_ID_RITUAL := &"ritual";
const MSG_ID_BITSBADGETIER := &"bitsbadgetier";
#region TagWrapper

class Message extends RefCounted:
	var color: String;
	var badges: String;
	var emotes: String;
	var room_id: String;
	var raw: Variant;

	static func from_priv_msg(tag: PrivMsg) -> Message:
		var msg = Message.new();
		msg.color = tag.color;
		msg.badges = tag.badges;
		msg.emotes = tag.emotes;
		msg.room_id = tag.room_id;
		msg.raw = tag;
		return msg;

	func get_color() -> String:
		return color;

	func get_badges() -> Array[SpriteFrames]:
		var badge_composite : Array[String] = [];
		for badge in badges.split(",", false):
			badge_composite.append(badge);
		var result = await(TwitchService.get_badges(badge_composite, room_id))
		var sprite_frames : Array[SpriteFrames] = [];
		for sprite_frame in result.values():
			sprite_frames.append(sprite_frame);
		return sprite_frames;

	func get_emotes() -> Array[TwitchIRC.EmoteLocation]:
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

		var emotes: Dictionary = await TwitchService.icon_loader.get_emotes(emotes_to_load);
		for emote_location: TwitchIRC.EmoteLocation in locations:
			emote_location.sprite_frames = emotes[emote_location.id];

		return locations;

#endregion

#region Lowlevel Tags

class BaseTags:
	var _raw: String;
	var _unmapped: Dictionary = {};

	func parse_tags(tag_string: String, output: Object) -> void:
		_raw = tag_string;
		if tag_string.left(1) == "@":
			tag_string = tag_string.substr(1);

		var tags = tag_string.split(";");
		for tag in tags:
			var tag_value = tag.split("=");
			var property_name = tag_value[0].replace("-", "_");
			if _has_property(output, property_name):
				output.set(property_name, tag_value[1]);
			elif tag_value.size() == 2:
				output._unmapped[property_name] = tag_value[1];
			else:
				output._unmapped[property_name] = "";

	func _has_property(obj: Object, property_name: String) -> bool:
		var properties = obj.get_property_list();
		for property in properties:
			if property.name == property_name:
				return true;
		return false;

	func get_unmapped(property: String) -> Variant:
		return _unmapped[property];

	func has_unmapped(property: String) -> bool:
		return _unmapped.has(property);

## Sent when the bot or moderator removes all messages from the chat room or removes all messages for the specified user. [br]
## @ban-duration=<duration>;room-id=<room-id>;target-user-id=<user-id>;tmi-sent-ts=<timestamp> [br]
## See: https://dev.twitch.tv/docs/irc/tags/#clearchat-tags
class ClearChat extends BaseTags:
	## Optional. The message includes this tag if the user was put in a timeout. The tag contains the duration of the timeout, in seconds.
	var ban_duration: String
	## The ID of the channel where the messages were removed from.
	var room_id: String
	## Optional. The ID of the user that was banned or put in a timeout. The user was banned if the message doesn’t include the ban-duration tag.
	var target_user_id: String
	## The UNIX timestamp.
	var tmi_sent_ts: String

	func _init(tags: String) -> void:
		parse_tags(tags, self);

## Sent when the bot removes a single message from the chat room. [br]
## @login=<login>;room-id=<room-id>;target-msg-id=<target-msg-id>;tmi-sent-ts=<timestamp> [br]
## See: https://dev.twitch.tv/docs/irc/tags/#clearmsg-tags
class ClearMsg extends BaseTags:
	## The name of the user who sent the message.
	var login: String;
	## Optional. The ID of the channel (chat room) where the message was removed from.
	var room_id: String;
	## A UUID that identifies the message that was removed.
	var target_msg_id: String;
	## The UNIX timestamp.
	var tmi_sent_ts: String;

	func _init(tags: String) -> void:
		parse_tags(tags, self);

## Sent when the bot authenticates with the server. [br]
## @badge-info=<badge-info>;badges=<badges>;color=<color>;display-name=<display-name>;emote-sets=<emote-sets>;turbo=<turbo>;user-id=<user-id>;user-type=<user-type> [br]
## See https://dev.twitch.tv/docs/irc/tags/#globaluserstate-tags
class GlobalUserState extends BaseTags:
	## Contains metadata related to the chat badges in the badges tag. [br]
	## Currently, this tag contains metadata only for subscriber badges, to indicate the number of months the user has been a subscriber.
	var badge_info: String
	## Comma-separated list of chat badges in the form, <badge>/<version>. For example, admin/1. There are many possible badge values.
	var badges: String
	## The color of the user’s name in the chat room. This is a hexadecimal RGB color code in the form, #<RGB>. This tag may be empty if it is never set.
	var color: String
	## The user’s display name, escaped as described in the IRCv3 spec. This tag may be empty if it is never set.
	var display_name: String
	## A comma-delimited list of IDs that identify the emote sets that the user has access to. Is always set to at least zero (0). To access the emotes in the set, use the Get Emote Sets API.
	var emote_sets: String
	## A Boolean value that indicates whether the user has site-wide commercial free mode enabled. Is true (1) if enabled; otherwise, false (0).
	var turbo: String
	## The user’s ID.
	var user_id: String
	## The type of user. See TwitchTags.USER_TYPE_*
	var user_type: String

	func _init(tags: String) -> void:
		parse_tags(tags, self);

## Sent to indicate the outcome of an action like banning a user. [br]
## @msg-id=<msg-id>;target-user-id=<user-id> [br]
## See: https://dev.twitch.tv/docs/irc/tags/#notice-tags
class Notice extends BaseTags:
	## An ID that you can use to programmatically determine the action’s outcome. For a list of possible IDs, see NOTICE Message IDs.
	var msg_id: String;
	## The ID of the user that the action targeted.
	var target_user_id: String;

	func _init(tags: String) -> void:
		parse_tags(tags, self);

## Sent when a user posts a message to the chat room. [br]
## @badge-info=<badge-info>;badges=<badges>;bits=<bits>client-nonce=<nonce>;color=<color>;display-name=<display-name>;emotes=<emotes>;first-msg=<first-msg>;flags=<flags>;id=<msg-id>;mod=<mod>;room-id=<room-id>;subscriber=<subscriber>;tmi-sent-ts=<timestamp>;turbo=<turbo>;user-id=<user-id>;user-type=<user-type>;reply-parent-msg-id=<reply-parent-msg-id>;reply-parent-user-id=<reply-parent-user-id>;reply-parent-user-login=<reply-parent-user-login>;reply-parent-display-name=<reply-parent-display-name>;reply-parent-msg-body=<reply-parent-msg-body>;reply-thread-parent-msg-id=<reply-thread-parent-msg-id>;reply-thread-parent-user-login=<reply-thread-parent-user-login>;vip=<vip> [br]
## See: https://dev.twitch.tv/docs/irc/tags/#privmsg-tags
class PrivMsg extends BaseTags:
	## Contains metadata related to the chat badges in the badges tag. [br]
	##Currently, this tag contains metadata only for subscriber badges, to indicate the number of months the user has been a subscriber.
	var badge_info: String;
	## Comma-separated list of chat badges in the form, <badge>/<version>. For example, admin/1. There are many possible badge values,
	var badges: String;
	## The amount of Bits the user cheered. Only a Bits cheer message includes this tag. To learn more about Bits, see the Extensions Monetization Guide. To get the cheermote, use the Get Cheermotes API. Match the cheer amount to the id field’s value in the response. Then, get the cheermote’s URL based on the cheermote theme, type, and size you want to use.
	var bits: String;
	## The color of the user’s name in the chat room. This is a hexadecimal RGB color code in the form, #<RGB>. This tag may be empty if it is never set.
	var color: String;
	## The user’s display name, escaped as described in the IRCv3 spec. This tag may be empty if it is never set.
	var display_name: String;
	## A comma-delimited list of emotes and their positions in the message. Each emote is in the form, <emote ID>:<start position>-<end position>. The position indices are zero-based.
	var emotes: String;
	## An ID that uniquely identifies the message.
	var id: String;
	## A Boolean value that determines whether the user is a moderator. Is true (1) if the user is a moderator; otherwise, false (0).
	var mod: String;
	## The value of the Hype Chat sent by the user.
	var pinned_chat_paid_amount: String;
	## The ISO 4217 alphabetic currency code the user has sent the Hype Chat in.
	var pinned_chat_paid_currency: String;
	## Indicates how many decimal points this currency represents partial amounts in. Decimal points start from the right side of the value defined in pinned-chat-paid-amount.
	var pinned_chat_paid_exponent: String;
	## The level of the Hype Chat, in English. Possible values are: ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN
	var pinned_chat_paid_level: String;
	##A Boolean value that determines if the message sent with the Hype Chat was filled in by the system. [br]
	##If true (1), the user entered no message and the body message was automatically filled in by the system. [br]
	##If false (0), the user provided their own message to send with the Hype Chat.
	var pinned_chat_paid_is_system_message: String;
	## An ID that uniquely identifies the direct parent message that this message is replying to. The message does not include this tag if this message is not a reply.
	var reply_parent_msg_id: String;
	## An ID that identifies the sender of the direct parent message. The message does not include this tag if this message is not a reply.
	var reply_parent_user_id: String;
	## The login name of the sender of the direct parent message. The message does not include this tag if this message is not a reply.
	var reply_parent_user_login: String;
	## The display name of the sender of the direct parent message. The message does not include this tag if this message is not a reply.
	var reply_parent_display_name: String;
	## The text of the direct parent message. The message does not include this tag if this message is not a reply.
	var reply_parent_msg_body: String;
	## An ID that uniquely identifies the top-level parent message of the reply thread that this message is replying to. The message does not include this tag if this message is not a reply.
	var reply_thread_parent_msg_id: String;
	## The login name of the sender of the top-level parent message. The message does not include this tag if this message is not a reply.
	var reply_thread_parent_user_login: String;
	## An ID that identifies the chat room (channel).
	var room_id: String;
	## A Boolean value that determines whether the user is a subscriber. Is true (1) if the user is a subscriber; otherwise, false (0).
	var subscriber: String;
	## The UNIX timestamp.
	var tmi_sent_ts: String;
	## A Boolean value that indicates whether the user has site-wide commercial free mode enabled. Is true (1) if enabled; otherwise, false (0).
	var turbo: String;
	## The user’s ID.
	var user_id: String;
	## The type of user. See TwitchTags.USER_TYPE_*
	var user_type: String;
	## A Boolean value that determines whether the user that sent the chat is a VIP. The message includes this tag if the user is a VIP; otherwise, the message doesn’t include this tag (check for the presence of the tag instead of whether the tag is set to true or false).
	var vip: String;
	## Not documented by Twitch.
	var first_msg: String;
	## Not documented by Twitch.
	var client_nonce: String

	func _init(tags: String) -> void:
		parse_tags(tags, self);

## Sent when the bot joins a channel or when the channel’s chat room settings change.  [br]
## @emote-only=<emote-only>;followers-only=<followers-only>;r9k=<r9k>;rituals=<rituals>;room-id=<room-id>;slow=<slow>;subs-only=<subs-only> [br]
## See: https://dev.twitch.tv/docs/irc/tags/#roomstate-tags
class Roomstate extends BaseTags:
	## A Boolean value that determines whether the chat room allows only messages with emotes. Is true (1) if only emotes are allowed; otherwise, false (0).
	var emote_only: String;
	## An integer value that determines whether only followers can post messages in the chat room. The value indicates how long, in minutes, the user must have followed the broadcaster before posting chat messages. If the value is -1, the chat room is not restricted to followers only.
	var followers_only: String;
	## A Boolean value that determines whether a user’s messages must be unique. Applies only to messages with more than 9 characters. Is true (1) if users must post unique messages; otherwise, false (0).
	var r9k: String;
	## An ID that identifies the chat room (channel).
	var room_id: String;
	## An integer value that determines how long, in seconds, users must wait between sending messages.
	var slow: String;
	## A Boolean value that determines whether only subscribers and moderators can chat in the chat room. Is true (1) if only subscribers and moderators can chat; otherwise, false (0).
	var subs_only: String;

	func _init(tags: String) -> void:
		parse_tags(tags, self);

## Sent when events like someone subscribing to the channel occurs.[br]
## @badge-info=<badge-info>;badges=<badges>;color=<color>;display-name=<display-name>;emotes=<emotes>;id=<id-of-msg>;login=<user>;mod=<mod>;msg-id=<msg-id>;room-id=<room-id>;subscriber=<subscriber>;system-msg=<system-msg>;tmi-sent-ts=<timestamp>;turbo=<turbo>;user-id=<user-id>;user-type=<user-type>[br]
## See: https://dev.twitch.tv/docs/irc/tags/#usernotice-tags
class Usernotice extends BaseTags:
	## Contains metadata related to the chat badges in the badges tag. [br]
	## Currently, this tag contains metadata only for subscriber badges, to indicate the number of months the user has been a subscriber.
	var badge_info: String;
	## Comma-separated list of chat badges in the form, <badge>/<version>. For example, admin/1. There are many possible badge values.
	var badges: String;
	## The color of the user’s name in the chat room. This is a hexadecimal RGB color code in the form, #<RGB>. This tag may be empty if it is never set.
	var color: String;
	## The user’s display name, escaped as described in the IRCv3 spec. This tag may be empty if it is never set.
	var display_name: String;
	## A comma-delimited list of emotes and their positions in the message. Each emote is in the form, <emote ID>:<start position>-<end position>. The position indices are zero-based.
	var emotes: String;
	## An ID that uniquely identifies this message.
	var id: String;
	## The login name of the user whose action generated the message.
	var login: String;
	## A Boolean value that determines whether the user is a moderator. Is true (1) if the user is a moderator; otherwise, false (0).
	var mod: String;
	## The type of notice (not the ID). Possible values are: TwitchTags.MSG_ID_*
	var msg_id: String;
	## An ID that identifies the chat room (channel).
	var room_id: String;
	## A Boolean value that determines whether the user is a subscriber. Is true (1) if the user is a subscriber; otherwise, false (0).
	var subscriber: String;
	## The message Twitch shows in the chat room for this notice.
	var system_msg: String;
	## The UNIX timestamp for when the Twitch IRC server received the message.
	var tmi_sent_ts: String;
	## A Boolean value that indicates whether the user has site-wide commercial free mode enabled. Is true (1) if enabled; otherwise, false (0).
	var turbo: String;
	## The user’s ID.
	var user_id: String;
	## The type of user. See TwitchTags.USER_TYPE_*
	var user_type: String;
#
# Depending on State
#
	## Included only with sub and resub notices. [br]
	## The total number of months the user has subscribed. This is the same as msg-param-months but sent for different types of user notices.
	var msg_param_cumulative_months: String;
	## Included only with raid notices. [br]
	## The display name of the broadcaster raiding this channel.
	var msg_param_displayName: String;
	## Included only with raid notices. [br]
	## The login name of the broadcaster raiding this channel.
	var msg_param_login: String;
	## Included only with subgift notices. [br]
	## The total number of months the user has subscribed. This is the same as msg-param-cumulative-months but sent for different types of user notices.
	var msg_param_months: String;
	## Included only with anongiftpaidupgrade and giftpaidupgrade notices. [br]
	## The number of gifts the gifter has given during the promo indicated by msg-param-promo-name.
	var msg_param_promo_gift_total: String;
	## Included only with anongiftpaidupgrade and giftpaidupgrade notices. [br]
	## The subscriptions promo, if any, that is ongoing (for example, Subtember 2018).
	var msg_param_promo_name: String;
	## Included only with subgift notices.[br]
	## The display name of the subscription gift recipient.
	var msg_param_recipient_display_name: String;
	## Included only with subgift notices.[br]
	## The user ID of the subscription gift recipient.
	var msg_param_recipient_id: String;
	## Included only with subgift notices.[br]
	## The user name of the subscription gift recipient.
	var msg_param_recipient_user_name: String;
	## Included only with giftpaidupgrade notices. [br]
	## The login name of the user who gifted the subscription.
	var msg_param_sender_login: String;
	## Include only with giftpaidupgrade notices.[br]
	## The display name of the user who gifted the subscription.
	var msg_param_sender_name: String;
	## Included only with sub and resub notices.[br]
	## A Boolean value that indicates whether the user wants their streaks shared.
	var msg_param_should_share_streak: String;
	## Included only with sub and resub notices.
	## The number of consecutive months the user has subscribed. This is zero (0) if msg-param-should-share-streak is 0.
	var msg_param_streak_months: String;
	## Included only with sub, resub and subgift notices.[br]
	## [br]
	## The type of subscription plan being used. Possible values are:[br]
	## [br]
	## Prime — Amazon Prime subscription[br]
	## 1000 — First level of paid subscription[br]
	## 2000 — Second level of paid subscription[br]
	## 3000 — Third level of paid subscription[br]
	var msg_param_sub_plan: String;
	## Included only with sub, resub, and subgift notices.[br]
 	## The display name of the subscription plan. This may be a default name or one created by the channel owner.
	var msg_param_sub_plan_name: String;
	## Included only with raid notices.[br]
	## The number of viewers raiding this channel from the broadcaster’s channel.
	var msg_param_viewerCount: String;
	## Included only with ritual notices.[br]
	## The name of the ritual being celebrated. Possible values are: new_chatter.
	var msg_param_ritual_name: String;
	## Included only with bitsbadgetier notices.[br]
	## The tier of the Bits badge the user just earned. For example, 100, 1000, or 10000.
	var msg_param_threshold: String;
	## Included only with subgift notices.[br]
	## The number of months gifted as part of a single, multi-month gift.
	var msg_param_gift_months: String;

	func _init(tags: String) -> void:
		parse_tags(tags, self);

## Sent when the bot joins a channel or sends a PRIVMSG message. [br]
## @badge-info=<badge-info>;badges=<badges>;color=<color>;display-name=<display-name>;emote-sets=<emote-sets>;id=<id>;mod=<mod>;subscriber=<subscriber>;turbo=<turbo>;user-type=<user-type>[br][br]
## See: https://dev.twitch.tv/docs/irc/tags/#userstate-tags
class Userstate extends BaseTags:
	## Contains metadata related to the chat badges in the badges tag. [br]
	## Currently, this tag contains metadata only for subscriber badges, to indicate the number of months the user has been a subscriber.
	var badge_info: String;
	## Comma-separated list of chat badges in the form, <badge>/<version>. For example, admin/1. There are many possible badge values.
	var badges: String;
	## The color of the user’s name in the chat room. This is a hexadecimal RGB color code in the form, #<RGB>. This tag may be empty if it is never set.
	var color: String
	## The user’s display name, escaped as described in the IRCv3 spec. This tag may be empty if it is never set.
	var display_name: String
	## A comma-delimited list of IDs that identify the emote sets that the user has access to. Is always set to at least zero (0). To access the emotes in the set, use the Get Emote Sets API.
	var emote_sets: String
	## If a privmsg was sent, an ID that uniquely identifies the message.
	var id: String
	## A Boolean value that determines whether the user is a moderator. Is true (1) if the user is a moderator; otherwise, false (0).
	var mod: String
	## A Boolean value that determines whether the user is a subscriber. Is true (1) if the user is a subscriber; otherwise, false (0).
	var subscriber: String
	## A Boolean value that indicates whether the user has site-wide commercial free mode enabled. Is true (1) if enabled; otherwise, false (0).
	var turbo: String
	## The type of user. See TwitchTags.USER_TYPE_*
	var user_type: String

	func _init(tags: String) -> void:
		parse_tags(tags, self);

## Sent when someone sends your bot a whisper message. [br]
## @badges=<badges>;color=<color>;display-name=<display-name>;emotes=<emotes>;message-id=<msg-id>;thread-id=<thread-id>;turbo=<turbo>;user-id=<user-id>;user-type=<user-type>[br]
## See: https://dev.twitch.tv/docs/irc/tags/#whisper-tags
class Whisper extends BaseTags:
	## Comma-separated list of chat badges in the form, <badge>/<version>. For example, admin/1. There are many possible badge values.
	var badges: String;
	## The color of the user’s name in the chat room. This is a hexadecimal RGB color code in the form, #<RGB>. This tag may be empty if it is never set.
	var color: String;
	## The display name of the user sending the whisper message, escaped as described in the IRCv3 spec. This tag may be empty if it is never set.
	var display_name: String;
	## A comma-delimited list of emotes and their positions in the message. Each emote is in the form, <emote ID>:<start position>-<end position>. The position indices are zero-based.
	var emotes: String;
	## An ID that uniquely identifies the whisper message.
	var message_id: String;
	## An ID that uniquely identifies the whisper thread. The ID is in the form, <smaller-value-user-id>_<larger-value-user-id>.
	var thread_id: String;
	## A Boolean value that indicates whether the user has site-wide commercial free mode enabled. Is true (1) if enabled; otherwise, false (0).
	var turbo: String;
	## The ID of the user sending the whisper message.
	var user_id: String;
	## The type of user. See TwitchTags.USER_TYPE_*
	var user_type: String;

	func _init(tags: String) -> void:
		parse_tags(tags, self);

#endregion
