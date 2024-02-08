@tool
extends RefCounted

class_name TwitchUserModerator

## The ID of the user that has permission to moderate the broadcaster’s channel.
var user_id: String;
## The user’s login name.
var user_login: String;
## The user’s display name.
var user_name: String;

static func from_json(d: Dictionary) -> TwitchUserModerator:
	var result = TwitchUserModerator.new();
	result.user_id = d["user_id"];
	result.user_login = d["user_login"];
	result.user_name = d["user_name"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["user_id"] = user_id;
	d["user_login"] = user_login;
	d["user_name"] = user_name;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

