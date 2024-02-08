@tool
extends RefCounted

class_name TwitchDeleteVideosResponse

## The list of IDs of the videos that were deleted.
var data: Array[String];

static func from_json(d: Dictionary) -> TwitchDeleteVideosResponse:
	var result = TwitchDeleteVideosResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

