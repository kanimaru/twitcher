@tool
extends RefCounted

class_name TwitchUserExtension

## An ID that identifies the extension.
var id: String;
## The extension's version.
var version: String;
## The extension's name.
var name: String;
## A Boolean value that determines whether the extension is configured and can be activated. Is **true** if the extension is configured and can be activated.
var can_activate: bool;
## The extension types that you can activate for this extension. Possible values are:      * component * mobile * overlay * panel
var type: Array[String];

static func from_json(d: Dictionary) -> TwitchUserExtension:
	var result = TwitchUserExtension.new();
	result.id = d["id"];
	result.version = d["version"];
	result.name = d["name"];
	result.can_activate = d["can_activate"];
	result.type = d["type"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["version"] = version;
	d["name"] = name;
	d["can_activate"] = can_activate;
	d["type"] = type;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

