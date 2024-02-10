@tool
extends RefCounted

class_name TwitchUserExtensionOverlay

## A Boolean value that determines the extension’s activation state. If **false**, the user has not configured an overlay extension.
var active: bool;
## An ID that identifies the extension.
var id: String;
## The extension’s version.
var version: String;
## The extension’s name.
var name: String;

static func from_json(d: Dictionary) -> TwitchUserExtensionOverlay:
	var result = TwitchUserExtensionOverlay.new();




	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};




	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

