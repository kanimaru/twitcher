@tool
extends RefCounted

class_name TwitchSnoozeNextAdResponse

## A list that contains information about the channel’s snoozes and next upcoming ad after successfully snoozing.
var data: Array;

static func from_json(d: Dictionary) -> TwitchSnoozeNextAdResponse:
	var result = TwitchSnoozeNextAdResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

