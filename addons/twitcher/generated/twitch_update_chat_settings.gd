@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateChatSettings
	


## 
## #/components/schemas/UpdateChatSettingsBody
class Body extends TwitchData:

	## A Boolean value that determines whether chat messages must contain only emotes.  
	##   
	## Set to **true** if only emotes are allowed; otherwise, **false**. The default is **false**.
	@export var emote_mode: bool:
		set(val): 
			emote_mode = val
			track_data(&"emote_mode", val)
	
	## A Boolean value that determines whether the broadcaster restricts the chat room to followers only.  
	##   
	## Set to **true** if the broadcaster restricts the chat room to followers only; otherwise, **false**. The default is **true**.  
	##   
	## To specify how long users must follow the broadcaster before being able to participate in the chat room, see the `follower_mode_duration` field.
	@export var follower_mode: bool:
		set(val): 
			follower_mode = val
			track_data(&"follower_mode", val)
	
	## The length of time, in minutes, that users must follow the broadcaster before being able to participate in the chat room. Set only if `follower_mode` is **true**. Possible values are: 0 (no restriction) through 129600 (3 months). The default is 0.
	@export var follower_mode_duration: int:
		set(val): 
			follower_mode_duration = val
			track_data(&"follower_mode_duration", val)
	
	## A Boolean value that determines whether the broadcaster adds a short delay before chat messages appear in the chat room. This gives chat moderators and bots a chance to remove them before viewers can see the message.  
	##   
	## Set to **true** if the broadcaster applies a delay; otherwise, **false**. The default is **false**.  
	##   
	## To specify the length of the delay, see the `non_moderator_chat_delay_duration` field.
	@export var non_moderator_chat_delay: bool:
		set(val): 
			non_moderator_chat_delay = val
			track_data(&"non_moderator_chat_delay", val)
	
	## The amount of time, in seconds, that messages are delayed before appearing in chat. Set only if `non_moderator_chat_delay` is **true**. Possible values are:  
	##   
	## * 2 — 2 second delay (recommended)
	## * 4 — 4 second delay
	## * 6 — 6 second delay
	@export var non_moderator_chat_delay_duration: int:
		set(val): 
			non_moderator_chat_delay_duration = val
			track_data(&"non_moderator_chat_delay_duration", val)
	
	## A Boolean value that determines whether the broadcaster limits how often users in the chat room are allowed to send messages. Set to **true** if the broadcaster applies a wait period between messages; otherwise, **false**. The default is **false**.  
	##   
	## To specify the delay, see the `slow_mode_wait_time` field.
	@export var slow_mode: bool:
		set(val): 
			slow_mode = val
			track_data(&"slow_mode", val)
	
	## The amount of time, in seconds, that users must wait between sending messages. Set only if `slow_mode` is **true**.  
	##   
	## Possible values are: 3 (3 second delay) through 120 (2 minute delay). The default is 30 seconds.
	@export var slow_mode_wait_time: int:
		set(val): 
			slow_mode_wait_time = val
			track_data(&"slow_mode_wait_time", val)
	
	## A Boolean value that determines whether only users that subscribe to the broadcaster’s channel may talk in the chat room.  
	##   
	## Set to **true** if the broadcaster restricts the chat room to subscribers only; otherwise, **false**. The default is **false**.
	@export var subscriber_mode: bool:
		set(val): 
			subscriber_mode = val
			track_data(&"subscriber_mode", val)
	
	## A Boolean value that determines whether the broadcaster requires users to post only unique messages in the chat room.  
	##   
	## Set to **true** if the broadcaster allows only unique messages; otherwise, **false**. The default is **false**.
	@export var unique_chat_mode: bool:
		set(val): 
			unique_chat_mode = val
			track_data(&"unique_chat_mode", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create() -> Body:
		var body: Body = Body.new()
		return body
	
	
	static func from_json(d: Dictionary) -> Body:
		var result: Body = Body.new()
		if d.get("emote_mode", null) != null:
			result.emote_mode = d["emote_mode"]
		if d.get("follower_mode", null) != null:
			result.follower_mode = d["follower_mode"]
		if d.get("follower_mode_duration", null) != null:
			result.follower_mode_duration = d["follower_mode_duration"]
		if d.get("non_moderator_chat_delay", null) != null:
			result.non_moderator_chat_delay = d["non_moderator_chat_delay"]
		if d.get("non_moderator_chat_delay_duration", null) != null:
			result.non_moderator_chat_delay_duration = d["non_moderator_chat_delay_duration"]
		if d.get("slow_mode", null) != null:
			result.slow_mode = d["slow_mode"]
		if d.get("slow_mode_wait_time", null) != null:
			result.slow_mode_wait_time = d["slow_mode_wait_time"]
		if d.get("subscriber_mode", null) != null:
			result.subscriber_mode = d["subscriber_mode"]
		if d.get("unique_chat_mode", null) != null:
			result.unique_chat_mode = d["unique_chat_mode"]
		return result
	


## 
## #/components/schemas/UpdateChatSettingsResponse
class Response extends TwitchData:

	## The list of chat settings. The list contains a single object with all the settings.
	@export var data: Array[TwitchChatSettingsUpdated]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchChatSettingsUpdated]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchChatSettingsUpdated.from_json(value))
		return result
	