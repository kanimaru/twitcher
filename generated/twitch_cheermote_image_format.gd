@tool
extends RefCounted

class_name TwitchCheermoteImageFormat

## No description available
var _1: String;
## No description available
var _2: String;
## No description available
var _3: String;
## No description available
var _4: String;
## No description available
var _1_5: String;

static func from_json(d: Dictionary) -> TwitchCheermoteImageFormat:
	var result = TwitchCheermoteImageFormat.new();





	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};





	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

