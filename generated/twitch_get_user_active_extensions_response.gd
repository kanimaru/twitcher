@tool
extends RefCounted

class_name TwitchGetUserActiveExtensionsResponse

## The active extensions that the broadcaster has installed.
var data: GetUserActiveExtensionsResponseData;

static func from_json(d: Dictionary) -> TwitchGetUserActiveExtensionsResponse:
	var result = TwitchGetUserActiveExtensionsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	d["data"] = data.to_dict();
{else}
	d["data"] = data;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The active extensions that the broadcaster has installed.
class GetUserActiveExtensionsResponseData extends RefCounted:
	## A dictionary that contains the data for a panel extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the panel’s data for each key.
	var panel: Dictionary;
	## A dictionary that contains the data for a video-overlay extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the overlay’s data for each key.
	var overlay: Dictionary;
	## A dictionary that contains the data for a video-component extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the component’s data for each key.
	var component: Dictionary;

	static func from_json(d: Dictionary) -> GetUserActiveExtensionsResponseData:
		var result = GetUserActiveExtensionsResponseData.new();
		result.panel = d["panel"];
		result.overlay = d["overlay"];
		result.component = d["component"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["panel"] = panel;
		d["overlay"] = overlay;
		d["component"] = component;
		return d;

