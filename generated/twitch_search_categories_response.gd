@tool
extends RefCounted

class_name TwitchSearchCategoriesResponse

## The list of games or categories that match the query. The list is empty if there are no matches.
var data: Array[TwitchCategory];

static func from_json(d: Dictionary) -> TwitchSearchCategoriesResponse:
	var result = TwitchSearchCategoriesResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

