@tool
extends RefCounted

class_name TwitchAddBlockedTermBody

## The word or phrase to block from being used in the broadcaster’s chat room. The term must contain a minimum of 2 characters and may contain up to a maximum of 500 characters.      Terms may include a wildcard character (\*). The wildcard character must appear at the beginning or end of a word or set of characters. For example, \*foo or foo\*.      If the blocked term already exists, the response contains the existing blocked term.
var text: String;

static func from_json(d: Dictionary) -> TwitchAddBlockedTermBody:
	var result = TwitchAddBlockedTermBody.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

