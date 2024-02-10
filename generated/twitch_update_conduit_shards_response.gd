@tool
extends RefCounted

class_name TwitchUpdateConduitShardsResponse

## List of successful shard updates.
var data: Array;
## List of unsuccessful updates.
var errors: Array;

static func from_json(d: Dictionary) -> TwitchUpdateConduitShardsResponse:
	var result = TwitchUpdateConduitShardsResponse.new();

	for value in d["data"]:
		result.data.append(value);
{elif property.is_typed_array}
	for value in d["data"]:
		result.data.append(.from_json(value));
{elif property.is_sub_class}
	result.data = Array.from_json(d["data"]);
{else}
	result.data = d["data"];


	for value in d["errors"]:
		result.errors.append(value);
{elif property.is_typed_array}
	for value in d["errors"]:
		result.errors.append(.from_json(value));
{elif property.is_sub_class}
	result.errors = Array.from_json(d["errors"]);
{else}
	result.errors = d["errors"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

