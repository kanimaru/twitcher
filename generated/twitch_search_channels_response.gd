@tool
extends RefCounted

class_name TwitchSearchChannelsResponse

## The list of channels that match the query. The list is empty if there are no matches.
var data: Array[TwitchChannel];

static func from_json(d: Dictionary) -> TwitchSearchChannelsResponse:
	var result = TwitchSearchChannelsResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

