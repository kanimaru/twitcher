@tool
extends RefCounted

class_name TwitchChatSettingsUpdated

## The ID of the broadcaster specified in the request.
var broadcaster_id: String;
## A Boolean value that determines whether chat messages must contain only emotes. Is **true** if chat messages may contain only emotes; otherwise, **false**.
var emote_mode: bool;
## A Boolean value that determines whether the broadcaster restricts the chat room to followers only.      Is **true** if the broadcaster restricts the chat room to followers only; otherwise, **false**.      See the `follower_mode_duration` field for how long users must follow the broadcaster before being able to participate in the chat room.
var follower_mode: bool;
## The length of time, in minutes, that users must follow the broadcaster before being able to participate in the chat room. Is **null** if `follower_mode` is **false**.
var follower_mode_duration: int;
## The moderator’s ID. The response includes this field only if the request specifies a user access token that includes the **moderator:read:chat\_settings** scope.
var moderator_id: String;
## A Boolean value that determines whether the broadcaster adds a short delay before chat messages appear in the chat room. This gives chat moderators and bots a chance to remove them before viewers can see the message. See the `non_moderator_chat_delay_duration` field for the length of the delay. Is **true** if the broadcaster applies a delay; otherwise, **false**.
var non_moderator_chat_delay: bool;
## The amount of time, in seconds, that messages are delayed before appearing in chat. Is **null** if `non_moderator_chat_delay` is **false**.
var non_moderator_chat_delay_duration: int;
## A Boolean value that determines whether the broadcaster limits how often users in the chat room are allowed to send messages.      Is **true** if the broadcaster applies a delay; otherwise, **false**.      See the `slow_mode_wait_time` field for the delay.
var slow_mode: bool;
## The amount of time, in seconds, that users must wait between sending messages.      Is **null** if slow\_mode is **false**.
var slow_mode_wait_time: int;
## A Boolean value that determines whether only users that subscribe to the broadcaster’s channel may talk in the chat room.      Is **true** if the broadcaster restricts the chat room to subscribers only; otherwise, **false**.
var subscriber_mode: bool;
## A Boolean value that determines whether the broadcaster requires users to post only unique messages in the chat room.      Is **true** if the broadcaster requires unique messages only; otherwise, **false**.
var unique_chat_mode: bool;

static func from_json(d: Dictionary) -> TwitchChatSettingsUpdated:
	var result = TwitchChatSettingsUpdated.new();











	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};











	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

