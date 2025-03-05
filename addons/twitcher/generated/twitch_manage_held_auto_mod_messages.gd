@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchManageHeldAutoModMessages
	


## 
## #/components/schemas/ManageHeldAutoModMessagesBody
class Body extends TwitchData:

	## The moderator who is approving or denying the held message. This ID must match the user ID in the access token.
	var user_id: String:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	## The ID of the message to allow or deny.
	var msg_id: String:
		set(val): 
			msg_id = val
			track_data(&"msg_id", val)
	
	## The action to take for the message. Possible values are:  
	##   
	## * ALLOW
	## * DENY
	var action: String:
		set(val): 
			action = val
			track_data(&"action", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_user_id: String, _msg_id: String, _action: String) -> Body:
		var body: Body = Body.new()
		body.user_id = _user_id
		body.msg_id = _msg_id
		body.action = _action
		return body
	
	
	static func from_json(d: Dictionary) -> Body:
		var result: Body = Body.new()
		if d.get("user_id", null) != null:
			result.user_id = d["user_id"]
		if d.get("msg_id", null) != null:
			result.msg_id = d["msg_id"]
		if d.get("action", null) != null:
			result.action = d["action"]
		return result
	