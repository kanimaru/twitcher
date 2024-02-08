extends RefCounted

## Handles the evensub part of twitch. Returns the event data when receives it.
class_name TwitchEventsub;

signal event(type: String, data: Dictionary);
signal events_revoked(type: String, status: String);
signal session_id_received(id: String);
signal connected();

var client : WebsocketClient = WebsocketClient.new();
var swap_over_client : WebsocketClient = WebsocketClient.new();
var api: TwitchRestAPI;
var session_id: String;
var keepalive_timeout: int;
var eventsub_messages: Dictionary = {};
var last_keepalive: int;
var is_conntected: bool;

func _init(twitch_api: TwitchRestAPI) -> void:
	api = twitch_api;
	client.message_received.connect(_data_received);
	client.connection_state_changed.connect(_on_connection_state_changed)
	subscribe_all();

func _on_connection_state_changed(state : WebSocketPeer.State):
	if state == WebSocketPeer.State.STATE_OPEN:
		is_conntected = true;
		connected.emit();
	else:
		is_conntected = false;

func wait_for_connection():
	if not is_conntected: await connected;

func connect_to_eventsub(url: String) -> void:
	client.connect_to(url);

func subscribe_all():
	if session_id == "": await session_id_received;
	var subscriptions: Dictionary = TwitchSetting.subscriptions;
	for subscription: TwitchSubscriptions.Subscription in subscriptions:
		var condition: Dictionary = subscriptions[subscription];
		_subscribe_event(subscription.value, subscription.version, condition, session_id);

## Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
## which API versions are available and which conditions are required.
func _subscribe_event(event_name : String, version : String, conditions : Dictionary, session_id: String):
	var data : Dictionary = {}
	data["type"] = event_name
	data["version"] = version
	data["condition"] = conditions
	data["transport"] = {
		"method":"websocket",
		"session_id": session_id
	}

	var response = await api.create_eventsub_subscription(data);

	if not str(response.response_code).begins_with("2"):
		print("REST: Subscription failed for event '%s'. Error %s: %s" % [event_name, response.response_code, response.response_data.get_string_from_utf8()])
		return
	elif (response.response_data.is_empty()):
		return
	print("REST: Now listening to '%s' events." % event_name)

func _data_received(data : PackedByteArray) -> void:
	var message_str : String = data.get_string_from_utf8();
	var message_json : Dictionary = JSON.parse_string(message_str);
	var id = message_json["metadata"]["message_id"];
	var timestamp_str = message_json["metadata"]["message_timestamp"];
	var timestamp = Time.get_unix_time_from_datetime_string(timestamp_str);

	if(_message_got_processed(id) || _message_is_to_old(timestamp)):
		return;

	eventsub_messages[id] = timestamp;
	var payload : Dictionary = message_json["payload"];
	last_keepalive = Time.get_ticks_msec()

	match message_json["metadata"]["message_type"]:
		"session_welcome":
			session_id = payload["session"]["id"]
			keepalive_timeout = payload["session"]["keepalive_timeout_seconds"]
			session_id_received.emit(session_id)
		"session_keepalive":
			if (payload.has("session")):
				keepalive_timeout = payload["session"]["keepalive_timeout_seconds"]
		"session_reconnect":
			print("[TwitchEventsub]: Session reconnect")
			var reconnect_url = payload["session"]["reconnect_url"]
			swap_over_client.message_received.connect(_data_received);
			swap_over_client.connect_to(reconnect_url);
			await session_id_received;
			client.close(1000, "Closed cause of reconnect.");
			client = swap_over_client;
			swap_over_client = WebsocketClient.new();
			print("[TwitchEventsub]: Session reconnected on ", reconnect_url);
		"revocation":
			events_revoked.emit(payload["subscription"]["type"], payload["subscription"]["status"])
		"notification":
			var event_data : Dictionary = payload["event"]
			event.emit(payload["subscription"]["type"], event_data)

func _message_got_processed(message_id: String) -> bool:
	return eventsub_messages.has(message_id);

func _message_is_to_old(timestamp: int) -> bool:
	return timestamp < Time.get_unix_time_from_system() - TwitchSetting.ignore_message_eventsub_in_seconds;
