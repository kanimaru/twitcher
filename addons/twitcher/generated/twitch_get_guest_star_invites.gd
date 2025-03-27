@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetGuestStarInvites
	


## 
## #/components/schemas/GetGuestStarInvitesResponse
class Response extends TwitchData:

	## A list of invite objects describing the invited user as well as their ready status.
	@export var data: Array[TwitchGuestStarInvite]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchGuestStarInvite]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchGuestStarInvite.from_json(value))
		return result
	