@tool
extends Node

## Handles the evensub part of twitch. Returns the event data when receives it.
class_name TwitchEventsub
static var _log: TwitchLogger = TwitchLogger.new("TwitchEventsub")

## An object that identifies the message.
class Metadata extends RefCounted:
	## An ID that uniquely identifies the message. Twitch sends messages at least once, but if Twitch is unsure of whether you received a notification, it’ll resend the message. This means you may receive a notification twice. If Twitch resends the message, the message ID is the same.
	var message_id: String
	## The type of message, which is set to session_keepalive.
	var message_type: String
	## The UTC date and time that the message was sent.
	var message_timestamp: String

	func _init(d: Dictionary):
		message_id = d['message_id']
		message_type = d['message_type']
		message_timestamp = d['message_timestamp']

## An object that contains information about the connection.
class Session extends RefCounted:
	## An ID that uniquely identifies this WebSocket connection. Use this ID to set the session_id field in all subscription requests.
	var id: String
	## The connection’s status, which is set to connected.
	var status: String
	## The maximum number of seconds that you should expect silence before receiving a keepalive message. For a welcome message, this is the number of seconds that you have to subscribe to an event after receiving the welcome message. If you don’t subscribe to an event within this window, the socket is disconnected.
	var keepalive_timeout_seconds: int
	## The URL to reconnect to if you get a Reconnect message. Is set to null.
	var reconnect_url: String
	## The UTC date and time that the connection was created.
	var connected_at: String

	func _init(d: Dictionary):
		id = d["id"]
		status = d["status"]
		var timeout = d["keepalive_timeout_seconds"]
		keepalive_timeout_seconds = timeout if timeout != null else 30
		if d["reconnect_url"] != null:
			reconnect_url = d["reconnect_url"]
		connected_at = d["connected_at"]

## Will be send as soon as the websocket connection is up and running you can use it to subscribe to events
signal session_id_received(id: String)

## Will be called when an event is sent from Twitch.
signal event(type: String, data: Dictionary)

## Will be called when an event got revoked from your subscription by Twitch.
signal events_revoked(type: String, status: String)

## Called when any eventsub message is received for low level access
signal message_received(message: Variant)

@export var api: TwitchAPI
@export var _subscriptions: Array[TwitchEventsubConfig] = []
@export var scopes: OAuthScopes
@export var eventsub_live_server_url: String = "wss://eventsub.wss.twitch.tv/ws"
@export var eventsub_test_server_url: String = "ws://127.0.0.1:8080/ws"
@export var use_test_server: bool
@export var ignore_message_eventsub_in_seconds: int = 600

var _client: WebsocketClient = WebsocketClient.new()
var _test_client : WebsocketClient = WebsocketClient.new()
## Swap over client in case Twitch sends us the message for a new server.
## See: https://dev.twitch.tv/docs/eventsub/handling-websocket-events/#reconnect-message
var _swap_over_client : WebsocketClient

var session: Session
## Holds the messages that was processed already.
## Key: MessageID  Value: Timestamp
var eventsub_messages: Dictionary = {}
var last_keepalive: int
var is_open: bool:
	get(): return _client.is_open
var _should_connect: bool

## When the Websocket server is shutting down and the client is doing a
## gracefull handover
var _swap_over_process: bool

## queues the actions that should be executed when the connection is established
var _action_stack: Array[SubscriptionAction]
var _executing_action_stack: bool

## Determines the action that the subscription should do
class SubscriptionAction extends RefCounted:
	var subscribe: bool
	var subscription: TwitchEventsubConfig

	func _to_string() -> String:
		return "%s %s" % [("Subscribe to" if subscribe else "Unsubscribe from"), subscription.definition.get_readable_name()]


func _init() -> void:
	_log.enabled = true
	_log.debug = true
	_client.connection_url = eventsub_live_server_url
	_client.message_received.connect(_data_received)
	_client.connection_established.connect(_on_connection_established)
	_test_client.connection_url = eventsub_test_server_url
	_test_client.message_received.connect(_data_received)


func _ready() -> void:
	_client.name = "Websocket Client"
	add_child(_client)
	if use_test_server:
		_test_client.name = "Websocket Client Test"
		add_child(_test_client)


## Propergated call from twitch service
func do_setup() -> void:
	await open_connection()
	_log.i("Eventsub setup")


func wait_setup() -> void:
	await wait_for_session_established()


## Waits until the eventsub is fully established
func wait_for_session_established() -> void:
	if session == null: await session_id_received


func _on_connection_established() -> void:
	if not _swap_over_process:
		_action_stack.clear()
		# Resubscribe
		_log.i("Connection established -> resubscribe to: [%s]" % [_subscriptions])
		for sub in _subscriptions: _add_action(sub, true)
	_execute_action_stack()


func open_connection() -> void:
	if _client.is_closed:
		_client.open_connection()
	if _test_client.is_closed && use_test_server:
		_test_client.open_connection()


## Add a new subscription
func subscribe(eventsub_config: TwitchEventsubConfig) -> void:
	_log.i("Subscribe to %s" % eventsub_config.definition.get_readable_name())
	_subscriptions.append(eventsub_config)
	_add_action(eventsub_config, true)


## Remove a subscription
func unsubscribe(eventsub_config: TwitchEventsubConfig) -> void:
	_subscriptions.erase(eventsub_config)
	_add_action(eventsub_config, false)


## Process the queue of actions until its empty
func _execute_action_stack() -> void:
	if _executing_action_stack: return
	await wait_for_session_established()
	_log.d("Execute actions [%s]" % [_action_stack])
	_executing_action_stack = true
	while not _action_stack.is_empty():
		var action = _action_stack.pop_back()
		var sub: TwitchEventsubConfig = action.subscription
		if action.subscribe:
			_subscribe(sub)
		else:
			_unsubscribe(sub)
	_executing_action_stack = false


