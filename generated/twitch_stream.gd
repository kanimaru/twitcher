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













	for value in d["tag_ids"]:
		result.tag_ids.append(value);
{elif property.is_typed_array}
	for value in d["tag_ids"]:
		result.tag_ids.append(.from_json(value));
{elif property.is_sub_class}
	result.tag_ids = Array[String].from_json(d["tag_ids"]);
{else}
	result.tag_ids = d["tag_ids"];


	for value in d["tags"]:
		result.tags.append(value);
{elif property.is_typed_array}
	for value in d["tags"]:
		result.tags.append(.from_json(value));
{elif property.is_sub_class}
	result.tags = Array[String].from_json(d["tags"]);
{else}
	result.tags = d["tags"];


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};















	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

