@icon("../assets/chat-icon.svg")
@tool
extends Node

## Grants access to read and write to a chat
class_name TwitchChat

@export var twitch_service: TwitchService:
	set(val):
		twitch_service = val
		update_configuration_warnings()

@export var target_user_channel: String = "":
	set = _update_target_user_channel

@onready var twitch_event_listener: TwitchEventListener = %TwitchEventListener


static var _log: TwitchLogger = TwitchLogger.new("TwitchChat")

var broadcaster_user: TwitchUser:
	set = _update_broadcaster_user

var sender_user: TwitchUser
var _sender_user_loading: bool
signal _sender_user_loaded

## Triggered when a chat message got received
signal message_received(message: TwitchChatMessage)
## Rest API got changed
signal rest_updated(rest: TwitchAPI)


func _ready() -> void:
	_log.d("is ready")
	twitch_event_listener.eventsub = twitch_service.eventsub
	twitch_event_listener.received.connect(_on_event_received)
	_update_target_user_channel(target_user_channel)


func _update_target_user_channel(val: String) -> void:
	target_user_channel = val
	if not is_inside_tree(): return
	if val != null && val != "":
		_log.d("change channel to %s" % val)
		broadcaster_user = await twitch_service.get_user(val)
		
		
func _update_broadcaster_user(val: TwitchUser) -> void:
		broadcaster_user = val
		update_configuration_warnings()
		notify_property_list_changed()
		twitch_service.media_loader.preload_badges(broadcaster_user.id)
		twitch_service.media_loader.preload_emotes(broadcaster_user.id)
		_subscribe_to_channel()
		
		
func _subscribe_to_channel() -> void:
	var subscriptions = twitch_service.eventsub.get_subscriptions()
	for subscription: TwitchEventsubConfig in subscriptions:
		if subscription.type == TwitchEventsubDefinition.Type.CHANNEL_CHAT_MESSAGE and \
			subscription.condition.broadcaster_user_id == broadcaster_user.id:
				# it is already subscribed
				return
		
	var config = TwitchEventsubConfig.new()
	config.type = TwitchEventsubDefinition.Type.CHANNEL_CHAT_MESSAGE
	config.condition = {
		"broadcaster_user_id": broadcaster_user.id,
		"user_id": broadcaster_user.id
	}
	twitch_service.eventsub.subscribe(config)


func _on_event_received(data: Dictionary) -> void:
	var message = TwitchChatMessage.from_json(data, twitch_service)
	if message.broadcaster_user_id == broadcaster_user.id:
		message_received.emit(message)


func send_message(message: String, reply_parent_message_id: String = "") -> Array[TwitchSendChatMessageResponse.Data]:
	if not _sender_user_loading && sender_user == null:
		_sender_user_loading = true
		await _load_sender_user()
	await _wait_for_sender_user()

	var message_body = TwitchSendChatMessageBody.new()
	message_body.broadcaster_id = broadcaster_user.id
	message_body.sender_id = sender_user.id
	message_body.message = message
	if reply_parent_message_id:
		message_body.reply_parent_message_id = reply_parent_message_id

	var response = await twitch_service.api.send_chat_message(message_body)
	if _log.enabled:
		for message_data: TwitchSendChatMessageResponse.Data in response.data:
			if not message_data.is_sent:
				_log.w(message_data.drop_reason)

	return response.data


func _wait_for_sender_user() -> void:
	if sender_user == null: await _sender_user_loaded


func _load_sender_user() -> void:
	if sender_user != null:
		_sender_user_loaded.emit()
		return
	sender_user = await twitch_service.get_current_user()
	if sender_user == null:
		push_error("Current Twitch User can't be loaded. (Can't send chat messages)")
		return
	_sender_user_loaded.emit()


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if twitch_service == null:
		result.append("TwitchService not assgined")
	if broadcaster_user == null:
		result.append("Target broadcaster not specified")
	return result
