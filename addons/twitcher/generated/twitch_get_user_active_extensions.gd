@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetUserActiveExtensions
	


## 
## #/components/schemas/GetUserActiveExtensionsResponse
class Response extends TwitchData:

	## The active extensions that the broadcaster has installed.
	@export var data: ResponseData:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create() -> Response:
		var response: Response = Response.new()
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			result.data = ResponseData.from_json(d["data"])
		return result
	


## The active extensions that the broadcaster has installed.
## #/components/schemas/GetUserActiveExtensionsResponse/Data
class ResponseData extends TwitchData:

	## A dictionary that contains the data for a panel extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the panel’s data for each key.
	@export var panel: Dictionary:
		set(val): 
			panel = val
			track_data(&"panel", val)
	
	## A dictionary that contains the data for a video-overlay extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the overlay’s data for each key.
	@export var overlay: Dictionary:
		set(val): 
			overlay = val
			track_data(&"overlay", val)
	
	## A dictionary that contains the data for a video-component extension. The dictionary’s key is a sequential number beginning with 1\. The following fields contain the component’s data for each key.
	@export var component: Dictionary:
		set(val): 
			component = val
			track_data(&"component", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("panel", null) != null:
			result.panel = d["panel"]
		if d.get("overlay", null) != null:
			result.overlay = d["overlay"]
		if d.get("component", null) != null:
			result.component = d["component"]
		return result
	


## All optional parameters for TwitchAPI.get_user_active_extensions
## #/components/schemas/GetUserActiveExtensionsOpt
class Opt extends TwitchData:

	## The ID of the broadcaster whose active extensions you want to get.  
	##   
	## This parameter is required if you specify an app access token and is optional if you specify a user access token. If you specify a user access token and don’t specify this parameter, the API uses the user ID from the access token.
	@export var user_id: String:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("user_id", null) != null:
			result.user_id = d["user_id"]
		return result
	