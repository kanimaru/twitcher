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
	result.broadcaster_id = d["broadcaster_id"];
	result.broadcaster_login = d["broadcaster_login"];
	result.broadcaster_name = d["broadcaster_name"];
	result.background_image_url = d["background_image_url"];
	result.banner = d["banner"];
	result.created_at = d["created_at"];
	result.updated_at = d["updated_at"];
	result.info = d["info"];
	result.thumbnail_url = d["thumbnail_url"];
	result.team_name = d["team_name"];
	result.team_display_name = d["team_display_name"];
	result.id = d["id"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["broadcaster_id"] = broadcaster_id;
	d["broadcaster_login"] = broadcaster_login;
	d["broadcaster_name"] = broadcaster_name;
	d["background_image_url"] = background_image_url;
	d["banner"] = banner;
	d["created_at"] = created_at;
	d["updated_at"] = updated_at;
	d["info"] = info;
	d["thumbnail_url"] = thumbnail_url;
	d["team_name"] = team_name;
	d["team_display_name"] = team_display_name;
	d["id"] = id;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

