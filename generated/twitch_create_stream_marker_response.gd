@tool
extends RefCounted

class_name TwitchCreateStreamMarkerResponse

## A list that contains the single marker that you added.
var data: Array[TwitchStreamMarkerCreated];

static func from_json(d: Dictionary) -> TwitchCreateStreamMarkerResponse:
	var result = TwitchCreateStreamMarkerResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

