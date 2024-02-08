@tool
extends RefCounted

class_name TwitchGetCheermotesResponse

## The list of Cheermotes. The list is in ascending order by the `order` field’s value.
var data: Array[TwitchCheermote];

static func from_json(d: Dictionary) -> TwitchGetCheermotesResponse:
	var result = TwitchGetCheermotesResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

