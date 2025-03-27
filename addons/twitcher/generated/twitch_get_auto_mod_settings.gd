@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetAutoModSettings
	


## 
## #/components/schemas/GetAutoModSettingsResponse
class Response extends TwitchData:

	## The list of AutoMod settings. The list contains a single object that contains all the AutoMod settings.
	@export var data: Array[TwitchAutoModSettings]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchAutoModSettings]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchAutoModSettings.from_json(value))
		return result
	