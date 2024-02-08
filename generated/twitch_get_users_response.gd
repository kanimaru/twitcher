@tool
extends RefCounted

class_name TwitchGetUsersResponse

## The list of users.
var data: Array[TwitchUser];

static func from_json(d: Dictionary) -> TwitchGetUsersResponse:
	var result = TwitchGetUsersResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

