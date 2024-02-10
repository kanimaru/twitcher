@tool
extends RefCounted

class_name TwitchGetModeratedChannelsResponse

## The list of channels that the user has moderator privileges in.
var data: Array;
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through.
var pagination: GetModeratedChannelsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetModeratedChannelsResponse:
	var result = TwitchGetModeratedChannelsResponse.new();

	for value in d["data"]:
		result.data.append(value);
{elif property.is_typed_array}
	for value in d["data"]:
		result.data.append(.from_json(value));
{elif property.is_sub_class}
	result.data = Array.from_json(d["data"]);
{else}
	result.data = d["data"];


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	d["pagination"] = pagination.to_dict();
{else}
	d["pagination"] = pagination;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through.
class GetModeratedChannelsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s after query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetModeratedChannelsResponsePagination:
		var result = GetModeratedChannelsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

