@tool
extends RefCounted

class_name TwitchGetChatSettingsResponse

## The list of chat settings. The list contains a single object with all the settings.
var data: Array[TwitchChatSettings];

static func from_json(d: Dictionary) -> TwitchGetChatSettingsResponse:
	var result = TwitchGetChatSettingsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

