@tool
extends RefCounted

class_name TwitchUserBlockList

## An ID that identifies the blocked user.
var user_id: String;
## The blocked user’s login name.
var user_login: String;
## The blocked user’s display name.
var display_name: String;

static func from_json(d: Dictionary) -> TwitchUserBlockList:
	var result = TwitchUserBlockList.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

