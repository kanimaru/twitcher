@tool
extends RefCounted

class_name TwitchGetContentClassificationLabelsResponse

## A list that contains information about the available content classification labels.
var data: Array[TwitchContentClassificationLabel];

static func from_json(d: Dictionary) -> TwitchGetContentClassificationLabelsResponse:
	var result = TwitchGetContentClassificationLabelsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

