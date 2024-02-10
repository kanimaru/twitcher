@tool
extends RefCounted

class_name TwitchUserChatColor

## An ID that uniquely identifies the user.
var user_id: String;
## The user’s login name.
var user_login: String;
## The user’s display name.
var user_name: String;
## The Hex color code that the user uses in chat for their name. If the user hasn’t specified a color in their settings, the string is empty.
var color: String;

static func from_json(d: Dictionary) -> TwitchUserChatColor:
	var result = TwitchUserChatColor.new();




	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};




	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

