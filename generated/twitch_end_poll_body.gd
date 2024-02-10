@tool
extends RefCounted

class_name TwitchEndPollBody

## The ID of the broadcaster that’s running the poll. This ID must match the user ID in the user access token.
var broadcaster_id: String;
## The ID of the poll to update.
var id: String;
## The status to set the poll to. Possible case-sensitive values are:      * TERMINATED — Ends the poll before the poll is scheduled to end. The poll remains publicly visible. * ARCHIVED — Ends the poll before the poll is scheduled to end, and then archives it so it's no longer publicly visible.
var status: String;

static func from_json(d: Dictionary) -> TwitchEndPollBody:
	var result = TwitchEndPollBody.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

