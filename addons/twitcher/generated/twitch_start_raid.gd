@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchStartRaid
	


## 
## #/components/schemas/StartRaidResponse
class Response extends TwitchData:

	## A list that contains a single object with information about the pending raid.
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
	


## A list that contains a single object with information about the pending raid.
## #/components/schemas/StartRaidResponse/Data
class ResponseData extends TwitchData:

	## The UTC date and time, in RFC3339 format, of when the raid was requested.
	var created_at: Variant:
		set(val): 
			created_at = val
			track_data(&"created_at", val)
	
	## A Boolean value that indicates whether the channel being raided contains mature content.
	var is_mature: bool:
		set(val): 
			is_mature = val
			track_data(&"is_mature", val)
	
	
	
	## Constructor with all required fields.
	static func create(_created_at: Variant, _is_mature: bool) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.created_at = _created_at
		response_data.is_mature = _is_mature
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("created_at", null) != null:
			result.created_at = d["created_at"]
		if d.get("is_mature", null) != null:
			result.is_mature = d["is_mature"]
		return result
	