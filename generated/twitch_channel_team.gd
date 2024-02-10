@tool
extends RefCounted

class_name TwitchChannelTeam

## An ID that identifies the broadcaster.
var broadcaster_id: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## A URL to the team’s background image.
var background_image_url: String;
## A URL to the team’s banner.
var banner: String;
## The UTC date and time (in RFC3339 format) of when the team was created.
var created_at: Variant;
## The UTC date and time (in RFC3339 format) of the last time the team was updated.
var updated_at: Variant;
## The team’s description. The description may contain formatting such as Markdown, HTML, newline (\\n) characters, etc.
var info: String;
## A URL to a thumbnail image of the team’s logo.
var thumbnail_url: String;
## The team’s name.
var team_name: String;
## The team’s display name.
var team_display_name: String;
## An ID that identifies the team.
var id: String;

static func from_json(d: Dictionary) -> TwitchChannelTeam:
	var result = TwitchChannelTeam.new();












	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};












	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

