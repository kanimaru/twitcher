@tool
extends RefCounted

class_name TwitchGetConduitShardsResponse

## List of information about a conduit's shards.
var data: Array;
## Contains information used to page through a list of results. The object is empty if there are no more pages left to page through.
var pagination: GetConduitShardsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetConduitShardsResponse:
	var result = TwitchGetConduitShardsResponse.new();
	result.data = d["data"];

	result.pagination = GetConduitShardsResponsePagination.from_json(d["pagination"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;

	d["pagination"] = pagination.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains information used to page through a list of results. The object is empty if there are no more pages left to page through.
class GetConduitShardsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s after query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetConduitShardsResponsePagination:
		var result = GetConduitShardsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

