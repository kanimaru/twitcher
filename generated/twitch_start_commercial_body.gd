@tool
extends RefCounted

class_name TwitchStartCommercialBody

## The ID of the partner or affiliate broadcaster that wants to run the commercial. This ID must match the user ID found in the OAuth token.
var broadcaster_id: String;
## The length of the commercial to run, in seconds. Twitch tries to serve a commercial that’s the requested length, but it may be shorter or longer. The maximum length you should request is 180 seconds.
var length: int;

static func from_json(d: Dictionary) -> TwitchStartCommercialBody:
	var result = TwitchStartCommercialBody.new();


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

