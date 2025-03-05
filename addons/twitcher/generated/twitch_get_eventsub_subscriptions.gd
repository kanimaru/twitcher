@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetEventsubSubscriptions
	


## All optional parameters for TwitchAPI.get_eventsub_subscriptions
## #/components/schemas/GetEventsubSubscriptionsOpt
class Opt extends TwitchData:

	## Filter subscriptions by its status. Possible values are:  
	##   
	## * enabled — The subscription is enabled.
	## * webhook\_callback\_verification\_pending — The subscription is pending verification of the specified callback URL.
	## * webhook\_callback\_verification\_failed — The specified callback URL failed verification.
	## * notification\_failures\_exceeded — The notification delivery failure rate was too high.
	## * authorization\_revoked — The authorization was revoked for one or more users specified in the **Condition** object.
	## * moderator\_removed — The moderator that authorized the subscription is no longer one of the broadcaster's moderators.
	## * user\_removed — One of the users specified in the **Condition** object was removed.
	## * chat\_user\_banned - The user specified in the **Condition** object was banned from the broadcaster's chat.
	## * version\_removed — The subscription to subscription type and version is no longer supported.
	## * beta\_maintenance — The subscription to the beta subscription type was removed due to maintenance.
	## * websocket\_disconnected — The client closed the connection.
	## * websocket\_failed\_ping\_pong — The client failed to respond to a ping message.
	## * websocket\_received\_inbound\_traffic — The client sent a non-pong message. Clients may only send pong messages (and only in response to a ping message).
	## * websocket\_connection\_unused — The client failed to subscribe to events within the required time.
	## * websocket\_internal\_error — The Twitch WebSocket server experienced an unexpected error.
	## * websocket\_network\_timeout — The Twitch WebSocket server timed out writing the message to the client.
	## * websocket\_network\_error — The Twitch WebSocket server experienced a network error writing the message to the client.
	## * websocket\_failed\_to\_reconnect - The client failed to reconnect to the Twitch WebSocket server within the required time after a Reconnect Message.
	var status: String:
		set(val): 
			status = val
			track_data(&"status", val)
	
	## Filter subscriptions by subscription type. For a list of subscription types, see [Subscription Types](https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#subscription-types).
	var type: String:
		set(val): 
			type = val
			track_data(&"type", val)
	
	## Filter subscriptions by user ID. The response contains subscriptions where this ID matches a user ID that you specified in the **Condition** object when you [created the subscription](https://dev.twitch.tv/docs/api/reference#create-eventsub-subscription).
	var user_id: String:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	## The cursor used to get the next page of results. The `pagination` object in the response contains the cursor's value.
	var after: String:
		set(val): 
			after = val
			track_data(&"after", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("status", null) != null:
			result.status = d["status"]
		if d.get("type", null) != null:
			result.type = d["type"]
		if d.get("user_id", null) != null:
			result.user_id = d["user_id"]
		if d.get("after", null) != null:
			result.after = d["after"]
		return result
	