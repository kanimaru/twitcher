@tool
extends RefCounted

class_name TwitchGetStreamKeyResponse

## A list that contains the channel’s stream key.
var data: Array;

static func from_json(d: Dictionary) -> TwitchGetStreamKeyResponse:
	var result = TwitchGetStreamKeyResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

