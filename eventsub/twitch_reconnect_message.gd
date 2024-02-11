extends RefCounted

class_name TwitchReconnectMessage

## An object that contains the message.
class Payload extends RefCounted:
	var session: TwitchEventsub.Session;

	func _init(d: Dictionary) -> void:
		session = TwitchEventsub.Session.new(d["session"]);

## An object that identifies the message.
var metadata: TwitchEventsub.Metadata;

## An object that contains the message.
var payload: Payload;

func _init(d: Dictionary) -> void:
	metadata = TwitchEventsub.Metadata.new(d["metadata"]);
	payload = Payload.new(d["payload"]);
