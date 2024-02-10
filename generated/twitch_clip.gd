@tool
extends RefCounted

class_name TwitchClip

## An ID that uniquely identifies the clip.
var id: String;
## A URL to the clip.
var url: String;
## A URL that you can use in an iframe to embed the clip (see [Embedding Video and Clips](https://dev.twitch.tv/docs/embed/video-and-clips)).
var embed_url: String;
## An ID that identifies the broadcaster that the video was clipped from.
var broadcaster_id: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## An ID that identifies the user that created the clip.
var creator_id: String;
## The user’s display name.
var creator_name: String;
## An ID that identifies the video that the clip came from. This field contains an empty string if the video is not available.
var video_id: String;
## The ID of the game that was being played when the clip was created.
var game_id: String;
## The ISO 639-1 two-letter language code that the broadcaster broadcasts in. For example, _en_ for English. The value is _other_ if the broadcaster uses a language that Twitch doesn’t support.
var language: String;
## The title of the clip.
var title: String;
## The number of times the clip has been viewed.
var view_count: int;
## The date and time of when the clip was created. The date and time is in RFC3339 format.
var created_at: Variant;
## A URL to a thumbnail image of the clip.
var thumbnail_url: String;
## The length of the clip, in seconds. Precision is 0.1.
var duration: Variant;
## The zero-based offset, in seconds, to where the clip starts in the video (VOD). Is **null** if the video is not available or hasn’t been created yet from the live stream (see `video_id`).      Note that there’s a delay between when a clip is created during a broadcast and when the offset is set. During the delay period, `vod_offset` is **null**. The delay is indeterminant but is typically minutes long.
var vod_offset: int;
## A Boolean value that indicates if the clip is featured or not.
var is_featured: bool;

static func from_json(d: Dictionary) -> TwitchClip:
	var result = TwitchClip.new();

















	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

















	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

