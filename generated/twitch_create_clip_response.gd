@tool
extends RefCounted

class_name TwitchCreateClipResponse

## 
var data: Array;

static func from_json(d: Dictionary) -> TwitchCreateClipResponse:
	var result = TwitchCreateClipResponse.new();
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

