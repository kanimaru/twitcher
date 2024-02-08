@tool
extends RefCounted

class_name TwitchVideo

## An ID that identifies the video.
var id: String;
## The ID of the stream that the video originated from if the video's type is "archive;" otherwise, **null**.
var stream_id: String;
## The ID of the broadcaster that owns the video.
var user_id: String;
## The broadcaster's login name.
var user_login: String;
## The broadcaster's display name.
var user_name: String;
## The video's title.
var title: String;
## The video's description.
var description: String;
## The date and time, in UTC, of when the video was created. The timestamp is in RFC3339 format.
var created_at: Variant;
## The date and time, in UTC, of when the video was published. The timestamp is in RFC3339 format.
var published_at: Variant;
## The video's URL.
var url: String;
## A URL to a thumbnail image of the video. Before using the URL, you must replace the `%{width}` and `%{height}` placeholders with the width and height of the thumbnail you want returned. Due to current limitations, `${width}` must be 320 and `${height}` must be 180.
var thumbnail_url: String;
## The video's viewable state. Always set to **public**.
var viewable: String;
## The number of times that users have watched the video.
var view_count: int;
## The ISO 639-1 two-letter language code that the video was broadcast in. For example, the language code is DE if the video was broadcast in German. For a list of supported languages, see [Supported Stream Language](https://help.twitch.tv/s/article/languages-on-twitch#streamlang). The language value is "other" if the video was broadcast in a language not in the list of supported languages.
var language: String;
## The video's type. Possible values are:      * archive — An on-demand video (VOD) of one of the broadcaster's past streams. * highlight — A highlight reel of one of the broadcaster's past streams. See [Creating Highlights](https://help.twitch.tv/s/article/creating-highlights-and-stream-markers). * upload — A video that the broadcaster uploaded to their video library. See Upload under [Video Producer](https://help.twitch.tv/s/article/video-on-demand?language=en%5FUS#videoproducer).
var type: String;
## The video's length in ISO 8601 duration format. For example, 3m21s represents 3 minutes, 21 seconds.
var duration: String;
## The segments that Twitch Audio Recognition muted; otherwise, **null**.
var muted_segments: Array;

static func from_json(d: Dictionary) -> TwitchVideo:
	var result = TwitchVideo.new();
	result.id = d["id"];
	result.stream_id = d["stream_id"];
	result.user_id = d["user_id"];
	result.user_login = d["user_login"];
	result.user_name = d["user_name"];
	result.title = d["title"];
	result.description = d["description"];
	result.created_at = d["created_at"];
	result.published_at = d["published_at"];
	result.url = d["url"];
	result.thumbnail_url = d["thumbnail_url"];
	result.viewable = d["viewable"];
	result.view_count = d["view_count"];
	result.language = d["language"];
	result.type = d["type"];
	result.duration = d["duration"];
	result.muted_segments = d["muted_segments"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["stream_id"] = stream_id;
	d["user_id"] = user_id;
	d["user_login"] = user_login;
	d["user_name"] = user_name;
	d["title"] = title;
	d["description"] = description;
	d["created_at"] = created_at;
	d["published_at"] = published_at;
	d["url"] = url;
	d["thumbnail_url"] = thumbnail_url;
	d["viewable"] = viewable;
	d["view_count"] = view_count;
	d["language"] = language;
	d["type"] = type;
	d["duration"] = duration;
	d["muted_segments"] = muted_segments;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

