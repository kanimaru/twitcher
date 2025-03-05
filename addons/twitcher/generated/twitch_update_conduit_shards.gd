@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateConduitShards
	


## 
## #/components/schemas/UpdateConduitShardsBody
class Body extends TwitchData:

	## Conduit ID.
	var conduit_id: String:
		set(val): 
			conduit_id = val
			track_data(&"conduit_id", val)
	
	## List of shards to update.
	var shards: Array[BodyShards]:
		set(val): 
			shards = val
			track_data(&"shards", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_conduit_id: String, _shards: Array[BodyShards]) -> Body:
		var body: Body = Body.new()
		body.conduit_id = _conduit_id
		body.shards = _shards
		return body
	
	
	static func from_json(d: Dictionary) -> Body:
		var result: Body = Body.new()
		if d.get("conduit_id", null) != null:
			result.conduit_id = d["conduit_id"]
		if d.get("shards", null) != null:
			for value in d["shards"]:
				result.shards.append(BodyShards.from_json(value))
		return result
	


## List of shards to update.
## #/components/schemas/UpdateConduitShardsBody/Shards
class BodyShards extends TwitchData:

	## Shard ID.
	var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The transport details that you want Twitch to use when sending you notifications.
	var transport: BodyTransport:
		set(val): 
			transport = val
			track_data(&"transport", val)
	
	
	
	## Constructor with all required fields.
	static func create(_id: String, _transport: BodyTransport) -> BodyShards:
		var body_shards: BodyShards = BodyShards.new()
		body_shards.id = _id
		body_shards.transport = _transport
		return body_shards
	
	
	static func from_json(d: Dictionary) -> BodyShards:
		var result: BodyShards = BodyShards.new()
		if d.get("id", null) != null:
			result.id = d["id"]
		if d.get("transport", null) != null:
			result.transport = BodyTransport.from_json(d["transport"])
		return result
	


