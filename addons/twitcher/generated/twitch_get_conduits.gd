@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetConduits
	


## 
## #/components/schemas/GetConduitsResponse
class Response extends TwitchData:

	## List of information about the client’s conduits.
	var data: Array[ResponseData]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[ResponseData]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(ResponseData.from_json(value))
		return result
	


## List of information about the client’s conduits.
## #/components/schemas/GetConduitsResponse/Data
class ResponseData extends TwitchData:

	## Conduit ID.
	var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## Number of shards associated with this conduit.
	var shard_count: int:
		set(val): 
			shard_count = val
			track_data(&"shard_count", val)
	
	
	
	## Constructor with all required fields.
	static func create(_id: String, _shard_count: int) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.id = _id
		response_data.shard_count = _shard_count
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("id", null) != null:
			result.id = d["id"]
		if d.get("shard_count", null) != null:
			result.shard_count = d["shard_count"]
		return result
	