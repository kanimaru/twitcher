@tool
extends RefCounted

class_name TwitchCheermoteImageTheme

## No description available
var animated: TwitchCheermoteImageFormat;
## No description available
var static: TwitchCheermoteImageFormat;

static func from_json(d: Dictionary) -> TwitchCheermoteImageTheme:
	var result = TwitchCheermoteImageTheme.new();
	result.animated = d["animated"];
	result.static = d["static"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["animated"] = animated;
	d["static"] = static;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

