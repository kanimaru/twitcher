@tool
extends RefCounted

class_name TwitchExtensionSecret

## The version number that identifies this definition of the secret’s data.
var format_version: int;
## The list of secrets.
var secrets: Array;

static func from_json(d: Dictionary) -> TwitchExtensionSecret:
	var result = TwitchExtensionSecret.new();
	result.format_version = d["format_version"];
	result.secrets = d["secrets"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["format_version"] = format_version;
	d["secrets"] = secrets;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

