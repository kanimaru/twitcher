@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetUsers
	


## 
## #/components/schemas/GetUsersResponse
class Response extends TwitchData:

	## The list of users.
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
	


## All optional parameters for TwitchAPI.get_users
## #/components/schemas/GetUsersOpt
class Opt extends TwitchData:

	## The ID of the user to get. To specify more than one user, include the _id_ parameter for each user to get. For example, `id=1234&id=5678`. The maximum number of IDs you may specify is 100.
	@export var id: Array[String]:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The login name of the user to get. To specify more than one user, include the _login_ parameter for each user to get. For example, `login=foo&login=bar`. The maximum number of login names you may specify is 100.
	@export var login: Array[String]:
		set(val): 
			login = val
			track_data(&"login", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("id", null) != null:
			for value in d["id"]:
				result.id.append(value)
		if d.get("login", null) != null:
			for value in d["login"]:
				result.login.append(value)
		return result
	
