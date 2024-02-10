@tool
extends RefCounted

class_name TwitchUpdateConduitShardsBody

## Conduit ID.
var conduit_id: String;
## List of shards to update.
var shards: Array;

static func from_json(d: Dictionary) -> TwitchUpdateConduitShardsBody:
	var result = TwitchUpdateConduitShardsBody.new();
	if d.has("conduit_id") && d["conduit_id"] != null:
		result.conduit_id = d["conduit_id"];
	if d.has("shards") && d["shards"] != null:
		for value in d["shards"]:
			result.shards.append(value);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["conduit_id"] = conduit_id;
	d["shards"] = [];
	if shards != null:
		for value in shards:
			d["shards"].append(value);
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

