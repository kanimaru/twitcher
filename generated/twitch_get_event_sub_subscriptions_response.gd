@tool
extends RefCounted

class_name TwitchGetEventSubSubscriptionsResponse

## The list of subscriptions. The list is ordered by the oldest subscription first. The list is empty if the client hasn't created subscriptions or there are no subscriptions that match the specified filter criteria.
var data: Array[TwitchEventSubSubscription];
## The total number of subscriptions that you've created.
var total: int;
## The sum of all of your subscription costs. [Learn More](https://dev.twitch.tv/docs/eventsub/manage-subscriptions/#subscription-limits)
var total_cost: int;
## The maximum total cost that you're allowed to incur for all subscriptions that you create.
var max_total_cost: int;
## An object that contains the cursor used to get the next page of subscriptions. The object is empty if there are no more pages to get. The number of subscriptions returned per page is undertermined.
var pagination: GetEventSubSubscriptionsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetEventSubSubscriptionsResponse:
	var result = TwitchGetEventSubSubscriptionsResponse.new();
	result.data = d["data"];
	result.total = d["total"];
	result.total_cost = d["total_cost"];
	result.max_total_cost = d["max_total_cost"];

	result.pagination = GetEventSubSubscriptionsResponsePagination.from_json(d["pagination"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	d["total"] = total;
	d["total_cost"] = total_cost;
	d["max_total_cost"] = max_total_cost;

	d["pagination"] = pagination.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that contains the cursor used to get the next page of subscriptions. The object is empty if there are no more pages to get. The number of subscriptions returned per page is undertermined.
class GetEventSubSubscriptionsResponsePagination extends RefCounted:
	## The cursor value that you set the _after_ query parameter to.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetEventSubSubscriptionsResponsePagination:
		var result = GetEventSubSubscriptionsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

