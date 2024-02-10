@tool
extends RefCounted

class_name TwitchGetExtensionsResponse

## A list that contains the specified extension.
var data: Array[TwitchExtension];

static func from_json(d: Dictionary) -> TwitchGetExtensionsResponse:
	var result = TwitchGetExtensionsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchExtension.from_json(value));
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value.to_dict());
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

