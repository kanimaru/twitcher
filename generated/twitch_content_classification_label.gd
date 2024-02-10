@tool
extends RefCounted

class_name TwitchContentClassificationLabel

## Unique identifier for the CCL.
var id: String;
## Localized description of the CCL.
var description: String;
## Localized name of the CCL.
var name: String;

static func from_json(d: Dictionary) -> TwitchContentClassificationLabel:
	var result = TwitchContentClassificationLabel.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

