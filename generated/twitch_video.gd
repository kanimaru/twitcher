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

















	for value in d["muted_segments"]:
		result.muted_segments.append(value);
{elif property.is_typed_array}
	for value in d["muted_segments"]:
		result.muted_segments.append(.from_json(value));
{elif property.is_sub_class}
	result.muted_segments = Array.from_json(d["muted_segments"]);
{else}
	result.muted_segments = d["muted_segments"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

















	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

