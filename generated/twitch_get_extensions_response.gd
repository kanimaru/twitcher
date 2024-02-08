@tool
extends RefCounted

class_name TwitchGetExtensionsResponse

## A list that contains the specified extension.
var data: Array[TwitchExtension];

static func from_json(d: Dictionary) -> TwitchGetExtensionsResponse:
	var result = TwitchGetExtensionsResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

