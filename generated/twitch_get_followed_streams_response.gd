@tool
extends RefCounted

class_name TwitchGetFollowedStreamsResponse

## The list of live streams of broadcasters that the specified user follows. The list is in descending order by the number of viewers watching the stream. Because viewers come and go during a stream, it’s possible to find duplicate or missing streams in the list as you page through the results. The list is empty if none of the followed broadcasters are streaming live.
var data: Array[TwitchStream];
## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetFollowedStreamsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetFollowedStreamsResponse:
	var result = TwitchGetFollowedStreamsResponse.new();


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
class GetFollowedStreamsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Set the request’s _after_ query parameter to this value.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetFollowedStreamsResponsePagination:
		var result = GetFollowedStreamsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

