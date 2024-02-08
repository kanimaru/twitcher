@tool
extends RefCounted

class_name TwitchSendChatMessageBody

## The ID of the broadcaster whose chat room the message will be sent to.
var broadcaster_id: String;
## The ID of the user sending the message. This ID must match the user ID in the user access token.
var sender_id: String;
## The message to send. The message is limited to a maximum of 500 characters. Chat messages can also include emoticons. To include emoticons, use the name of the emote. The names are case sensitive. Don’t include colons around the name (e.g., :bleedPurple:). If Twitch recognizes the name, Twitch converts the name to the emote before writing the chat message to the chat room
var message: String;
## The ID of the chat message being replied to.
var reply_parent_message_id: String;

static func from_json(d: Dictionary) -> TwitchSendChatMessageBody:
	var result = TwitchSendChatMessageBody.new();
	result.broadcaster_id = d["broadcaster_id"];
	result.sender_id = d["sender_id"];
	result.message = d["message"];
	result.reply_parent_message_id = d["reply_parent_message_id"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["broadcaster_id"] = broadcaster_id;
	d["sender_id"] = sender_id;
	d["message"] = message;
	d["reply_parent_message_id"] = reply_parent_message_id;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

