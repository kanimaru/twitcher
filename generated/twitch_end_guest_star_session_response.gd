@tool
extends RefCounted

class_name TwitchEndGuestStarSessionResponse

## Summary of the session details when the session was ended.
var data: Array[TwitchGuestStarSession];

static func from_json(d: Dictionary) -> TwitchEndGuestStarSessionResponse:
	var result = TwitchEndGuestStarSessionResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

