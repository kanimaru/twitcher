@tool
extends Node

## Grants access to read and write to a chat
class_name TwitchChat

@export var twitch_service: TwitchService:
	set(val):
		twitch_service = val
		update_configuration_warnings()

@export var target_user_channel: String = "":
	set = _update_broadcaster_user

@onready var twitch_event_listener: TwitchEventListener = %TwitchEventListener


var log: TwitchLogger = TwitchLogger.new("TwitchChat")

var broadcaster_user: TwitchUser:
	set(val):
		broadcaster_user = val
		if target_user_channel != val.login:
			target_user_channel = val.login
		update_configuration_warnings()
		notify_property_list_changed()

var sender_user: TwitchUser
var _sender_user_loading: bool
signal _sender_user_loaded

## Triggered when a chat message got received
signal message_received(message: TwitchChatMessage)
## Rest API got changed
signal rest_updated(rest: TwitchRestAPI)



func _exit_tree() -> void:
	twitch_event_listener.received.disconnect(_on_event_received)


func _ready() -> void:
	twitch_event_listener.eventsub = twitch_service.eventsub
	twitch_event_listener.received.connect(_on_event_received)
	_update_broadcaster_user(target_user_channel)


func _update_broadcaster_user(val: String) -> void:
	if twitch_service != null:
		broadcaster_user = await twitch_service.get_user(target_user_channel)
		await twitch_service.icon_loader.preload_badges(broadcaster_user.id)
	target_user_channel = val


func _on_event_received(data: Dictionary) -> void:
	var message = TwitchChatMessage.from_json(data, twitch_service)
	if message.broadcaster_user_id == broadcaster_user.id:
		message_received.emit(message)


func send_message(message: String, reply_parent_message_id: String = "") -> Array[TwitchSendChatMessageResponse.Data]:
	if not _sender_user_loading and sender_user == null:
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
	if log.enabled:
		for message_data: TwitchSendChatMessageResponse.Data in response.data:
			if not message_data.is_sent:
				log.w(message_data.drop_reason)

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
