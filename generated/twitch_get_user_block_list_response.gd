@tool
extends RefCounted

class_name TwitchGetUserBlockListResponse

## The list of blocked users. The list is in descending order by when the user was blocked.
var data: Array[TwitchUserBlockList];

static func from_json(d: Dictionary) -> TwitchGetUserBlockListResponse:
	var result = TwitchGetUserBlockListResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

