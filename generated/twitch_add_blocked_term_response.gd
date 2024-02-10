@tool
extends RefCounted

class_name TwitchAddBlockedTermResponse

## A list that contains the single blocked term that the broadcaster added.
var data: Array[TwitchBlockedTerm];

static func from_json(d: Dictionary) -> TwitchAddBlockedTermResponse:
	var result = TwitchAddBlockedTermResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

