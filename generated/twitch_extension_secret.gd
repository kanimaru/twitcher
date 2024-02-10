@tool
extends RefCounted

class_name TwitchExtensionSecret

## The version number that identifies this definition of the secret’s data.
var format_version: int;
## The list of secrets.
var secrets: Array;

static func from_json(d: Dictionary) -> TwitchExtensionSecret:
	var result = TwitchExtensionSecret.new();


	for value in d["secrets"]:
		result.secrets.append(value);
{elif property.is_typed_array}
	for value in d["secrets"]:
		result.secrets.append(.from_json(value));
{elif property.is_sub_class}
	result.secrets = Array.from_json(d["secrets"]);
{else}
	result.secrets = d["secrets"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

