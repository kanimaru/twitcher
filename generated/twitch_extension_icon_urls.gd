@tool
extends RefCounted

class_name TwitchExtensionIconUrls

## No description available
var 100x100: String;
## No description available
var 24x24: String;
## No description available
var 300x200: String;

static func from_json(d: Dictionary) -> TwitchExtensionIconUrls:
	var result = TwitchExtensionIconUrls.new();
	result.100x100 = d["100x100"];
	result.24x24 = d["24x24"];
	result.300x200 = d["300x200"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["100x100"] = 100x100;
	d["24x24"] = 24x24;
	d["300x200"] = 300x200;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