## Adds a subscribe or unsubscribe action to the queue
func _add_action(sub: TwitchEventsubConfig, subscribe: bool) -> void:
	var sub_action = SubscriptionAction.new()
	sub_action.subscription = sub
	sub_action.subscribe = subscribe
	_action_stack.append(sub_action)
	_log.d("Add subscribe action: %s" % sub.definition.get_readable_name())
	_execute_action_stack()


## Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/
## for details on which API versions are available and which conditions are required.
func _subscribe(subscription: TwitchEventsubConfig) -> String:
	var event_name = subscription.definition.value
	var version = subscription.definition.version
	var conditions = subscription.condition

	var data : TwitchCreateEventSubSubscriptionBody = TwitchCreateEventSubSubscriptionBody.new()
	var transport : TwitchCreateEventSubSubscriptionBody.Transport = TwitchCreateEventSubSubscriptionBody.Transport.new()
	data.type = event_name
	data.version = version
	data.condition = conditions
	data.transport = transport
	transport.method = "websocket"
	transport.session_id = session.id

	_log.d("Do subscribe: %s" % event_name)

	var response = await api.create_eventsub_subscription(data)

	if response.response_code == 401:
		_log.e("Subscription failed for '%s': Missing authentication for eventsub. The token got not authenticated yet. Please login!" % data.type)
		_client.close(3000, "Missing Authentication")
		return ""
	elif response.response_code == 403:
		_log.e("Subscription failed for '%s': The token is missing proper scopes. [url='%s']Please check documentation[/url]!" % [data.type, subscription.definition.documentation_link])
		_client.close(3003, "Missing Authorization")
		return ""
	if response.response_code < 200 || response.response_code >= 300:
		_log.e("Subscription failed for '%s'. Unknown error %s: %s" % [data.type, response.response_code, response.response_data.get_string_from_utf8()])
		return ""
	elif (response.response_data.is_empty()):
		return ""
	_log.i("Now listening to '%s' events." % data.type)

	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result.data[0].id


## Unsubscribes from an eventsub in case of an error returns false
func _unsubscribe(subscription: TwitchEventsubConfig) -> bool:
	var response = await api.delete_eventsub_subscription(subscription.id)
	return response.error || response.response_code != 200


func _data_received(data : PackedByteArray) -> void:
	var message_str : String = data.get_string_from_utf8()
	var message_json : Dictionary = JSON.parse_string(message_str)
	if not message_json.has("metadata"):
		_log.e("Twitch send something undocumented: %s" % message_str)
		return
	var metadata : Metadata = Metadata.new(message_json["metadata"])
	var id = metadata.message_id
	var timestamp_str = metadata.message_timestamp
	var timestamp = Time.get_unix_time_from_datetime_string(timestamp_str)

	if(_message_got_processed(id) || _message_is_to_old(timestamp)):
		return

	eventsub_messages[id] = timestamp
	last_keepalive = Time.get_ticks_msec()

	match metadata.message_type:
		"session_welcome":
			var welcome_message = TwitchWelcomeMessage.new(message_json)
			session = welcome_message.payload.session
			session_id_received.emit(session.id)
			_log.i("Session established %s" % session.id)
			message_received.emit(welcome_message)
		"session_keepalive":
			# Notification from server that the connection is still alive
			var keep_alive_message = TwitchKeepaliveMessage.new(message_json)
			message_received.emit(keep_alive_message)
			pass
		"session_reconnect":
			var reconnect_message = TwitchReconnectMessage.new(message_json)
			message_received.emit(reconnect_message)
			_handle_reconnect(reconnect_message)
		"revocation":
			var revocation_message = TwitchRevocationMessage.new(message_json)
			message_received.emit(revocation_message)
			events_revoked.emit(revocation_message.payload.subscription.type,
				revocation_message.payload.subscription.status)
		"notification":
			var notification_message = TwitchNotificationMessage.new(message_json)
			message_received.emit(notification_message)
			event.emit(notification_message.payload.subscription.type,
				notification_message.payload.event)
	_cleanup()


func _handle_reconnect(reconnect_message: TwitchReconnectMessage):
	_log.i("Session is forced to reconnect")
	_swap_over_process = true
	var reconnect_url = reconnect_message.payload.session.reconnect_url
	_swap_over_client = WebsocketClient.new()
	_swap_over_client.message_received.connect(_data_received)
	_swap_over_client.connection_established.connect(_on_connection_established)
	_swap_over_client.connection_url = reconnect_url
	add_child(_swap_over_client)
	_swap_over_client.open_connection()
	await session_id_received
	_client.close(1000, "Closed cause of reconnect.")
	remove_child(_client)
	_client = _swap_over_client
	_swap_over_client = null
	_swap_over_process = false
	_log.i("Session reconnected on %s" % reconnect_url)


## Cleanup old messages that won't be processed anymore cause of time to prevent a
## memory problem on long runinng applications.
func _cleanup() -> void:
	for message_id in eventsub_messages.keys():
		var timestamp = eventsub_messages[message_id]
		if _message_is_to_old(timestamp):
			eventsub_messages.erase(message_id)


func _message_got_processed(message_id: String) -> bool:
	return eventsub_messages.has(message_id)


func _message_is_to_old(timestamp: int) -> bool:
	return timestamp < Time.get_unix_time_from_system() - ignore_message_eventsub_in_seconds


func get_client() -> WebsocketClient:
	return _client


func get_test_client() -> WebsocketClient:
	return _test_client

## Returns a copy of the current subscribed events. Don't modify the result they won't get applied anyway.
func get_subscriptions() -> Array[TwitchEventsubConfig]:
	return _subscriptions.duplicate()
