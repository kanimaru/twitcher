@tool
extends RefCounted

class_name TwitchStartCommercialResponse

## An array that contains a single object with the status of your start commercial request.
var data: Array;

static func from_json(d: Dictionary) -> TwitchStartCommercialResponse:
	var result = TwitchStartCommercialResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

