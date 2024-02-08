@tool
extends RefCounted

class_name TwitchCheckAutoModStatusBody

## The list of messages to check. The list must contain at least one message and may contain up to a maximum of 100 messages.
var data: Array;

static func from_json(d: Dictionary) -> TwitchCheckAutoModStatusBody:
	var result = TwitchCheckAutoModStatusBody.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

