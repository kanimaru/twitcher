@tool
extends RefCounted

class_name TwitchGetPollsResponse

## A list of polls. The polls are returned in descending order of start time unless you specify IDs in the request, in which case they’re returned in the same order as you passed them in the request. The list is empty if the broadcaster hasn’t created polls.
var data: Array[TwitchPoll];
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetPollsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetPollsResponse:
	var result = TwitchGetPollsResponse.new();


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
class GetPollsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetPollsResponsePagination:
		var result = GetPollsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

