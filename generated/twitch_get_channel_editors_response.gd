@tool
extends RefCounted

class_name TwitchGetChannelEditorsResponse

## A list of users that are editors for the specified broadcaster. The list is empty if the broadcaster doesn’t have editors.
var data: Array[TwitchChannelEditor];

static func from_json(d: Dictionary) -> TwitchGetChannelEditorsResponse:
	var result = TwitchGetChannelEditorsResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

