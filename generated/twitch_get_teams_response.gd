@tool
extends RefCounted

class_name TwitchGetTeamsResponse

## A list that contains the single team that you requested.
var data: Array[TwitchTeam];

static func from_json(d: Dictionary) -> TwitchGetTeamsResponse:
	var result = TwitchGetTeamsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

