@tool
extends RefCounted

class_name TwitchUpdateConduitsBody

## Conduit ID.
var id: String;
## The new number of shards for this conduit.
var shard_count: int;

static func from_json(d: Dictionary) -> TwitchUpdateConduitsBody:
	var result = TwitchUpdateConduitsBody.new();


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

