@tool
extends RefCounted

class_name TwitchGetDropsEntitlementsResponse

## The list of entitlements.
var data: Array[TwitchDropsEntitlement];
## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetDropsEntitlementsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetDropsEntitlementsResponse:
	var result = TwitchGetDropsEntitlementsResponse.new();


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	d["pagination"] = pagination.to_dict();
{else}
	d["pagination"] = pagination;

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

