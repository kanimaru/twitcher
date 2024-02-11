@tool
extends RefCounted

class_name TwitchGetTeamsResponse

## A list that contains the single team that you requested.
var data: Array[TwitchTeam];

static func from_json(d: Dictionary) -> TwitchGetTeamsResponse:
	var result = TwitchGetTeamsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchTeam.from_json(value));
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
