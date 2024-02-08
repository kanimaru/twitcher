@tool
extends RefCounted

class_name TwitchCheckAutoModStatusResponse

## The list of messages and whether Twitch would approve them for chat.
var data: Array[TwitchAutoModStatus];

static func from_json(d: Dictionary) -> TwitchCheckAutoModStatusResponse:
	var result = TwitchCheckAutoModStatusResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

