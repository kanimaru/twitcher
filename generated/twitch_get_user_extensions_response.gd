@tool
extends RefCounted

class_name TwitchGetUserExtensionsResponse

## The list of extensions that the user has installed.
var data: Array[TwitchUserExtension];

static func from_json(d: Dictionary) -> TwitchGetUserExtensionsResponse:
	var result = TwitchGetUserExtensionsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

