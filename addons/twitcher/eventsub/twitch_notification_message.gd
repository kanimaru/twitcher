extends RefCounted

class_name TwitchNotificationMessage

## An object that identifies the message.
class Metadata extends TwitchEventsub.Metadata:
	## The type of event sent in the message.
	var subscription_type: String;
	## The version number of the subscription type’s definition. This is the same value specified in the subscription request.
	var subscription_version: String;

	func _init(d: Dictionary) -> void:
		super._init(d);
		subscription_type = d["subscription_type"];
		subscription_version = d["subscription_version"];

## An object that contains the message.
class Payload extends RefCounted:
	## An object that contains information about your subscription.
	var subscription: Subscription;
	## The event’s data. For information about the event’s data, see the subscription type’s description in Subscription Types. https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types
	var event: Dictionary;

	func _init(d: Dictionary) -> void:
		var sub = d.get("subscription");
		if sub != null:
			subscription = Subscription.new(sub)

		event = d["event"]

## An object that contains information about your subscription.
class Subscription extends RefCounted:
	## An ID that uniquely identifies this subscription.
	var id: String;
	## The subscription’s status, which is set to enabled.
	var status: String;
	## The type of event sent in the message. See the event field.
	var type: String;
	## The version number of the subscription type’s definition.
	var version: String;
	## The event’s cost. See Subscription limits. (https://dev.twitch.tv/docs/eventsub/manage-subscriptions#subscription-limits)
	var cost: int;
	## The conditions under which the event fires. For example, if you requested notifications when a broadcaster gets a new follower, this object contains the broadcaster’s ID. For information about the condition’s data, see the subscription type’s description in Subscription types. (https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types)
	var condition: Dictionary;
	## An object that contains information about the transport used for notifications.
	var transport: Transport;
	## The UTC date and time that the subscription was created.
	var created_at: String;

	func _init(d: Dictionary) -> void:
		id = d["id"];
		status = d["status"];
		type = d["type"];
		version = d["version"];
		cost = d["cost"];
		condition = d["condition"];
		transport = Transport.new(d.get("transport", {}));
		created_at = d["created_at"];

## An object that contains information about the transport used for notifications.
class Transport extends RefCounted:
	## The transport method, which is set to websocket.
	var method: String;
	## An ID that uniquely identifies the WebSocket connection.
	var session_id: String;

	func _init(d: Dictionary) -> void:
		method = d["method"];
		session_id = d["session_id"];

## An object that identifies the message.
var metadata: Metadata;

## An object that contains the message.
var payload: Payload;

func _init(d: Dictionary) -> void:
	metadata = Metadata.new(d["metadata"])
	payload = Payload.new(d["payload"])
