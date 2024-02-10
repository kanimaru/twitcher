@tool
extends RefCounted

class_name TwitchStreamMarkers

## The ID of the user that created the marker.
var user_id: String;
## The user’s display name.
var user_name: String;
## The user’s login name.
var user_login: String;
## A list of videos that contain markers. The list contains a single video.
var videos: Array;
## An ID that identifies this video.
var video_id: String;
## The list of markers in this video. The list in ascending order by when the marker was created.
var markers: Array;

static func from_json(d: Dictionary) -> TwitchStreamMarkers:
	var result = TwitchStreamMarkers.new();




	for value in d["videos"]:
		result.videos.append(value);
{elif property.is_typed_array}
	for value in d["videos"]:
		result.videos.append(.from_json(value));
{elif property.is_sub_class}
	result.videos = Array.from_json(d["videos"]);
{else}
	result.videos = d["videos"];



	for value in d["markers"]:
		result.markers.append(value);
{elif property.is_typed_array}
	for value in d["markers"]:
		result.markers.append(.from_json(value));
{elif property.is_sub_class}
	result.markers = Array.from_json(d["markers"]);
{else}
	result.markers = d["markers"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};






	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

