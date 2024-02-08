@tool
extends RefCounted

class_name TwitchCreateCustomRewardsResponse

## A list that contains the single custom reward you created.
var data: Array[TwitchCustomReward];

static func from_json(d: Dictionary) -> TwitchCreateCustomRewardsResponse:
	var result = TwitchCreateCustomRewardsResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

