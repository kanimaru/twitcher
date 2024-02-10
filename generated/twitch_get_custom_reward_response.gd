@tool
extends RefCounted

class_name TwitchGetCustomRewardResponse

## A list of custom rewards. The list is in ascending order by `id`. If the broadcaster hasn’t created custom rewards, the list is empty.
var data: Array[TwitchCustomReward];

static func from_json(d: Dictionary) -> TwitchGetCustomRewardResponse:
	var result = TwitchGetCustomRewardResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

