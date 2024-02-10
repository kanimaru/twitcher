@tool
extends RefCounted

class_name TwitchCreateConduitsBody

## The number of shards to create for this conduit.
var shard_count: int;

static func from_json(d: Dictionary) -> TwitchCreateConduitsBody:
	var result = TwitchCreateConduitsBody.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

