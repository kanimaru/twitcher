@tool
extends RefCounted

class_name TwitchUpdateConduitShardsBody

## Conduit ID.
var conduit_id: String;
## List of shards to update.
var shards: Array;

static func from_json(d: Dictionary) -> TwitchUpdateConduitShardsBody:
	var result = TwitchUpdateConduitShardsBody.new();
	result.conduit_id = d["conduit_id"];
	result.shards = d["shards"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["conduit_id"] = conduit_id;
	d["shards"] = shards;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

