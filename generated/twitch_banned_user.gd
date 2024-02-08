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
	result.user_id = d["user_id"];
	result.user_login = d["user_login"];
	result.user_name = d["user_name"];
	result.expires_at = d["expires_at"];
	result.created_at = d["created_at"];
	result.reason = d["reason"];
	result.moderator_id = d["moderator_id"];
	result.moderator_login = d["moderator_login"];
	result.moderator_name = d["moderator_name"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["user_id"] = user_id;
	d["user_login"] = user_login;
	d["user_name"] = user_name;
	d["expires_at"] = expires_at;
	d["created_at"] = created_at;
	d["reason"] = reason;
	d["moderator_id"] = moderator_id;
	d["moderator_login"] = moderator_login;
	d["moderator_name"] = moderator_name;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

