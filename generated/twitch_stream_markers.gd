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
	result.user_id = d["user_id"];
	result.user_name = d["user_name"];
	result.user_login = d["user_login"];
	result.videos = d["videos"];
	result.video_id = d["video_id"];
	result.markers = d["markers"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["user_id"] = user_id;
	d["user_name"] = user_name;
	d["user_login"] = user_login;
	d["videos"] = videos;
	d["video_id"] = video_id;
	d["markers"] = markers;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

