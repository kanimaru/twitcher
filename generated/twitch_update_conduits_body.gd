@tool
extends RefCounted

class_name TwitchUpdateConduitsBody

## Conduit ID.
var id: String;
## The new number of shards for this conduit.
var shard_count: int;

static func from_json(d: Dictionary) -> TwitchUpdateConduitsBody:
	var result = TwitchUpdateConduitsBody.new();
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("shard_count") && d["shard_count"] != null:
		result.shard_count = d["shard_count"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["shard_count"] = shard_count;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());
