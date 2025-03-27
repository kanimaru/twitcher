@icon("../assets/chat-icon.svg")
@tool
extends Twitcher

## Grants access to read and write to a chat
class_name TwitchChat

static var _log: TwitchLogger = TwitchLogger.new("TwitchChat")

@export var eventsub: TwitchEventsub:
	set(val):
		eventsub = val
		update_configuration_warnings()
@export var media_loader: TwitchMediaLoader:
	set(val):
		media_loader = val
		update_configuration_warnings()
@export var api: TwitchAPI:
	set(val):
		api = val
		update_configuration_warnings()
@export var broadcaster_user: TwitchUser:
	set(val):
		broadcaster_user = val
		update_configuration_warnings()
## Can be null. Then the owner of the access token will be used to send message aka the current user.
@export var sender_user: TwitchUser

var twitch_event_listener: TwitchEventListener = TwitchEventListener.new()

## Triggered when a chat message got received
signal message_received(message: TwitchChatMessage)
## Rest API got changed
signal rest_updated(rest: TwitchAPI)


func _ready() -> void:
	_log.d("is ready")
	eventsub.event.connect(_on_event_received)


## Subscribe to eventsub and preload data if not happend yet
func subscribe() -> void:
	if broadcaster_user != null:
		media_loader.preload_badges(broadcaster_user.id)
		media_loader.preload_emotes(broadcaster_user.id)
			
	var subscriptions: Array[TwitchEventsubConfig] = eventsub.get_subscriptions()
	for subscription: TwitchEventsubConfig in subscriptions:
		if subscription.type == TwitchEventsubDefinition.Type.CHANNEL_CHAT_MESSAGE and \
			subscription.condition.broadcaster_user_id == broadcaster_user.id:
				# it is already subscribed
				return
		
	var current_user: TwitchGetUsers.Response = await api.get_users(null)
	sender_user = current_user.data[0]
	
	var config: TwitchEventsubConfig = TwitchEventsubConfig.new()
	config.type = TwitchEventsubDefinition.Type.CHANNEL_CHAT_MESSAGE
	config.condition = {
		"broadcaster_user_id": broadcaster_user.id,
		"user_id": sender_user.id
	}
	eventsub.subscribe(config)


func _on_event_received(type: StringName, data: Dictionary) -> void:
	if type != TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE.value: return
	var message: TwitchChatMessage = TwitchChatMessage.from_json(data)
	if message.broadcaster_user_id == broadcaster_user.id:
		message_received.emit(message)


func send_message(message: String, reply_parent_message_id: String = "") -> Array[TwitchSendChatMessage.ResponseData]:
	var message_body: TwitchSendChatMessage.Body = TwitchSendChatMessage.Body.new()
	message_body.broadcaster_id = broadcaster_user.id
	message_body.sender_id = sender_user.id
	message_body.message = message
	if reply_parent_message_id:
		message_body.reply_parent_message_id = reply_parent_message_id

	var response: TwitchSendChatMessage.Response = await api.send_chat_message(message_body)
	if _log.enabled:
		for message_data: TwitchSendChatMessage.ResponseData in response.data:
			if not message_data.is_sent:
				_log.w(message_data.drop_reason)

	return response.data


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if eventsub == null:
		result.append("TwitchEventsub not assgined")
	if media_loader == null:
		result.append("TwitchMediaLoader not assgined")
	if api == null:
		result.append("TwitchAPI not assgined")
	if broadcaster_user == null:
		result.append("Target broadcaster not specified")
	return result
