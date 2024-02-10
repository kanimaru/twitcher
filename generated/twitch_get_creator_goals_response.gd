@tool
extends RefCounted

class_name TwitchGetCreatorGoalsResponse

## The list of goals. The list is empty if the broadcaster hasn’t created goals.
var data: Array[TwitchCreatorGoal];

static func from_json(d: Dictionary) -> TwitchGetCreatorGoalsResponse:
	var result = TwitchGetCreatorGoalsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

