@tool
extends RefCounted

class_name TwitchCheermoteImages

## No description available
var light: TwitchCheermoteImageTheme;
## No description available
var dark: TwitchCheermoteImageTheme;

static func from_json(d: Dictionary) -> TwitchCheermoteImages:
	var result = TwitchCheermoteImages.new();
	result.light = d["light"];
	result.dark = d["dark"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["light"] = light;
	d["dark"] = dark;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

