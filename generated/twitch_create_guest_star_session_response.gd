@tool
extends RefCounted

class_name TwitchCreateGuestStarSessionResponse

## Summary of the session details.
var data: Array[TwitchGuestStarSession];

static func from_json(d: Dictionary) -> TwitchCreateGuestStarSessionResponse:
	var result = TwitchCreateGuestStarSessionResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

