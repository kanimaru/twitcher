@tool
extends RefCounted

class_name TwitchExtensionConfigurationSegment

## The type of segment. Possible values are:       * broadcaster * developer * global
var segment: String;
## The ID of the broadcaster that installed the extension. The object includes this field only if the `segment` query parameter is set to developer or broadcaster.
var broadcaster_id: String;
## The contents of the segment. This string may be a plain-text string or a string-encoded JSON object.
var content: String;
## The version number that identifies this definition of the segment’s data.
var version: String;

static func from_json(d: Dictionary) -> TwitchExtensionConfigurationSegment:
	var result = TwitchExtensionConfigurationSegment.new();




	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};




	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

