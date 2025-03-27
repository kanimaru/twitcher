@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetSharedChatSession
	


## 
## #/components/schemas/GetSharedChatSessionResponse
class Response extends TwitchData:

	## 
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
	


## 
## #/components/schemas/GetSharedChatSessionResponse/Data
class ResponseData extends TwitchData:

	## The unique identifier for the shared chat session.
	@export var session_id: String:
		set(val): 
			session_id = val
			track_data(&"session_id", val)
	
	## The User ID of the host channel.
	@export var host_broadcaster_id: String:
		set(val): 
			host_broadcaster_id = val
			track_data(&"host_broadcaster_id", val)
	
	## The list of participants in the session.
	@export var participants: Array[ResponseParticipants]:
		set(val): 
			participants = val
			track_data(&"participants", val)
	
	## The UTC date and time (in RFC3339 format) for when the session was created.
	@export var created_at: String:
		set(val): 
			created_at = val
			track_data(&"created_at", val)
	
	## The UTC date and time (in RFC3339 format) for when the session was last updated.
	@export var updated_at: String:
		set(val): 
			updated_at = val
			track_data(&"updated_at", val)
	
	
	
	## Constructor with all required fields.
	static func create(_session_id: String, _host_broadcaster_id: String, _participants: Array[ResponseParticipants], _created_at: String, _updated_at: String) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.session_id = _session_id
		response_data.host_broadcaster_id = _host_broadcaster_id
		response_data.participants = _participants
		response_data.created_at = _created_at
		response_data.updated_at = _updated_at
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("session_id", null) != null:
			result.session_id = d["session_id"]
		if d.get("host_broadcaster_id", null) != null:
			result.host_broadcaster_id = d["host_broadcaster_id"]
		if d.get("participants", null) != null:
			for value in d["participants"]:
				result.participants.append(ResponseParticipants.from_json(value))
		if d.get("created_at", null) != null:
			result.created_at = d["created_at"]
		if d.get("updated_at", null) != null:
			result.updated_at = d["updated_at"]
		return result
	


## The list of participants in the session.
## #/components/schemas/GetSharedChatSessionResponse/Data/Participants
class ResponseParticipants extends TwitchData:

	## The User ID of the participant channel.
	@export var broadcaster_id: String:
		set(val): 
			broadcaster_id = val
			track_data(&"broadcaster_id", val)
	
	
	
	## Constructor with all required fields.
	static func create(_broadcaster_id: String) -> ResponseParticipants:
		var response_participants: ResponseParticipants = ResponseParticipants.new()
		response_participants.broadcaster_id = _broadcaster_id
		return response_participants
	
	
	static func from_json(d: Dictionary) -> ResponseParticipants:
		var result: ResponseParticipants = ResponseParticipants.new()
		if d.get("broadcaster_id", null) != null:
			result.broadcaster_id = d["broadcaster_id"]
		return result
	