@tool
extends RefCounted

class_name TwitchCheermoteImageTheme

## No description available
var animated_format: TwitchCheermoteImageFormat;
## No description available
var static_format: TwitchCheermoteImageFormat;

static func from_json(d: Dictionary) -> TwitchCheermoteImageTheme:
	var result = TwitchCheermoteImageTheme.new();


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

