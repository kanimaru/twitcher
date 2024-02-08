@tool
extends RefCounted

class_name TwitchStream

## An ID that identifies the stream. You can use this ID later to look up the video on demand (VOD).
var id: String;
## The ID of the user that’s broadcasting the stream.
var user_id: String;
## The user’s login name.
var user_login: String;
## The user’s display name.
var user_name: String;
## The ID of the category or game being played.
var game_id: String;
## The ID of the category or game being played.
var game_name: String;
## The type of stream. Possible values are:      * live    If an error occurs, this field is set to an empty string.
var type: String;
## The stream’s title. Is an empty string if not set.
var title: String;
## The number of users watching the stream.
var viewer_count: int;
## The UTC date and time (in RFC3339 format) of when the broadcast began.
var started_at: Variant;
## The language that the stream uses. This is an ISO 639-1 two-letter language code or _other_ if the stream uses a language not in the list of [supported stream languages](https://help.twitch.tv/s/article/languages-on-twitch#streamlang).
var language: String;
## A URL to an image of a frame from the last 5 minutes of the stream. Replace the width and height placeholders in the URL (`{width}x{height}`) with the size of the image you want, in pixels.
var thumbnail_url: String;
## **IMPORTANT** As of February 28, 2023, this field is deprecated and returns only an empty array. If you use this field, please update your code to use the `tags` field.      The list of tags that apply to the stream. The list contains IDs only when the channel is steaming live. For a list of possible tags, see [List of All Tags](https://www.twitch.tv/directory/all/tags). The list doesn’t include Category Tags.
var tag_ids: Array[String];
## The tags applied to the stream.
var tags: Array[String];
## A Boolean value that indicates whether the stream is meant for mature audiences.
var is_mature: bool;

static func from_json(d: Dictionary) -> TwitchStream:
	var result = TwitchStream.new();
	result.id = d["id"];
	result.user_id = d["user_id"];
	result.user_login = d["user_login"];
	result.user_name = d["user_name"];
	result.game_id = d["game_id"];
	result.game_name = d["game_name"];
	result.type = d["type"];
	result.title = d["title"];
	result.viewer_count = d["viewer_count"];
	result.started_at = d["started_at"];
	result.language = d["language"];
	result.thumbnail_url = d["thumbnail_url"];
	result.tag_ids = d["tag_ids"];
	result.tags = d["tags"];
	result.is_mature = d["is_mature"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["user_id"] = user_id;
	d["user_login"] = user_login;
	d["user_name"] = user_name;
	d["game_id"] = game_id;
	d["game_name"] = game_name;
	d["type"] = type;
	d["title"] = title;
	d["viewer_count"] = viewer_count;
	d["started_at"] = started_at;
	d["language"] = language;
	d["thumbnail_url"] = thumbnail_url;
	d["tag_ids"] = tag_ids;
	d["tags"] = tags;
	d["is_mature"] = is_mature;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

