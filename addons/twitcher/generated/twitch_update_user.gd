@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateUser
	


## 
## #/components/schemas/UpdateUserResponse
class Response extends TwitchData:

	## A list contains the single user that you updated.
	@export var data: Array[TwitchUser]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchUser]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchUser.from_json(value))
		return result
	


## All optional parameters for TwitchAPI.update_user
## #/components/schemas/UpdateUserOpt
class Opt extends TwitchData:

	## The string to update the channel’s description to. The description is limited to a maximum of 300 characters.  
	##   
	## To remove the description, specify this parameter but don’t set it’s value (for example, `?description=`).
	@export var description: String:
		set(val): 
			description = val
			track_data(&"description", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("description", null) != null:
			result.description = d["description"]
		return result
	