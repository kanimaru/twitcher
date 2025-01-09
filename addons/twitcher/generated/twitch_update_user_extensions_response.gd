@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateUserExtensionsResponse

## The extensions that the broadcaster updated.
var data: Data:
	set(val):
		data = val
		if data != null:
			changed_data["data"] = data.to_dict()

var changed_data: Dictionary = {}

static func from_json(d: Dictionary) -> TwitchUpdateUserExtensionsResponse:
	var result = TwitchUpdateUserExtensionsResponse.new()
	if d.has("data") && d["data"] != null:
		result.data = Data.from_json(d["data"])
	return result

func to_dict() -> Dictionary:
	return changed_data

func to_json() -> String:
	return JSON.stringify(to_dict())

## The extensions that the broadcaster updated.
class Data extends RefCounted:
	## A dictionary that contains the data for a panel extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the panel’s data for each key.
	var panel: Dictionary:
		set(val):
			panel = val
			changed_data["panel"] = panel
	## A dictionary that contains the data for a video-overlay extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the overlay’s data for each key.
	var overlay: Dictionary:
		set(val):
			overlay = val
			changed_data["overlay"] = overlay
	## A dictionary that contains the data for a video-component extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the component’s data for each key.
	var component: Dictionary:
		set(val):
			component = val
			changed_data["component"] = component

	var changed_data: Dictionary = {}

	static func from_json(d: Dictionary) -> Data:
		var result = Data.new()
		if d.has("panel") && d["panel"] != null:
			result.panel = d["panel"]
		if d.has("overlay") && d["overlay"] != null:
			result.overlay = d["overlay"]
		if d.has("component") && d["component"] != null:
			result.component = d["component"]
		return result

	func to_dict() -> Dictionary:
		return changed_data

	func to_json() -> String:
		return JSON.stringify(to_dict())

