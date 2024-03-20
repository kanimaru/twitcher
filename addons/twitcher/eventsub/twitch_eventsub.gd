extends RefCounted

## Handles the evensub part of twitch. Returns the event data when receives it.
class_name TwitchEventsub;

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_EVENT_SUB)

## An object that identifies the message.
class Metadata extends RefCounted:
	## An ID that uniquely identifies the message. Twitch sends messages at least once, but if Twitch is unsure of whether you received a notification, it’ll resend the message. This means you may receive a notification twice. If Twitch resends the message, the message ID is the same.
	var message_id: String
	## The type of message, which is set to session_keepalive.
	var message_type: String
	## The UTC date and time that the message was sent.
	var message_timestamp: String

	func _init(d: Dictionary):
		message_id = d['message_id'];
		message_type = d['message_type'];
		message_timestamp = d['message_timestamp'];

## An object that contains information about the connection.
class Session extends RefCounted:
	## An ID that uniquely identifies this WebSocket connection. Use this ID to set the session_id field in all subscription requests.
	var id: String;
	## The connection’s status, which is set to connected.
	var status: String;
	## The maximum number of seconds that you should expect silence before receiving a keepalive message. For a welcome message, this is the number of seconds that you have to subscribe to an event after receiving the welcome message. If you don’t subscribe to an event within this window, the socket is disconnected.
	var keepalive_timeout_seconds: int;
	## The URL to reconnect to if you get a Reconnect message. Is set to null.
	var reconnect_url: String;
	## The UTC date and time that the connection was created.
	var connected_at: String;

	func _init(d: Dictionary):
		id = d["id"];
		status = d["status"];
		var timeout = d["keepalive_timeout_seconds"];
		keepalive_timeout_seconds = timeout if timeout != null else 30;
		if d["reconnect_url"] != null:
			reconnect_url = d["reconnect_url"];
		connected_at = d["connected_at"];

## Called as soon the websocket got a connections
signal connected();

## Will be send as soon as the websocket connection is up and running you can use it to subscribe to events
signal session_id_received(id: String);

## Will be called when an event is sent from Twitch.
signal event(type: String, data: Dictionary);

## Will be called when an event got revoked from your subscription by Twitch.
signal events_revoked(type: String, status: String);

## Called when any eventsub message is received for low level access
signal message_received(message: Variant);

## Main eventsub client to receive messages from.
var client : WebsocketClient = WebsocketClient.new();
## Swap over client in case Twitch sends us the message for a new server.
## See: https://dev.twitch.tv/docs/eventsub/handling-websocket-events/#reconnect-message
var swap_over_client : WebsocketClient;
var api: TwitchRestAPI;

var session: Session;
## All the subscriptions that should be subscribed or resubscribed in case of reconnection.
## Notice: Wanted to do a Dict<EventName, Request> but you can subscribe to multiple event names from different streams..
var subscriptions: Array = [];
## Holds the messages that was processed already.
## Key: MessageID ; Value: Timestamp
var eventsub_messages: Dictionary = {};
var last_keepalive: int;
var is_conntected: bool;

func _init(twitch_api: TwitchRestAPI, autoconnect: bool = true) -> void:
	api = twitch_api;
	client.message_received.connect(_data_received);
	client.connection_state_changed.connect(_on_connection_state_changed)
	if autoconnect:
		_create_subscriptions_from_config();

## Connects to this url starts the whole eventsub connection.
func connect_to_eventsub(url: String) -> void:
	client.connect_to(url);

func _on_connection_state_changed(state : WebSocketPeer.State):
	if state == WebSocketPeer.State.STATE_OPEN:
		is_conntected = true;
		connected.emit();
		_subscribe_all();
	else:
		is_conntected = false;

## Awaits until the websocket is connected and the session id was received
## at this point we can subscribe to events.
func wait_for_connection() -> void:
	if not is_conntected: await connected;
	if session == null: await session_id_received;

func _subscribe_all() -> void:
	await wait_for_connection()
	for subscription in subscriptions:
		subscribe(subscription);

