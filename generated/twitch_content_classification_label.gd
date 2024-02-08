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
	result.id = d["id"];
	result.description = d["description"];
	result.name = d["name"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["description"] = description;
	d["name"] = name;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

