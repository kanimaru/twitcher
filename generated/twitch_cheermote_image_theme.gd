@tool
extends RefCounted

class_name TwitchCheermoteImageTheme

## No description available
var animated_format: TwitchCheermoteImageFormat;
## No description available
var static_format: TwitchCheermoteImageFormat;

static func from_json(d: Dictionary) -> TwitchCheermoteImageTheme:
	var result = TwitchCheermoteImageTheme.new();
	if d.has("animated") && d["animated"] != null:
		result.animated_format = d["animated"];
	if d.has("static") && d["static"] != null:
		result.static_format = d["static"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["animated"] = animated_format;
	d["static"] = static_format;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

