@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchEventSubSubscription

## An ID that identifies the subscription.
var id: String;
## The subscription's status. The subscriber receives events only for **enabled** subscriptions. Possible values are:      * enabled — The subscription is enabled. * webhook\_callback\_verification\_pending — The subscription is pending verification of the specified callback URL. * webhook\_callback\_verification\_failed — The specified callback URL failed verification. * notification\_failures\_exceeded — The notification delivery failure rate was too high. * authorization\_revoked — The authorization was revoked for one or more users specified in the **Condition** object. * moderator\_removed — The moderator that authorized the subscription is no longer one of the broadcaster's moderators. * user\_removed — One of the users specified in the **Condition** object was removed. * version\_removed — The subscription to subscription type and version is no longer supported. * beta\_maintenance — The subscription to the beta subscription type was removed due to maintenance. * websocket\_disconnected — The client closed the connection. * websocket\_failed\_ping\_pong — The client failed to respond to a ping message. * websocket\_received\_inbound\_traffic — The client sent a non-pong message. Clients may only send pong messages (and only in response to a ping message). * websocket\_connection\_unused — The client failed to subscribe to events within the required time. * websocket\_internal\_error — The Twitch WebSocket server experienced an unexpected error. * websocket\_network\_timeout — The Twitch WebSocket server timed out writing the message to the client. * websocket\_network\_error — The Twitch WebSocket server experienced a network error writing the message to the client.
var status: String;
## The subscription's type. See [Subscription Types](https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#subscription-types).
var type: String;
## The version number that identifies this definition of the subscription's data.
var version: String;
## The subscription's parameter values. This is a string-encoded JSON object whose contents are determined by the subscription type.
var condition: Dictionary;
## The date and time (in RFC3339 format) of when the subscription was created.
var created_at: Variant;
## The transport details used to send the notifications.
var transport: Transport;
## The amount that the subscription counts against your limit. [Learn More](https://dev.twitch.tv/docs/eventsub/manage-subscriptions/#subscription-limits)
var cost: int;

static func from_json(d: Dictionary) -> TwitchEventSubSubscription:
	var result = TwitchEventSubSubscription.new();
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("status") && d["status"] != null:
		result.status = d["status"];
	if d.has("type") && d["type"] != null:
		result.type = d["type"];
	if d.has("version") && d["version"] != null:
		result.version = d["version"];
	if d.has("condition") && d["condition"] != null:
		result.condition = d["condition"];
	if d.has("created_at") && d["created_at"] != null:
		result.created_at = d["created_at"];
	if d.has("transport") && d["transport"] != null:
		result.transport = Transport.from_json(d["transport"]);
	if d.has("cost") && d["cost"] != null:
		result.cost = d["cost"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["status"] = status;
	d["type"] = type;
	d["version"] = version;
	d["condition"] = condition;
	d["created_at"] = created_at;
	if transport != null:
		d["transport"] = transport.to_dict();
	d["cost"] = cost;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The transport details used to send the notifications.
class Transport extends RefCounted:
{for properties as property}
	## {property.description}
	var {property.field_name}: {property.type};
{/for}


	static func from_json(d: Dictionary) -> Transport:
		var result = Transport.new();
{for properties as property}
{if property.is_property_array}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			for value in d["{property.property_name}"]:
				result.{property.field_name}.append(value);
{/if}
{if property.is_property_typed_array}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			for value in d["{property.property_name}"]:
				result.{property.field_name}.append({property.array_type}.from_json(value));
{/if}
{if property.is_property_sub_class}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			result.{property.field_name} = {property.type}.from_json(d["{property.property_name}"]);
{/if}
{if property.is_property_basic}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			result.{property.field_name} = d["{property.property_name}"];
{/if}
{/for}
		return result;

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
{for properties as property}
{if property.is_property_array}
		d["{property.property_name}"] = [];
		if {property.field_name} != null:
			for value in {property.field_name}:
				d["{property.property_name}"].append(value);
{/if}
{if property.is_property_typed_array}
		d["{property.property_name}"] = [];
		if {property.field_name} != null:
			for value in {property.field_name}:
				d["{property.property_name}"].append(value.to_dict());
{/if}
{if property.is_property_sub_class}
		if {property.field_name} != null:
			d["{property.property_name}"] = {property.field_name}.to_dict();
{/if}
{if property.is_property_basic}
		d["{property.property_name}"] = {property.field_name};
{/if}
{/for}
		return d;


	func to_json() -> String:
		return JSON.stringify(to_dict());

