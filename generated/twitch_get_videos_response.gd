@tool
extends RefCounted

class_name TwitchGetVideosResponse

## The list of published videos that match the filter criteria.
var data: Array[TwitchVideo];
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetVideosResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetVideosResponse:
	var result = TwitchGetVideosResponse.new();


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
class GetVideosResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request's _after_ or _before_ query parameter depending on whether you're paging forwards or backwards through the results.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetVideosResponsePagination:
		var result = GetVideosResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

