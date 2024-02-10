@tool
extends RefCounted

class_name TwitchBitsLeaderboard

## An ID that identifies a user on the leaderboard.
var user_id: String;
## The user’s login name.
var user_login: String;
## The user’s display name.
var user_name: String;
## The user’s position on the leaderboard.
var rank: int;
## The number of Bits the user has cheered.
var score: int;

static func from_json(d: Dictionary) -> TwitchBitsLeaderboard:
	var result = TwitchBitsLeaderboard.new();





	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};





	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

