@tool
extends RefCounted

class_name TwitchGetStreamsResponse

## The list of streams.
var data: Array[TwitchStream];
## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetStreamsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetStreamsResponse:
	var result = TwitchGetStreamsResponse.new();


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
class GetStreamsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Set the request’s _after_ or _before_ query parameter to this value depending on whether you’re paging forwards or backwards.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetStreamsResponsePagination:
		var result = GetStreamsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

