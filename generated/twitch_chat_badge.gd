@tool
extends RefCounted

class_name TwitchChatBadge

## An ID that identifies this set of chat badges. For example, Bits or Subscriber.
var set_id: String;
## The list of chat badges in this set.
var versions: Array;

static func from_json(d: Dictionary) -> TwitchChatBadge:
	var result = TwitchChatBadge.new();
	result.set_id = d["set_id"];
	result.versions = d["versions"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["set_id"] = set_id;
	d["versions"] = versions;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

