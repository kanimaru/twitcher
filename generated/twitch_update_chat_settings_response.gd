@tool
extends RefCounted

class_name TwitchUpdateChatSettingsResponse

## The list of chat settings. The list contains a single object with all the settings.
var data: Array[TwitchChatSettingsUpdated];

static func from_json(d: Dictionary) -> TwitchUpdateChatSettingsResponse:
	var result = TwitchUpdateChatSettingsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

