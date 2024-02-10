@tool
extends RefCounted

class_name TwitchExtensionSecret

## The version number that identifies this definition of the secret’s data.
var format_version: int;
## The list of secrets.
var secrets: Array;

static func from_json(d: Dictionary) -> TwitchExtensionSecret:
	var result = TwitchExtensionSecret.new();
	if d.has("format_version") && d["format_version"] != null:
		result.format_version = d["format_version"];
	if d.has("secrets") && d["secrets"] != null:
		for value in d["secrets"]:
			result.secrets.append(value);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["format_version"] = format_version;
	d["secrets"] = [];
	if secrets != null:
		for value in secrets:
			d["secrets"].append(value);
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

