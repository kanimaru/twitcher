@tool
extends RefCounted

class_name TwitchEndPollResponse

## A list that contains the poll that you ended.
var data: Array[TwitchPoll];

static func from_json(d: Dictionary) -> TwitchEndPollResponse:
	var result = TwitchEndPollResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchPoll.from_json(value));
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value.to_dict());
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

