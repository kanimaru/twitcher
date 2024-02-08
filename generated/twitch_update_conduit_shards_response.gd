@tool
extends RefCounted

class_name TwitchUpdateConduitShardsResponse

## List of successful shard updates.
var data: Array;
## List of unsuccessful updates.
var errors: Array;

static func from_json(d: Dictionary) -> TwitchUpdateConduitShardsResponse:
	var result = TwitchUpdateConduitShardsResponse.new();
	result.data = d["data"];
	result.errors = d["errors"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	d["errors"] = errors;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

