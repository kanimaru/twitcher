@tool
extends RefCounted

class_name TwitchGetDropsEntitlementsResponse

## The list of entitlements.
var data: Array[TwitchDropsEntitlement];
## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetDropsEntitlementsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetDropsEntitlementsResponse:
	var result = TwitchGetDropsEntitlementsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchDropsEntitlement.from_json(value));
	if d.has("pagination") && d["pagination"] != null:
		result.pagination = GetDropsEntitlementsResponsePagination.from_json(d["pagination"]);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value.to_dict());
	if pagination != null:
		d["pagination"] = pagination.to_dict();
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetDropsEntitlementsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Set the request’s _after_ query parameter to this value to page forward through the results.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetDropsEntitlementsResponsePagination:
		var result = GetDropsEntitlementsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

