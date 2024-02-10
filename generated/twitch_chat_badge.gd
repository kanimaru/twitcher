@tool
extends RefCounted

class_name TwitchChatBadge

## An ID that identifies this set of chat badges. For example, Bits or Subscriber.
var set_id: String;
## The list of chat badges in this set.
var versions: Array;

static func from_json(d: Dictionary) -> TwitchChatBadge:
	var result = TwitchChatBadge.new();


	for value in d["versions"]:
		result.versions.append(value);
{elif property.is_typed_array}
	for value in d["versions"]:
		result.versions.append(.from_json(value));
{elif property.is_sub_class}
	result.versions = Array.from_json(d["versions"]);
{else}
	result.versions = d["versions"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

