## Builds EventSub WebSocket frames the way Twitch sends them, for tests that
## feed a [TwitchEventsub] through a [WebsocketTestServer].
##
## Every frame gets a fresh message id and the current time as timestamp, so the
## duplicate and age checks of the eventsub let it through. Pass an id to build a
## duplicate on purpose.
##
## See https://dev.twitch.tv/docs/eventsub/handling-websocket-events/
class_name EventsubMessages
extends RefCounted


static func welcome(session_id: String, keepalive_timeout_seconds: int = 10) -> String:
	return _frame("session_welcome", {
		"session": _session(session_id, "connected", keepalive_timeout_seconds, null),
	})


static func keepalive(message_id: String = "") -> String:
	return _frame("session_keepalive", {}, message_id)


static func reconnect(session_id: String, reconnect_url: String) -> String:
	return _frame("session_reconnect", {
		"session": _session(session_id, "reconnecting", null, reconnect_url),
	})


static func _session(
		session_id: String, status: String, keepalive_timeout: Variant,
		reconnect_url: Variant) -> Dictionary:
	return {
		"id": session_id,
		"status": status,
		"keepalive_timeout_seconds": keepalive_timeout,
		"reconnect_url": reconnect_url,
		"connected_at": _now(),
	}


static func _frame(message_type: String, payload: Dictionary, message_id: String = "") -> String:
	if message_id == "":
		message_id = "test-%d-%d" % [Time.get_ticks_usec(), randi()]
	return JSON.stringify({
		"metadata": {
			"message_id": message_id,
			"message_type": message_type,
			"message_timestamp": _now(),
		},
		"payload": payload,
	})


static func _now() -> String:
	return Time.get_datetime_string_from_system(true) + "Z"
