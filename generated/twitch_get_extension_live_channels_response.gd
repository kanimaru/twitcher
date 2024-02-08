@tool
extends RefCounted

class_name TwitchGetExtensionLiveChannelsResponse

## The list of broadcasters that are streaming live and that have installed or activated the extension.
var data: Array[TwitchExtensionLiveChannel];
## This field contains the cursor used to page through the results. The field is empty if there are no more pages left to page through. Note that this field is a string compared to other endpoints that use a **Pagination** object. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: String;

static func from_json(d: Dictionary) -> TwitchGetExtensionLiveChannelsResponse:
	var result = TwitchGetExtensionLiveChannelsResponse.new();
	result.data = d["data"];
	result.pagination = d["pagination"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	d["pagination"] = pagination;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

