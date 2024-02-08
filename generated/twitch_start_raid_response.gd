@tool
extends RefCounted

class_name TwitchStartRaidResponse

## A list that contains a single object with information about the pending raid.
var data: Array;

static func from_json(d: Dictionary) -> TwitchStartRaidResponse:
	var result = TwitchStartRaidResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

