@tool
extends RefCounted

class_name TwitchUserExtensionPanelUpdate

## A Boolean value that determines the extension’s activation state. If **false**, the user has not configured a panel extension.
var active: bool;
## An ID that identifies the extension.
var id: String;
## The extension’s version.
var version: String;

static func from_json(d: Dictionary) -> TwitchUserExtensionPanelUpdate:
	var result = TwitchUserExtensionPanelUpdate.new();
	result.active = d["active"];
	result.id = d["id"];
	result.version = d["version"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["active"] = active;
	d["id"] = id;
	d["version"] = version;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

