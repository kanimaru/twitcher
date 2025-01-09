@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetCustomRewardResponse

## A list of custom rewards. The list is in ascending order by `id`. If the broadcaster hasn’t created custom rewards, the list is empty.
var data: Array[TwitchCustomReward]:
	set(val):
		data = val
		changed_data["data"] = []
		if data != null:
			for value in data:
				changed_data["data"].append(value.to_dict())

var changed_data: Dictionary = {}

static func from_json(d: Dictionary) -> TwitchGetCustomRewardResponse:
	var result = TwitchGetCustomRewardResponse.new()
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchCustomReward.from_json(value))
	return result

func to_dict() -> Dictionary:
	return changed_data

func to_json() -> String:
	return JSON.stringify(to_dict())

