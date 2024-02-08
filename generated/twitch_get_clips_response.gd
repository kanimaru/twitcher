@tool
extends RefCounted

class_name TwitchGetClipsResponse

## The list of video clips. For clips returned by _game\_id_ or _broadcaster\_id_, the list is in descending order by view count. For lists returned by _id_, the list is in the same order as the input IDs.
var data: Array[TwitchClip];
## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetClipsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetClipsResponse:
	var result = TwitchGetClipsResponse.new();
	result.data = d["data"];

	result.pagination = GetClipsResponsePagination.from_json(d["pagination"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;

	d["pagination"] = pagination.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetClipsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Set the request’s _after_ or _before_ query parameter to this value depending on whether you’re paging forwards or backwards.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetClipsResponsePagination:
		var result = GetClipsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

