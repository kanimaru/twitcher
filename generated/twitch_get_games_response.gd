@tool
extends RefCounted

class_name TwitchGetGamesResponse

## The list of categories and games. The list is empty if the specified categories and games weren’t found.
var data: Array[TwitchGame];

static func from_json(d: Dictionary) -> TwitchGetGamesResponse:
	var result = TwitchGetGamesResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

