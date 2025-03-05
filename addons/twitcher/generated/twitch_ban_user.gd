@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchBanUser
	


## 
## #/components/schemas/BanUserBody
class Body extends TwitchData:

	## Identifies the user and type of ban.
	var data: BodyData:
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
	


## Identifies the user and type of ban.
## #/components/schemas/BanUserBody/Data
class BodyData extends TwitchData:

	## The ID of the user to ban or put in a timeout.
	var user_id: String:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	## To ban a user indefinitely, don’t include this field.  
	##   
	## To put a user in a timeout, include this field and specify the timeout period, in seconds. The minimum timeout is 1 second and the maximum is 1,209,600 seconds (2 weeks).  
	##   
	## To end a user’s timeout early, set this field to 1, or use the [Unban user](https://dev.twitch.tv/docs/api/reference#unban-user) endpoint.
	var duration: int:
		set(val): 
			duration = val
			track_data(&"duration", val)
	
	## The reason the you’re banning the user or putting them in a timeout. The text is user defined and is limited to a maximum of 500 characters.
	var reason: String:
		set(val): 
			reason = val
			track_data(&"reason", val)
	
	
	
	## Constructor with all required fields.
	static func create(_user_id: String) -> BodyData:
		var body_data: BodyData = BodyData.new()
		body_data.user_id = _user_id
		return body_data
	
	
	static func from_json(d: Dictionary) -> BodyData:
		var result: BodyData = BodyData.new()
		if d.get("user_id", null) != null:
			result.user_id = d["user_id"]
		if d.get("duration", null) != null:
			result.duration = d["duration"]
		if d.get("reason", null) != null:
			result.reason = d["reason"]
		return result
	


## 
## #/components/schemas/BanUserResponse
class Response extends TwitchData:

	## A list that contains the user you successfully banned or put in a timeout.
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
	


## A list that contains the user you successfully banned or put in a timeout.
## #/components/schemas/BanUserResponse/Data
class ResponseData extends TwitchData:

	## The broadcaster whose chat room the user was banned from chatting in.
	var broadcaster_id: String:
		set(val): 
			broadcaster_id = val
			track_data(&"broadcaster_id", val)
	
	## The moderator that banned or put the user in the timeout.
	var moderator_id: String:
		set(val): 
			moderator_id = val
			track_data(&"moderator_id", val)
	
	## The user that was banned or put in a timeout.
	var user_id: String:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	## The UTC date and time (in RFC3339 format) that the ban or timeout was placed.
	var created_at: Variant:
		set(val): 
			created_at = val
			track_data(&"created_at", val)
	
	## The UTC date and time (in RFC3339 format) that the timeout will end. Is **null** if the user was banned instead of being put in a timeout.
	var end_time: Variant:
		set(val): 
			end_time = val
			track_data(&"end_time", val)
	
	
	
	## Constructor with all required fields.
	static func create(_broadcaster_id: String, _moderator_id: String, _user_id: String, _created_at: Variant, _end_time: Variant) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.broadcaster_id = _broadcaster_id
		response_data.moderator_id = _moderator_id
		response_data.user_id = _user_id
		response_data.created_at = _created_at
		response_data.end_time = _end_time
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("broadcaster_id", null) != null:
			result.broadcaster_id = d["broadcaster_id"]
		if d.get("moderator_id", null) != null:
			result.moderator_id = d["moderator_id"]
		if d.get("user_id", null) != null:
			result.user_id = d["user_id"]
		if d.get("created_at", null) != null:
			result.created_at = d["created_at"]
		if d.get("end_time", null) != null:
			result.end_time = d["end_time"]
		return result
	