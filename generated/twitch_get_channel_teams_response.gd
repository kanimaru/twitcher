@tool
extends RefCounted

class_name TwitchGetChannelTeamsResponse

## The list of teams that the broadcaster is a member of. Returns an empty array if the broadcaster is not a member of a team.
var data: Array[TwitchChannelTeam];

static func from_json(d: Dictionary) -> TwitchGetChannelTeamsResponse:
	var result = TwitchGetChannelTeamsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

