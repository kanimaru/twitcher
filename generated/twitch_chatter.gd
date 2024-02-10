@tool
extends RefCounted

class_name TwitchChatter

## The ID of a user that’s connected to the broadcaster’s chat room.
var user_id: String;
## The user’s login name.
var user_login: String;
## The user’s display name.
var user_name: String;

static func from_json(d: Dictionary) -> TwitchChatter:
	var result = TwitchChatter.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

