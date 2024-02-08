@tool
extends RefCounted

class_name TwitchGetCharityCampaignDonationsResponse

## A list that contains the donations that users have made to the broadcaster’s charity campaign. The list is empty if the broadcaster is not currently running a charity campaign; the donation information is not available after the campaign ends.
var data: Array[TwitchCharityCampaignDonation];
## An object that contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetCharityCampaignDonationsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetCharityCampaignDonationsResponse:
	var result = TwitchGetCharityCampaignDonationsResponse.new();
	result.data = d["data"];

	result.pagination = GetCharityCampaignDonationsResponsePagination.from_json(d["pagination"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;

	d["pagination"] = pagination.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetCharityCampaignDonationsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetCharityCampaignDonationsResponsePagination:
		var result = GetCharityCampaignDonationsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