## The transport details that you want Twitch to use when sending you notifications.
## #/components/schemas/UpdateConduitShardsBody/Shards/Transport
class BodyTransport extends TwitchData:

	## The transport method. Possible values are:  
	##   
	## * webhook
	## * websocket
	var method: String:
		set(val): 
			method = val
			track_data(&"method", val)
	
	## The callback URL where the notifications are sent. The URL must use the HTTPS protocol and port 443\. See Processing an event.Specify this field only if method is set to webhook.NOTE: Redirects are not followed.
	var callback: String:
		set(val): 
			callback = val
			track_data(&"callback", val)
	
	## The secret used to verify the signature. The secret must be an ASCII string that’s a minimum of 10 characters long and a maximum of 100 characters long. For information about how the secret is used, see Verifying the event message.Specify this field only if method is set to webhook.
	var secret: String:
		set(val): 
			secret = val
			track_data(&"secret", val)
	
	## An ID that identifies the WebSocket to send notifications to. When you connect to EventSub using WebSockets, the server returns the ID in the Welcome message.Specify this field only if method is set to websocket.
	var session_id: String:
		set(val): 
			session_id = val
			track_data(&"session_id", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> BodyTransport:
		var body_transport: BodyTransport = BodyTransport.new()
		return body_transport
	
	
	static func from_json(d: Dictionary) -> BodyTransport:
		var result: BodyTransport = BodyTransport.new()
		if d.get("method", null) != null:
			result.method = d["method"]
		if d.get("callback", null) != null:
			result.callback = d["callback"]
		if d.get("secret", null) != null:
			result.secret = d["secret"]
		if d.get("session_id", null) != null:
			result.session_id = d["session_id"]
		return result
	


## 
## #/components/schemas/UpdateConduitShardsResponse
class Response extends TwitchData:

	## List of successful shard updates.
	var data: Array[ResponseData]:
		set(val): 
			data = val
			track_data(&"data", val)
	
	## List of unsuccessful updates.
	var errors: Array[ResponseErrors]:
		set(val): 
			errors = val
			track_data(&"errors", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[ResponseData], _errors: Array[ResponseErrors]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		response.errors = _errors
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(ResponseData.from_json(value))
		if d.get("errors", null) != null:
			for value in d["errors"]:
				result.errors.append(ResponseErrors.from_json(value))
		return result
	


## List of successful shard updates.
## #/components/schemas/UpdateConduitShardsResponse/Data
class ResponseData extends TwitchData:

	## Shard ID.
	var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The shard status. The subscriber receives events only for enabled shards. Possible values are:  
	##   
	## * enabled — The shard is enabled.
	## * webhook\_callback\_verification\_pending — The shard is pending verification of the specified callback URL.
	## * webhook\_callback\_verification\_failed — The specified callback URL failed verification.
	## * notification\_failures\_exceeded — The notification delivery failure rate was too high.
	## * websocket\_disconnected — The client closed the connection.
	## * websocket\_failed\_ping\_pong — The client failed to respond to a ping message.
	## * websocket\_received\_inbound\_traffic — The client sent a non-pong message. Clients may only send pong messages (and only in response to a ping message).
	## * websocket\_internal\_error — The Twitch WebSocket server experienced an unexpected error.
	## * websocket\_network\_timeout — The Twitch WebSocket server timed out writing the message to the client.
	## * websocket\_network\_error — The Twitch WebSocket server experienced a network error writing the message to the client.
	## * websocket\_failed\_to\_reconnect - The client failed to reconnect to the Twitch WebSocket server within the required time after a Reconnect Message.
	var status: String:
		set(val): 
			status = val
			track_data(&"status", val)
	
	## The transport details used to send the notifications.
	var transport: ResponseTransport:
		set(val): 
			transport = val
			track_data(&"transport", val)
	
	
	
	## Constructor with all required fields.
	static func create(_id: String, _status: String, _transport: ResponseTransport) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.id = _id
		response_data.status = _status
		response_data.transport = _transport
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("id", null) != null:
			result.id = d["id"]
		if d.get("status", null) != null:
			result.status = d["status"]
		if d.get("transport", null) != null:
			result.transport = ResponseTransport.from_json(d["transport"])
		return result
	


## The transport details used to send the notifications.
## #/components/schemas/UpdateConduitShardsResponse/Data/Transport
class ResponseTransport extends TwitchData:

	## The transport method. Possible values are:  
	##   
	## * webhook
	## * websocket
	var method: String:
		set(val): 
			method = val
			track_data(&"method", val)
	
	## The callback URL where the notifications are sent. Included only if method is set to webhook.
	var callback: String:
		set(val): 
			callback = val
			track_data(&"callback", val)
	
	## An ID that identifies the WebSocket that notifications are sent to. Included only if method is set to websocket.
	var session_id: String:
		set(val): 
			session_id = val
			track_data(&"session_id", val)
	
	## The UTC date and time that the WebSocket connection was established. Included only if method is set to websocket.
	var connected_at: Variant:
		set(val): 
			connected_at = val
			track_data(&"connected_at", val)
	
	## The UTC date and time that the WebSocket connection was lost. Included only if method is set to websocket.
	var disconnected_at: Variant:
		set(val): 
			disconnected_at = val
			track_data(&"disconnected_at", val)
	
	
	
	## Constructor with all required fields.
	static func create(_method: String) -> ResponseTransport:
		var response_transport: ResponseTransport = ResponseTransport.new()
		response_transport.method = _method
		return response_transport
	
	
	static func from_json(d: Dictionary) -> ResponseTransport:
		var result: ResponseTransport = ResponseTransport.new()
		if d.get("method", null) != null:
			result.method = d["method"]
		if d.get("callback", null) != null:
			result.callback = d["callback"]
		if d.get("session_id", null) != null:
			result.session_id = d["session_id"]
		if d.get("connected_at", null) != null:
			result.connected_at = d["connected_at"]
		if d.get("disconnected_at", null) != null:
			result.disconnected_at = d["disconnected_at"]
		return result
	


## List of unsuccessful updates.
## #/components/schemas/UpdateConduitShardsResponse/Errors
class ResponseErrors extends TwitchData:

	## Shard ID.
	var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The error that occurred while updating the shard. Possible errors:  
	##   
	## * The length of the string in the secret field is not valid.
	## * The URL in the transport's callback field is not valid. The URL must use the HTTPS protocol and the 443 port number.
	## * The value specified in the method field is not valid.
	## * The callback field is required if you specify the webhook transport method.
	## * The session\_id field is required if you specify the WebSocket transport method.
	## * The websocket session is not connected.
	## * The shard id is outside of the conduit’s range.
	var message: String:
		set(val): 
			message = val
			track_data(&"message", val)
	
	## Error codes used to represent a specific error condition while attempting to update shards.
	var code: String:
		set(val): 
			code = val
			track_data(&"code", val)
	
	
	
	## Constructor with all required fields.
	static func create(_id: String, _message: String, _code: String) -> ResponseErrors:
		var response_errors: ResponseErrors = ResponseErrors.new()
		response_errors.id = _id
		response_errors.message = _message
		response_errors.code = _code
		return response_errors
	
	
	static func from_json(d: Dictionary) -> ResponseErrors:
		var result: ResponseErrors = ResponseErrors.new()
		if d.get("id", null) != null:
			result.id = d["id"]
		if d.get("message", null) != null:
			result.message = d["message"]
		if d.get("code", null) != null:
			result.code = d["code"]
		return result
	