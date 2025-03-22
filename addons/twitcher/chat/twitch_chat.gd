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
		
## Channel of the chat that this node should listen too
@export var target_user_channel: String = "":
	set = _update_target_user_channel

var twitch_event_listener: TwitchEventListener = TwitchEventListener.new()

var broadcaster_user: TwitchUser:
	set = _update_broadcaster_user

var sender_user: TwitchUser

## Triggered when a chat message got received
signal message_received(message: TwitchChatMessage)
## Rest API got changed
signal rest_updated(rest: TwitchAPI)


func _ready() -> void:
	_log.d("is ready")
	eventsub.event.connect(_on_event_received)
	_update_target_user_channel(target_user_channel)

## Resolves username to TwitchUser
func _update_target_user_channel(val: String) -> void:
	target_user_channel = val
	if not is_inside_tree(): return
	if val != null && val != "":
		_log.d("change channel to %s" % val)
		var opt : TwitchGetUsers.Opt = TwitchGetUsers.Opt.create()
		opt.login = [ val ] as Array[String]
		broadcaster_user = await api.get_user(opt)
	else:
		broadcaster_user = null
		

## Perepares the user preloads badges and emojis
func _update_broadcaster_user(val: TwitchUser) -> void:
		broadcaster_user = val
		update_configuration_warnings()
		notify_property_list_changed()
		if broadcaster_user != null:
			media_loader.preload_badges(broadcaster_user.id)
			media_loader.preload_emotes(broadcaster_user.id)
			_subscribe_to_channel()

## Subscribe to eventsub if not happend yet
func _subscribe_to_channel() -> void:
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
