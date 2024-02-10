@tool
extends RefCounted

class_name TwitchStreamMarkerCreated

## An ID that identifies this marker.
var id: String;
## The UTC date and time (in RFC3339 format) of when the user created the marker.
var created_at: Variant;
## The relative offset (in seconds) of the marker from the beginning of the stream.
var position_seconds: int;
## A description that the user gave the marker to help them remember why they marked the location.
var description: String;

static func from_json(d: Dictionary) -> TwitchStreamMarkerCreated:
	var result = TwitchStreamMarkerCreated.new();




	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};




	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

