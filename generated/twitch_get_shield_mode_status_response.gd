@tool
extends RefCounted

class_name TwitchGetShieldModeStatusResponse

## A list that contains a single object with the broadcaster’s Shield Mode status.
var data: Array;

static func from_json(d: Dictionary) -> TwitchGetShieldModeStatusResponse:
	var result = TwitchGetShieldModeStatusResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

