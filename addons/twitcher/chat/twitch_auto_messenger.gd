extends Node

## Experimental: Node is not stable yet. For suggestions and feedback please use discord.
## Used to send the twitch_auto_messages
class_name TwitchAutoMessenger

## The minimal delay between the messages
@export var delay_in_s: float = 300:
	set = _update_delay_in_s
	
## The minimal amount of messages before a new message got triggered
@export var min_messages: int = -1

## The broadcasters chat this node will listen for. If empty the user of the token is used.
@export var broadcaster_to_listen: TwitchUser
## Eventsub that should be used to listen the messages for
@export var eventsub: TwitchEventsub

var _timer: Timer = Timer.new()

## The current tracker for messages received
var _current_message_sent: int
## Timer timedout and ready to send another message
var _timer_ready: bool

var _bag: Array[TwitchAutoMessage] = []


func _ready() -> void:
	_timer.autostart = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	if not eventsub: eventsub = TwitchEventsub.instance
	_update_delay_in_s(delay_in_s)
	eventsub.event_received.connect(_on_event)


func _on_event(event: TwitchEventsub.Event) -> void:
	if event.type == TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE and min_messages > 0:
		var message: TwitchESChannelChatMessage.Event = event.typed_data
		if message.broadcaster_user_id == broadcaster_to_listen.id:
			_current_message_sent += 1
			_check_to_send()
			
			
func _on_timer_timeout() -> void:
	_timer_ready = true
	_check_to_send()


func _check_to_send() -> void:
	if _timer_ready and (min_messages == -1 or min_messages <= _current_message_sent):
		_send_message()


func _fill_bag() -> void:
	for message: TwitchAutoMessage in TwitchAutoMessage.all_rotational_messages:
		for i in message.weight:
			_bag.append(message)


func _send_message() -> void:
	if _bag.is_empty(): _fill_bag()
	
	_bag.shuffle()
	var message: TwitchAutoMessage = _bag.pop_back()
	message.send()
	_timer_ready = false
	_current_message_sent = 0


func _update_delay_in_s(delay: float) -> void:
	delay_in_s = delay
	_timer.wait_time = delay
