extends RefCounted

## Defines the message that the EventSub WebSocket server sends your client to indicate that the WebSocket connection is healthy.
## See: https://dev.twitch.tv/docs/eventsub/websocket-reference/#keepalive-message
class_name TwitchKeepaliveMessage

var metadata: TwitchEventsub.Metadata;
## Is always empty
var payload: Dictionary = {};

func _init(d: Dictionary) -> void:
	metadata = TwitchEventsub.Metadata.new(d.get("metadata", {}));
	payload = d["payload"];
