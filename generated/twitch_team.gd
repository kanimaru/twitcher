@tool
extends RefCounted

class_name TwitchTeam

## The list of team members.
var users: Array;
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

static func from_json(d: Dictionary) -> TwitchTeam:
	var result = TwitchTeam.new();

	for value in d["users"]:
		result.users.append(value);
{elif property.is_typed_array}
	for value in d["users"]:
		result.users.append(.from_json(value));
{elif property.is_sub_class}
	result.users = Array.from_json(d["users"]);
{else}
	result.users = d["users"];










	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};










	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

