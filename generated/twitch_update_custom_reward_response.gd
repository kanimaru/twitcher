@tool
extends RefCounted

class_name TwitchUpdateCustomRewardResponse

## The list contains the single reward that you updated.
var data: Array[TwitchCustomReward];

static func from_json(d: Dictionary) -> TwitchUpdateCustomRewardResponse:
	var result = TwitchUpdateCustomRewardResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

