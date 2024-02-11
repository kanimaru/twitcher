@tool
extends RefCounted

class_name TwitchGetConduitShardsResponse

## List of information about a conduit's shards.
var data: Array;
## Contains information used to page through a list of results. The object is empty if there are no more pages left to page through.
var pagination: Pagination;

static func from_json(d: Dictionary) -> TwitchGetConduitShardsResponse:
	var result = TwitchGetConduitShardsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(value);
	if d.has("pagination") && d["pagination"] != null:
		result.pagination = Pagination.from_json(d["pagination"]);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value);
	if pagination != null:
		d["pagination"] = pagination.to_dict();
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains information used to page through a list of results. The object is empty if there are no more pages left to page through.
class Pagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s after query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> Pagination:
		var result = Pagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

