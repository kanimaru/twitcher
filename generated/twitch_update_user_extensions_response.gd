@tool
extends RefCounted

class_name TwitchUpdateUserExtensionsResponse

## The extensions that the broadcaster updated.
var data: UpdateUserExtensionsResponseData;

static func from_json(d: Dictionary) -> TwitchUpdateUserExtensionsResponse:
	var result = TwitchUpdateUserExtensionsResponse.new();

	result.data = UpdateUserExtensionsResponseData.from_json(d["data"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	d["data"] = data.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The extensions that the broadcaster updated.
class UpdateUserExtensionsResponseData extends RefCounted:
	## A dictionary that contains the data for a panel extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the panel’s data for each key.
	var panel: Dictionary;
	## A dictionary that contains the data for a video-overlay extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the overlay’s data for each key.
	var overlay: Dictionary;
	## A dictionary that contains the data for a video-component extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the component’s data for each key.
	var component: Dictionary;

	static func from_json(d: Dictionary) -> UpdateUserExtensionsResponseData:
		var result = UpdateUserExtensionsResponseData.new();
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

