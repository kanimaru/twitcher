@tool
extends RefCounted

class_name TwitchGetExtensionConfigurationSegmentResponse

## The list of requested configuration segments. The list is returned in the same order that you specified the list of segments in the request.
var data: Array[TwitchExtensionConfigurationSegment];

static func from_json(d: Dictionary) -> TwitchGetExtensionConfigurationSegmentResponse:
	var result = TwitchGetExtensionConfigurationSegmentResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

