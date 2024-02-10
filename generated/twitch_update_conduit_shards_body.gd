@tool
extends RefCounted

class_name TwitchUpdateConduitShardsBody

## Conduit ID.
var conduit_id: String;
## List of shards to update.
var shards: Array;

static func from_json(d: Dictionary) -> TwitchUpdateConduitShardsBody:
	var result = TwitchUpdateConduitShardsBody.new();


	for value in d["shards"]:
		result.shards.append(value);
{elif property.is_typed_array}
	for value in d["shards"]:
		result.shards.append(.from_json(value));
{elif property.is_sub_class}
	result.shards = Array.from_json(d["shards"]);
{else}
	result.shards = d["shards"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

