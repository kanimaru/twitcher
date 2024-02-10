@tool
extends RefCounted

class_name TwitchGetFollowedChannelsResponse

## The list of broadcasters that the user follows. The list is in descending order by `followed_at` (with the most recently followed broadcaster first). The list is empty if the user doesn’t follow anyone.
var data: Array;
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read more](https://dev.twitch.tv/docs/api/guide#pagination).
var pagination: GetFollowedChannelsResponsePagination;
## The total number of broadcasters that the user follows. As someone pages through the list, the number may change as the user follows or unfollows broadcasters.
var total: int;

static func from_json(d: Dictionary) -> TwitchGetFollowedChannelsResponse:
	var result = TwitchGetFollowedChannelsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(value);
	if d.has("pagination") && d["pagination"] != null:
		result.pagination = GetFollowedChannelsResponsePagination.from_json(d["pagination"]);
	if d.has("total") && d["total"] != null:
		result.total = d["total"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value);
	if pagination != null:
		d["pagination"] = pagination.to_dict();
	d["total"] = total;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read more](https://dev.twitch.tv/docs/api/guide#pagination).
class GetFollowedChannelsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetFollowedChannelsResponsePagination:
		var result = GetFollowedChannelsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

