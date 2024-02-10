@tool
extends RefCounted

class_name TwitchSetExtensionConfigurationSegmentBody

## The ID of the extension to update.
var extension_id: String;
## The configuration segment to update. Possible case-sensitive values are:      * broadcaster * developer * global
var segment: String;
## The ID of the broadcaster that installed the extension. Include this field only if the `segment` is set to developer or broadcaster.
var broadcaster_id: String;
## The contents of the segment. This string may be a plain-text string or a string-encoded JSON object.
var content: String;
## The version number that identifies this definition of the segment’s data. If not specified, the latest definition is updated.
var version: String;

static func from_json(d: Dictionary) -> TwitchSetExtensionConfigurationSegmentBody:
	var result = TwitchSetExtensionConfigurationSegmentBody.new();





	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};





	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

