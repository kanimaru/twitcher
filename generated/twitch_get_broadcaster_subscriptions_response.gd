@tool
extends RefCounted

class_name TwitchGetBroadcasterSubscriptionsResponse

## The list of users that subscribe to the broadcaster. The list is empty if the broadcaster has no subscribers.
var data: Array[TwitchBroadcasterSubscription];
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetBroadcasterSubscriptionsResponsePagination;
## The current number of subscriber points earned by this broadcaster. Points are based on the subscription tier of each user that subscribes to this broadcaster. For example, a Tier 1 subscription is worth 1 point, Tier 2 is worth 2 points, and Tier 3 is worth 6 points. The number of points determines the number of emote slots that are unlocked for the broadcaster (see [Subscriber Emote Slots](https://help.twitch.tv/s/article/subscriber-emote-guide#emoteslots)).
var points: int;
## The total number of users that subscribe to this broadcaster.
var total: int;

static func from_json(d: Dictionary) -> TwitchGetBroadcasterSubscriptionsResponse:
	var result = TwitchGetBroadcasterSubscriptionsResponse.new();
	result.data = d["data"];

	result.pagination = GetBroadcasterSubscriptionsResponsePagination.from_json(d["pagination"]);

	result.points = d["points"];
	result.total = d["total"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;

	d["pagination"] = pagination.to_dict();

	d["points"] = points;
	d["total"] = total;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetBroadcasterSubscriptionsResponsePagination extends RefCounted:
	## The cursor used to get the next or previous page of results. Use the cursor to set the request’s _after_ or _before_ query parameter depending on whether you’re paging forwards or backwards.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetBroadcasterSubscriptionsResponsePagination:
		var result = GetBroadcasterSubscriptionsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

