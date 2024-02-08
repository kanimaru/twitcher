@tool
extends RefCounted

class_name TwitchGetAdScheduleResponse

## A list that contains information related to the channel’s ad schedule.
var data: Array;

static func from_json(d: Dictionary) -> TwitchGetAdScheduleResponse:
	var result = TwitchGetAdScheduleResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

