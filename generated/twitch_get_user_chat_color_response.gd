@tool
extends RefCounted

class_name TwitchGetUserChatColorResponse

## The list of users and the color code they use for their name.
var data: Array[TwitchUserChatColor];

static func from_json(d: Dictionary) -> TwitchGetUserChatColorResponse:
	var result = TwitchGetUserChatColorResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

