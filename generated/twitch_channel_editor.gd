@tool
extends RefCounted

class_name TwitchChannelEditor

## An ID that uniquely identifies a user with editor permissions.
var user_id: String;
## The user’s display name.
var user_name: String;
## The date and time, in RFC3339 format, when the user became one of the broadcaster’s editors.
var created_at: Variant;

static func from_json(d: Dictionary) -> TwitchChannelEditor:
	var result = TwitchChannelEditor.new();



	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

