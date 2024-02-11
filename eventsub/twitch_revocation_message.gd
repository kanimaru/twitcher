extends RefCounted

class_name TwitchRevocationMessage

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

	func _init(d: Dictionary) -> void:
		subscription = Subscription.new(d.get("subscription", {}))

## An object that contains information about your subscription.
class Subscription extends RefCounted:
	## An ID that uniquely identifies this subscription.
	var id: String;
	## he subscription's status. The following are the possible values:[br]
	## authorization_revoked — The user in the condition object revoked the authorization that let you get events on their behalf.[br]
	## user_removed — The user in the condition object is no longer a Twitch user.[br]
	## version_removed — The subscribed to subscription type and version is no longer supported.
	var status: String;
	## The type of event sent in the message.
	var type: String;
	## The version number of the subscription type's definition.
	var version: String;
	## The event's cost. See Subscription limits (https://dev.twitch.tv/docs/eventsub/manage-subscriptions/#subscription-limits)
	var cost: String;
	## The conditions under which the event fires. For example, if you requested notifications when a broadcaster gets a new follower, this object contains the broadcaster’s ID. For information about the condition's data, see the subscription type's description in Subscription Types. (https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types)
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
	metadata = Metadata.new(d.get("metadata", {}))
	payload = Payload.new(d.get("payload", {}))
