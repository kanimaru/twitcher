@tool
extends RefCounted

class_name TwitchCreatePollResponse

## A list that contains the single poll that you created.
var data: Array[TwitchPoll];

static func from_json(d: Dictionary) -> TwitchCreatePollResponse:
	var result = TwitchCreatePollResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

