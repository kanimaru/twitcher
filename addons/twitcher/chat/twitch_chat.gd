@tool
extends Node

## Grants access to read and write to a chat
class_name TwitchChat

@export var event_sub: TwitchEventsub:
	set(val):
		event_sub = val
		update_configuration_warnings()

@export var rest: TwitchRestAPI:
	set(val):
		rest = val
		rest_updated.emit(val)
		update_configuration_warnings()

@export var target_user_channel: String = ""

@onready var twitch_event_listener: TwitchEventListener = %TwitchEventListener

var log: TwitchLogger = TwitchLogger.new("TwitchChat")

var broadcaster_user: TwitchUser:
	set(val):
		broadcaster_user = val
		update_configuration_warnings()

var sender_user: TwitchUser
var _sender_user_loading: bool
signal _sender_user_loaded

## Triggered when a chat message got received
signal message_received(message: TwitchChatMessage)
## Rest API got changed
signal rest_updated(rest: TwitchRestAPI)


func _enter_tree() -> void:
	%TwitchEventListener.event_sub = event_sub
	%TwitchEventListener.received.connect(_on_event_received)


func _exit_tree() -> void:
	twitch_event_listener.received.disconnect(_on_event_received)


func _on_event_received(data: Dictionary) -> void:
	var message = TwitchChatMessage.from_json(data)
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

	var response = await rest.send_chat_message(message_body)
	if log.enabled:
		for message_data: TwitchSendChatMessageResponse.Data in response.data:
			if not message_data.is_sent:
				log.w(message_data.drop_reason)

	return response.data


func _wait_for_sender_user() -> void:
	if sender_user != null: return
	await _sender_user_loaded


func _load_sender_user() -> void:
	if sender_user != null: return
	var current_user_response = await rest.get_users([], [])
	if current_user_response.data.is_empty():
		push_error("Current Twitch User can't be loaded. (Can't send chat messages)")
		return
	sender_user = current_user_response.data[0]
	_sender_user_loaded.emit()


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if event_sub == null:
		result.append("No 'Event Sub' node assgined")
	if rest == null:
		result.append("No 'Rest' node assigned")
	if broadcaster_user == null:
		result.append("No target broadcaster selected.")
	return result
