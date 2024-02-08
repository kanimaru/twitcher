@tool
extends RefCounted

class_name TwitchGetChannelChatBadgesResponse

## The list of chat badges. The list is sorted in ascending order by `set_id`, and within a set, the list is sorted in ascending order by `id`.
var data: Array[TwitchChatBadge];

static func from_json(d: Dictionary) -> TwitchGetChannelChatBadgesResponse:
	var result = TwitchGetChannelChatBadgesResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

