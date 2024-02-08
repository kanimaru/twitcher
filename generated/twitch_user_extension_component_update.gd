@tool
extends RefCounted

class_name TwitchUserExtensionComponentUpdate

## A Boolean value that determines the extension’s activation state. If **false**, the user has not configured a component extension.
var active: bool;
## An ID that identifies the extension.
var id: String;
## The extension’s version.
var version: String;
## The x-coordinate where the extension is placed.
var x: int;
## The y-coordinate where the extension is placed.
var y: int;

static func from_json(d: Dictionary) -> TwitchUserExtensionComponentUpdate:
	var result = TwitchUserExtensionComponentUpdate.new();
	result.active = d["active"];
	result.id = d["id"];
	result.version = d["version"];
	result.x = d["x"];
	result.y = d["y"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["active"] = active;
	d["id"] = id;
	d["version"] = version;
	d["x"] = x;
	d["y"] = y;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

