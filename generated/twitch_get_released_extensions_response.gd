@tool
extends RefCounted

class_name TwitchGetReleasedExtensionsResponse

## A list that contains the specified extension.
var data: Array[TwitchExtension];

static func from_json(d: Dictionary) -> TwitchGetReleasedExtensionsResponse:
	var result = TwitchGetReleasedExtensionsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

