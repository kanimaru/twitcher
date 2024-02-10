@tool
extends RefCounted

class_name TwitchSendExtensionChatMessageBody

## The message. The message may contain a maximum of 280 characters.
var text: String;
## The ID of the extension that’s sending the chat message.
var extension_id: String;
## The extension’s version number.
var extension_version: String;

static func from_json(d: Dictionary) -> TwitchSendExtensionChatMessageBody:
	var result = TwitchSendExtensionChatMessageBody.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

