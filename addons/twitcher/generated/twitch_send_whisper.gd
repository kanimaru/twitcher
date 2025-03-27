@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchSendWhisper
	


## 
## #/components/schemas/SendWhisperBody
class Body extends TwitchData:

	## The whisper message to send. The message must not be empty.  
	##   
	## The maximum message lengths are:  
	##   
	## * 500 characters if the user you're sending the message to hasn't whispered you before.
	## * 10,000 characters if the user you're sending the message to has whispered you before.
	##   
	## Messages that exceed the maximum length are truncated.
	@export var message: String:
		set(val): 
			message = val
			track_data(&"message", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_message: String) -> Body:
		var body: Body = Body.new()
		body.message = _message
		return body
	
	
	static func from_json(d: Dictionary) -> Body:
		var result: Body = Body.new()
		if d.get("message", null) != null:
			result.message = d["message"]
		return result
	