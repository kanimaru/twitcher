@tool
extends RefCounted

class_name TwitchUserVip

## An ID that uniquely identifies the VIP user.
var user_id: String;
## The user’s display name.
var user_name: String;
## The user’s login name.
var user_login: String;

static func from_json(d: Dictionary) -> TwitchUserVip:
	var result = TwitchUserVip.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

