@tool
extends RefCounted

class_name TwitchUserExtensionComponent

## A Boolean value that determines the extension’s activation state. If **false**, the user has not configured a component extension.
var active: bool;
## An ID that identifies the extension.
var id: String;
## The extension’s version.
var version: String;
## The extension’s name.
var name: String;
## The x-coordinate where the extension is placed.
var x: int;
## The y-coordinate where the extension is placed.
var y: int;

static func from_json(d: Dictionary) -> TwitchUserExtensionComponent:
	var result = TwitchUserExtensionComponent.new();






	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};






	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

