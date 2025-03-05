@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetChatSettings
	


## 
## #/components/schemas/GetChatSettingsResponse
class Response extends TwitchData:

	## The list of chat settings. The list contains a single object with all the settings.
	var data: Array[TwitchChatSettings]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchChatSettings]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchChatSettings.from_json(value))
		return result
	


## All optional parameters for TwitchAPI.get_chat_settings
## #/components/schemas/GetChatSettingsOpt
class Opt extends TwitchData:

	## The ID of the broadcaster or one of the broadcaster’s moderators.  
	##   
	## This field is required only if you want to include the `non_moderator_chat_delay` and `non_moderator_chat_delay_duration` settings in the response.  
	##   
	## If you specify this field, this ID must match the user ID in the user access token.
	var moderator_id: String:
		set(val): 
			moderator_id = val
			track_data(&"moderator_id", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("moderator_id", null) != null:
			result.moderator_id = d["moderator_id"]
		return result
	