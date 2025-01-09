@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetConduitsResponse

## List of information about the client’s conduits.
var data: Array[Data]:
	set(val):
		data = val
		changed_data["data"] = []
		if data != null:
			for value in data:
				changed_data["data"].append(value.to_dict())

var changed_data: Dictionary = {}

static func from_json(d: Dictionary) -> TwitchGetConduitsResponse:
	var result = TwitchGetConduitsResponse.new()
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(Data.from_json(value))
	return result

func to_dict() -> Dictionary:
	return changed_data

func to_json() -> String:
	return JSON.stringify(to_dict())

## 
class Data extends RefCounted:
	## Conduit ID.
	var id: String:
		set(val):
			id = val
			changed_data["id"] = id
	## Number of shards associated with this conduit.
	var shard_count: int:
		set(val):
			shard_count = val
			changed_data["shard_count"] = shard_count

	var changed_data: Dictionary = {}

	static func from_json(d: Dictionary) -> Data:
		var result = Data.new()
		if d.has("id") && d["id"] != null:
			result.id = d["id"]
		if d.has("shard_count") && d["shard_count"] != null:
			result.shard_count = d["shard_count"]
		return result

	func to_dict() -> Dictionary:
		return changed_data

	func to_json() -> String:
		return JSON.stringify(to_dict())

