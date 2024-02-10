@tool
extends RefCounted

class_name TwitchStartCommercialResponse

## An array that contains a single object with the status of your start commercial request.
var data: Array;

static func from_json(d: Dictionary) -> TwitchStartCommercialResponse:
	var result = TwitchStartCommercialResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(value);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value);
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

