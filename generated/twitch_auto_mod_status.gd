@tool
extends RefCounted

class_name TwitchAutoModStatus

## The caller-defined ID passed in the request.
var msg_id: String;
## A Boolean value that indicates whether Twitch would approve the message for chat or hold it for moderator review or block it from chat. Is **true** if Twitch would approve the message; otherwise, **false** if Twitch would hold the message for moderator review or block it from chat.
var is_permitted: bool;

static func from_json(d: Dictionary) -> TwitchAutoModStatus:
	var result = TwitchAutoModStatus.new();
	result.msg_id = d["msg_id"];
	result.is_permitted = d["is_permitted"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["msg_id"] = msg_id;
	d["is_permitted"] = is_permitted;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

