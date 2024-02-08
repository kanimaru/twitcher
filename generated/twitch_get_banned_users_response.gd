@tool
extends RefCounted

class_name TwitchGetBannedUsersResponse

## The list of users that were banned or put in a timeout.
var data: Array[TwitchBannedUser];
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetBannedUsersResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetBannedUsersResponse:
	var result = TwitchGetBannedUsersResponse.new();
	result.data = d["data"];

	result.pagination = GetBannedUsersResponsePagination.from_json(d["pagination"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;

	d["pagination"] = pagination.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetBannedUsersResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetBannedUsersResponsePagination:
		var result = GetBannedUsersResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

