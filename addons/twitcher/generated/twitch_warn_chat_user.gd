@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchWarnChatUser
	


## 
## #/components/schemas/WarnChatUserBody
class Body extends TwitchData:

	## A list that contains information about the warning.
	@export var data: BodyData:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: BodyData) -> Body:
		var body: Body = Body.new()
		body.data = _data
		return body
	
	
	static func from_json(d: Dictionary) -> Body:
		var result: Body = Body.new()
		if d.get("data", null) != null:
			result.data = BodyData.from_json(d["data"])
		return result
	


## A list that contains information about the warning.
## #/components/schemas/WarnChatUserBody/Data
class BodyData extends TwitchData:

	## The ID of the twitch user to be warned.
	@export var user_id: String:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	## A custom reason for the warning. **Max 500 chars.**
	@export var reason: String:
		set(val): 
			reason = val
			track_data(&"reason", val)
	
	
	
	## Constructor with all required fields.
	static func create(_user_id: String, _reason: String) -> BodyData:
		var body_data: BodyData = BodyData.new()
		body_data.user_id = _user_id
		body_data.reason = _reason
		return body_data
	
	
	static func from_json(d: Dictionary) -> BodyData:
		var result: BodyData = BodyData.new()
		if d.get("user_id", null) != null:
			result.user_id = d["user_id"]
		if d.get("reason", null) != null:
			result.reason = d["reason"]
		return result
	


## 
## #/components/schemas/WarnChatUserResponse
class Response extends TwitchData:

	## A list that contains information about the warning.
	@export var data: Array[ResponseData]:
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
	


## A list that contains information about the warning.
## #/components/schemas/WarnChatUserResponse/Data
class ResponseData extends TwitchData:

	## The ID of the channel in which the warning will take effect.
	@export var broadcaster_id: String:
		set(val): 
			broadcaster_id = val
			track_data(&"broadcaster_id", val)
	
	## The ID of the warned user.
	@export var user_id: String:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	## The ID of the user who applied the warning.
	@export var moderator_id: String:
		set(val): 
			moderator_id = val
			track_data(&"moderator_id", val)
	
	## The reason provided for warning.
	@export var reason: String:
		set(val): 
			reason = val
			track_data(&"reason", val)
	
	
	
	## Constructor with all required fields.
	static func create(_broadcaster_id: String, _user_id: String, _moderator_id: String, _reason: String) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.broadcaster_id = _broadcaster_id
		response_data.user_id = _user_id
		response_data.moderator_id = _moderator_id
		response_data.reason = _reason
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("broadcaster_id", null) != null:
			result.broadcaster_id = d["broadcaster_id"]
		if d.get("user_id", null) != null:
			result.user_id = d["user_id"]
		if d.get("moderator_id", null) != null:
			result.moderator_id = d["moderator_id"]
		if d.get("reason", null) != null:
			result.reason = d["reason"]
		return result
	