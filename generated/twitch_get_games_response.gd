@tool
extends RefCounted

class_name TwitchGetGamesResponse

## The list of categories and games. The list is empty if the specified categories and games weren’t found.
var data: Array[TwitchGame];

static func from_json(d: Dictionary) -> TwitchGetGamesResponse:
	var result = TwitchGetGamesResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchGame.from_json(value));
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value.to_dict());
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());
