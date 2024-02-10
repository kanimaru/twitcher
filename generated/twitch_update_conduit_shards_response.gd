@tool
extends RefCounted

class_name TwitchUpdateConduitShardsResponse

## List of successful shard updates.
var data: Array;
## List of unsuccessful updates.
var errors: Array;

static func from_json(d: Dictionary) -> TwitchUpdateConduitShardsResponse:
	var result = TwitchUpdateConduitShardsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(value);
	if d.has("errors") && d["errors"] != null:
		for value in d["errors"]:
			result.errors.append(value);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value);
	d["errors"] = [];
	if errors != null:
		for value in errors:
			d["errors"].append(value);
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

