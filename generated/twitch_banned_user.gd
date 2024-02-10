@tool
extends RefCounted

class_name TwitchBannedUser

## The ID of the banned user.
var user_id: String;
## The banned user’s login name.
var user_login: String;
## The banned user’s display name.
var user_name: String;
## The UTC date and time (in RFC3339 format) of when the timeout expires, or an empty string if the user is permanently banned.
var expires_at: Variant;
## The UTC date and time (in RFC3339 format) of when the user was banned.
var created_at: Variant;
## The reason the user was banned or put in a timeout if the moderator provided one.
var reason: String;
## The ID of the moderator that banned the user or put them in a timeout.
var moderator_id: String;
## The moderator’s login name.
var moderator_login: String;
## The moderator’s display name.
var moderator_name: String;

static func from_json(d: Dictionary) -> TwitchBannedUser:
	var result = TwitchBannedUser.new();









	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};









	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

