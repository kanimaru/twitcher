@tool
extends RefCounted

class_name TwitchGetTopGamesResponse

## The list of broadcasts. The broadcasts are sorted by the number of viewers, with the most popular first.
var data: Array[TwitchGame];
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetTopGamesResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetTopGamesResponse:
	var result = TwitchGetTopGamesResponse.new();
	result.data = d["data"];

	result.pagination = GetTopGamesResponsePagination.from_json(d["pagination"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;

	d["pagination"] = pagination.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetTopGamesResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ or _before_ query parameter to get the next or previous page of results.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetTopGamesResponsePagination:
		var result = GetTopGamesResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

