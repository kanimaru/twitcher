@tool
extends RefCounted

class_name TwitchGetAllStreamTagsResponse

## The list of stream tags that the broadcaster can apply to their channel.
var data: Array[TwitchStreamTag];
## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetAllStreamTagsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetAllStreamTagsResponse:
	var result = TwitchGetAllStreamTagsResponse.new();
	result.data = d["data"];

	result.pagination = GetAllStreamTagsResponsePagination.from_json(d["pagination"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;

	d["pagination"] = pagination.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetAllStreamTagsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Set the request’s _after_ query parameter to this value to page forwards through the results.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetAllStreamTagsResponsePagination:
		var result = GetAllStreamTagsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

