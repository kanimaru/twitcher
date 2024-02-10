@tool
extends RefCounted

class_name TwitchGetBlockedTermsResponse

## The list of blocked terms. The list is in descending order of when they were created (see the `created_at` timestamp).
var data: Array[TwitchBlockedTerm];
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetBlockedTermsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetBlockedTermsResponse:
	var result = TwitchGetBlockedTermsResponse.new();


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	d["pagination"] = pagination.to_dict();
{else}
	d["pagination"] = pagination;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetBlockedTermsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetBlockedTermsResponsePagination:
		var result = GetBlockedTermsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