func _create_subscriptions_from_config() -> void:
	if session == null: await session_id_received;
	var subscriptions: Dictionary = TwitchSetting.subscriptions;
	for subscription: TwitchSubscriptions.Subscription in subscriptions:
		var condition: Dictionary = subscriptions[subscription];
		create_subscription(subscription.value, subscription.version, condition);

func create_subscription(event_name : String, version : String, conditions : Dictionary) -> void:
	var data : TwitchCreateEventSubSubscriptionBody = TwitchCreateEventSubSubscriptionBody.new();
	var transport : TwitchCreateEventSubSubscriptionBody.Transport = TwitchCreateEventSubSubscriptionBody.Transport.new();
	data.type = event_name;
	data.version = version;
	data.condition = conditions;
	data.transport = transport;
	transport.method = "websocket";
	transport.session_id = session.id;
	subscriptions.append(data);

## Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
## which API versions are available and which conditions are required.
func subscribe(data: TwitchCreateEventSubSubscriptionBody):
	var response = await api.create_eventsub_subscription(data);

	if not str(response.response_code).begins_with("2"):
		log.e("Subscription failed for event '%s'. Error %s: %s" % [data.type, response.response_code, response.response_data.get_string_from_utf8()])
		return
	elif (response.response_data.is_empty()):
		return
	log.i("Now listening to '%s' events." % data.type)

func _data_received(data : PackedByteArray) -> void:
	var message_str : String = data.get_string_from_utf8();
	var message_json : Dictionary = JSON.parse_string(message_str);
	if not message_json.has("metadata"):
		log.e("Twitch send something undocumented: %s" % message_str);
		return;
	var metadata : Metadata = Metadata.new(message_json["metadata"]);
	var id = metadata.message_id;
	var timestamp_str = metadata.message_timestamp;
	var timestamp = Time.get_unix_time_from_datetime_string(timestamp_str);

	if(_message_got_processed(id) || _message_is_to_old(timestamp)):
		return;

	eventsub_messages[id] = timestamp;
	last_keepalive = Time.get_ticks_msec();

	match metadata.message_type:
		"session_welcome":
			var welcome_message = TwitchWelcomeMessage.new(message_json);
			session = welcome_message.payload.session;
			session_id_received.emit(session.id);
			message_received.emit(welcome_message);
		"session_keepalive":
			# Notification from server that the connection is still alive
			var keep_alive_message = TwitchKeepaliveMessage.new(message_json);
			message_received.emit(keep_alive_message);
			pass;
		"session_reconnect":
			var reconnect_message = TwitchReconnectMessage.new(message_json);
			message_received.emit(reconnect_message);
			_handle_reconnect(reconnect_message);
		"revocation":
			var revocation_message = TwitchRevocationMessage.new(message_json);
			message_received.emit(revocation_message);
			events_revoked.emit(revocation_message.payload.subscription.type,
				revocation_message.payload.subscription.status);
		"notification":
			var notification_message = TwitchNotificationMessage.new(message_json);
			message_received.emit(notification_message);
			event.emit(notification_message.payload.subscription.type,
				notification_message.payload.event);
	_cleanup();

func _handle_reconnect(reconnect_message: TwitchReconnectMessage):
	log.i("Session is forced to reconnect");
	var reconnect_url = reconnect_message.payload.session.reconnect_url;
	swap_over_client = WebsocketClient.new();
	swap_over_client.message_received.connect(_data_received);
	swap_over_client.connect_to(reconnect_url);
	await session_id_received;
	client.close(1000, "Closed cause of reconnect.");
	client = swap_over_client;
	swap_over_client = null;
	log.i("Session reconnected on %s" % reconnect_url);

## Cleanup old messages that won't be processed anymore cause of time to prevent a
## memory problem on long runinng applications.
func _cleanup() -> void:
	for message_id in eventsub_messages.keys():
		var timestamp = eventsub_messages[message_id];
		if _message_is_to_old(timestamp):
			eventsub_messages.erase(message_id);

func _message_got_processed(message_id: String) -> bool:
	return eventsub_messages.has(message_id);

func _message_is_to_old(timestamp: int) -> bool:
	return timestamp < Time.get_unix_time_from_system() - TwitchSetting.ignore_message_eventsub_in_seconds;
