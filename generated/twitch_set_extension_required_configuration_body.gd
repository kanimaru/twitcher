@tool
extends RefCounted

class_name TwitchSetExtensionRequiredConfigurationBody

## The ID of the extension to update.
var extension_id: String;
## The version of the extension to update.
var extension_version: String;
## The required\_configuration string to use with the extension.
var required_configuration: String;

static func from_json(d: Dictionary) -> TwitchSetExtensionRequiredConfigurationBody:
	var result = TwitchSetExtensionRequiredConfigurationBody.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

