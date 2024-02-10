@tool
extends RefCounted

class_name TwitchSendWhisperBody

## The whisper message to send. The message must not be empty.      The maximum message lengths are:      * 500 characters if the user you're sending the message to hasn't whispered you before. * 10,000 characters if the user you're sending the message to has whispered you before.    Messages that exceed the maximum length are truncated.
var message: String;

static func from_json(d: Dictionary) -> TwitchSendWhisperBody:
	var result = TwitchSendWhisperBody.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

