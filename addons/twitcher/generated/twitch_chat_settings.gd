@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/ChatSettings
class_name TwitchChatSettings
	
## The ID of the broadcaster specified in the request.
@export var broadcaster_id: String:
	set(val): 
		broadcaster_id = val
		track_data(&"broadcaster_id", val)

## A Boolean value that determines whether chat messages must contain only emotes. Is **true** if chat messages may contain only emotes; otherwise, **false**.
@export var emote_mode: bool:
	set(val): 
		emote_mode = val
		track_data(&"emote_mode", val)

## A Boolean value that determines whether the broadcaster restricts the chat room to followers only.  
##   
## Is **true** if the broadcaster restricts the chat room to followers only; otherwise, **false**.  
##   
## See the `follower_mode_duration` field for how long users must follow the broadcaster before being able to participate in the chat room.
@export var follower_mode: bool:
	set(val): 
		follower_mode = val
		track_data(&"follower_mode", val)

## The length of time, in minutes, that users must follow the broadcaster before being able to participate in the chat room. Is **null** if `follower_mode` is **false**.
@export var follower_mode_duration: int:
	set(val): 
		follower_mode_duration = val
		track_data(&"follower_mode_duration", val)

## The moderator’s ID. The response includes this field only if the request specifies a user access token that includes the **moderator:read:chat\_settings** scope.
@export var moderator_id: String:
	set(val): 
		moderator_id = val
		track_data(&"moderator_id", val)

## A Boolean value that determines whether the broadcaster adds a short delay before chat messages appear in the chat room. This gives chat moderators and bots a chance to remove them before viewers can see the message. See the `non_moderator_chat_delay_duration` field for the length of the delay. Is **true** if the broadcaster applies a delay; otherwise, **false**.  
##   
## The response includes this field only if the request specifies a user access token that includes the **moderator:read:chat\_settings** scope and the user in the _moderator\_id_ query parameter is one of the broadcaster’s moderators.
@export var non_moderator_chat_delay: bool:
	set(val): 
		non_moderator_chat_delay = val
		track_data(&"non_moderator_chat_delay", val)

## The amount of time, in seconds, that messages are delayed before appearing in chat. Is **null** if `non_moderator_chat_delay` is **false**.  
##   
## The response includes this field only if the request specifies a user access token that includes the **moderator:read:chat\_settings** scope and the user in the _moderator\_id_ query parameter is one of the broadcaster’s moderators.
@export var non_moderator_chat_delay_duration: int:
	set(val): 
		non_moderator_chat_delay_duration = val
		track_data(&"non_moderator_chat_delay_duration", val)

## A Boolean value that determines whether the broadcaster limits how often users in the chat room are allowed to send messages.  
##   
## Is **true** if the broadcaster applies a delay; otherwise, **false**.  
##   
## See the `slow_mode_wait_time` field for the delay.
@export var slow_mode: bool:
	set(val): 
		slow_mode = val
		track_data(&"slow_mode", val)

## The amount of time, in seconds, that users must wait between sending messages.  
##   
## Is **null** if slow\_mode is **false**.
@export var slow_mode_wait_time: int:
	set(val): 
		slow_mode_wait_time = val
		track_data(&"slow_mode_wait_time", val)

## A Boolean value that determines whether only users that subscribe to the broadcaster’s channel may talk in the chat room.  
##   
## Is **true** if the broadcaster restricts the chat room to subscribers only; otherwise, **false**.
@export var subscriber_mode: bool:
	set(val): 
		subscriber_mode = val
		track_data(&"subscriber_mode", val)

## A Boolean value that determines whether the broadcaster requires users to post only unique messages in the chat room.  
##   
## Is **true** if the broadcaster requires unique messages only; otherwise, **false**.
@export var unique_chat_mode: bool:
	set(val): 
		unique_chat_mode = val
		track_data(&"unique_chat_mode", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_broadcaster_id: String, _emote_mode: bool, _follower_mode: bool, _follower_mode_duration: int, _slow_mode: bool, _slow_mode_wait_time: int, _subscriber_mode: bool, _unique_chat_mode: bool) -> TwitchChatSettings:
	var twitch_chat_settings: TwitchChatSettings = TwitchChatSettings.new()
	twitch_chat_settings.broadcaster_id = _broadcaster_id
	twitch_chat_settings.emote_mode = _emote_mode
	twitch_chat_settings.follower_mode = _follower_mode
	twitch_chat_settings.follower_mode_duration = _follower_mode_duration
	twitch_chat_settings.slow_mode = _slow_mode
	twitch_chat_settings.slow_mode_wait_time = _slow_mode_wait_time
	twitch_chat_settings.subscriber_mode = _subscriber_mode
	twitch_chat_settings.unique_chat_mode = _unique_chat_mode
	return twitch_chat_settings


static func from_json(d: Dictionary) -> TwitchChatSettings:
	var result: TwitchChatSettings = TwitchChatSettings.new()
	if d.get("broadcaster_id", null) != null:
		result.broadcaster_id = d["broadcaster_id"]
	if d.get("emote_mode", null) != null:
		result.emote_mode = d["emote_mode"]
	if d.get("follower_mode", null) != null:
		result.follower_mode = d["follower_mode"]
	if d.get("follower_mode_duration", null) != null:
		result.follower_mode_duration = d["follower_mode_duration"]
	if d.get("moderator_id", null) != null:
		result.moderator_id = d["moderator_id"]
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
