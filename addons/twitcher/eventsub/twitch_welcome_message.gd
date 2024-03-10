extends RefCounted

## Defines the first message that the EventSub WebSocket server sends after your client connects to the server.
## See: https://dev.twitch.tv/docs/eventsub/websocket-reference/#welcome-message
class_name TwitchWelcomeMessage

class TwitchWelcomeMessagePayload extends RefCounted:
	var session: TwitchEventsub.Session;

	func _init(d: Dictionary) -> void:
		session = TwitchEventsub.Session.new(d.get("session", {}));

var metadata: TwitchEventsub.Metadata;
var payload: TwitchWelcomeMessagePayload;

func _init(d: Dictionary) -> void:
	metadata = TwitchEventsub.Metadata.new(d.get("metadata", {}));
	payload = TwitchWelcomeMessagePayload.new(d.get("payload", {}));
