@tool
extends RefCounted

class_name TwitchExtensionIconUrls

## No description available
var _100x100: String;
## No description available
var _24x24: String;
## No description available
var _300x200: String;

static func from_json(d: Dictionary) -> TwitchExtensionIconUrls:
	var result = TwitchExtensionIconUrls.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

