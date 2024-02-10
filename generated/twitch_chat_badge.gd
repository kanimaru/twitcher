@tool
extends RefCounted

class_name TwitchChatBadge

## An ID that identifies this set of chat badges. For example, Bits or Subscriber.
var set_id: String;
## The list of chat badges in this set.
var versions: Array;

static func from_json(d: Dictionary) -> TwitchChatBadge:
	var result = TwitchChatBadge.new();
	if d.has("set_id") && d["set_id"] != null:
		result.set_id = d["set_id"];
	if d.has("versions") && d["versions"] != null:
		for value in d["versions"]:
			result.versions.append(value);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["set_id"] = set_id;
	d["versions"] = [];
	if versions != null:
		for value in versions:
			d["versions"].append(value);
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

