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
	result.text = d["text"];
	result.extension_id = d["extension_id"];
	result.extension_version = d["extension_version"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["text"] = text;
	d["extension_id"] = extension_id;
	d["extension_version"] = extension_version;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

