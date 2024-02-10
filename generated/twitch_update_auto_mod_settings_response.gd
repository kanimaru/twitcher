@tool
extends RefCounted

class_name TwitchUpdateAutoModSettingsResponse

## The list of AutoMod settings. The list contains a single object that contains all the AutoMod settings.
var data: Array[TwitchAutoModSettings];

static func from_json(d: Dictionary) -> TwitchUpdateAutoModSettingsResponse:
	var result = TwitchUpdateAutoModSettingsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

