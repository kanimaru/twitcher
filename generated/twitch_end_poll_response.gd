@tool
extends RefCounted

class_name TwitchEndPollResponse

## A list that contains the poll that you ended.
var data: Array[TwitchPoll];

static func from_json(d: Dictionary) -> TwitchEndPollResponse:
	var result = TwitchEndPollResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

