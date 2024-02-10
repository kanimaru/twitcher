@tool
extends RefCounted

class_name TwitchGetChannelFollowersResponse

## The list of users that follow the specified broadcaster. The list is in descending order by `followed_at` (with the most recent follower first). The list is empty if nobody follows the broadcaster, the specified `user_id` isn’t in the follower list, the user access token is missing the **moderator:read:followers** scope, or the user isn’t the broadcaster or moderator for the channel.
var data: Array;
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read more](https://dev.twitch.tv/docs/api/guide#pagination).
var pagination: GetChannelFollowersResponsePagination;
## The total number of users that follow this broadcaster. As someone pages through the list, the number of users may change as users follow or unfollow the broadcaster.
var total: int;

static func from_json(d: Dictionary) -> TwitchGetChannelFollowersResponse:
	var result = TwitchGetChannelFollowersResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(value);
	if d.has("pagination") && d["pagination"] != null:
		result.pagination = GetChannelFollowersResponsePagination.from_json(d["pagination"]);
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
class GetChannelFollowersResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetChannelFollowersResponsePagination:
		var result = GetChannelFollowersResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

