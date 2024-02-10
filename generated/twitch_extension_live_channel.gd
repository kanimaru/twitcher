@tool
extends RefCounted

class_name TwitchExtensionLiveChannel

## The ID of the broadcaster that is streaming live and has installed or activated the extension.
var broadcaster_id: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The name of the category or game being streamed.
var game_name: String;
## The ID of the category or game being streamed.
var game_id: String;
## The title of the broadcaster’s stream. May be an empty string if not specified.
var title: String;

static func from_json(d: Dictionary) -> TwitchExtensionLiveChannel:
	var result = TwitchExtensionLiveChannel.new();





	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};





	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

