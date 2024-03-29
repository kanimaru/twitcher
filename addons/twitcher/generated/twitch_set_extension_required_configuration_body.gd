@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchSetExtensionRequiredConfigurationBody

## The ID of the extension to update.
var extension_id: String;
## The version of the extension to update.
var extension_version: String;
## The required\_configuration string to use with the extension.
var required_configuration: String;

static func from_json(d: Dictionary) -> TwitchSetExtensionRequiredConfigurationBody:
	var result = TwitchSetExtensionRequiredConfigurationBody.new();
	if d.has("extension_id") && d["extension_id"] != null:
		result.extension_id = d["extension_id"];
	if d.has("extension_version") && d["extension_version"] != null:
		result.extension_version = d["extension_version"];
	if d.has("required_configuration") && d["required_configuration"] != null:
		result.required_configuration = d["required_configuration"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["extension_id"] = extension_id;
	d["extension_version"] = extension_version;
	d["required_configuration"] = required_configuration;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

