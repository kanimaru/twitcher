@tool
extends RefCounted

class_name TwitchUpdateChatSettingsBody

## A Boolean value that determines whether chat messages must contain only emotes.      Set to **true** if only emotes are allowed; otherwise, **false**. The default is **false**.
var emote_mode: bool;
## A Boolean value that determines whether the broadcaster restricts the chat room to followers only.      Set to **true** if the broadcaster restricts the chat room to followers only; otherwise, **false**. The default is **true**.      To specify how long users must follow the broadcaster before being able to participate in the chat room, see the `follower_mode_duration` field.
var follower_mode: bool;
## The length of time, in minutes, that users must follow the broadcaster before being able to participate in the chat room. Set only if `follower_mode` is **true**. Possible values are: 0 (no restriction) through 129600 (3 months). The default is 0.
var follower_mode_duration: int;
## A Boolean value that determines whether the broadcaster adds a short delay before chat messages appear in the chat room. This gives chat moderators and bots a chance to remove them before viewers can see the message.      Set to **true** if the broadcaster applies a delay; otherwise, **false**. The default is **false**.      To specify the length of the delay, see the `non_moderator_chat_delay_duration` field.
var non_moderator_chat_delay: bool;
## The amount of time, in seconds, that messages are delayed before appearing in chat. Set only if `non_moderator_chat_delay` is **true**. Possible values are:      * 2 — 2 second delay (recommended) * 4 — 4 second delay * 6 — 6 second delay
var non_moderator_chat_delay_duration: int;
## A Boolean value that determines whether the broadcaster limits how often users in the chat room are allowed to send messages. Set to **true** if the broadcaster applies a wait period between messages; otherwise, **false**. The default is **false**.      To specify the delay, see the `slow_mode_wait_time` field.
var slow_mode: bool;
## The amount of time, in seconds, that users must wait between sending messages. Set only if `slow_mode` is **true**.      Possible values are: 3 (3 second delay) through 120 (2 minute delay). The default is 30 seconds.
var slow_mode_wait_time: int;
## A Boolean value that determines whether only users that subscribe to the broadcaster’s channel may talk in the chat room.      Set to **true** if the broadcaster restricts the chat room to subscribers only; otherwise, **false**. The default is **false**.
var subscriber_mode: bool;
## A Boolean value that determines whether the broadcaster requires users to post only unique messages in the chat room.      Set to **true** if the broadcaster allows only unique messages; otherwise, **false**. The default is **false**.
var unique_chat_mode: bool;

static func from_json(d: Dictionary) -> TwitchUpdateChatSettingsBody:
	var result = TwitchUpdateChatSettingsBody.new();









	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};









	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

