extends Node

const NOTIFICATION = preload("uid://bqwgietymy1b2")
const Notification = preload("uid://deso118lm3wux")

const CHEERMOTE = preload("uid://cftudp18otteu")
const Cheermote = preload("uid://bs11kd3horowg")

@export var notification_duration_in_s: float = 5
@export var notification_delay_in_between_in_s: float = 1

@onready var follow_twitch_event_listener: TwitchEventListener = %FollowTwitchEventListener
@onready var raid_twitch_event_listener: TwitchEventListener = %RaidTwitchEventListener
@onready var subscription_twitch_event_listener: TwitchEventListener = %SubscriptionTwitchEventListener
@onready var channel_chat_twitch_event_listener: TwitchEventListener = %ChannelChatTwitchEventListener

var _notification_queue: Array[Node]
var _current_notification: Node


func _ready() -> void:
	follow_twitch_event_listener.typed_data_received.connect(_on_follow_twitch_event)
	raid_twitch_event_listener.typed_data_received.connect(_on_raid_twitch_event)
	subscription_twitch_event_listener.typed_data_received.connect(_on_subscription_twitch_event)
	channel_chat_twitch_event_listener.typed_data_received.connect(_on_channel_chat_message_event)


func _process_notification() -> void:
	if _current_notification or _notification_queue.is_empty(): return
	_current_notification = _notification_queue.pop_front()
	add_child(_current_notification)
	await get_tree().create_timer(notification_duration_in_s).timeout
	await _current_notification.queue_free()
	_current_notification = null
	await get_tree().create_timer(notification_delay_in_between_in_s).timeout
	_process_notification()


func _on_follow_twitch_event(data: Variant) -> void:
	var follow_data: TwitchESChannelFollow.Event = data as TwitchESChannelFollow.Event
	_show_notification(follow_data.user_name, follow_data.user_id, "Thank you for following!")


func _on_raid_twitch_event(data: Variant) -> void:
	var raid_data: TwitchESChannelRaid.Event = data as TwitchESChannelRaid.Event
	_show_notification(raid_data.from_broadcaster_user_name, raid_data.user_id, "Thank you for raid!")


func _on_subscription_twitch_event(data: Variant) -> void:
	var subscribe_data: TwitchESChannelSubscribe.Event = data as TwitchESChannelSubscribe.Event
	_show_notification(subscribe_data.user_name, subscribe_data.user_id, "Thank you for subscribing!")


func _on_channel_chat_message_event(data: Variant) -> void:
	var chat_message_data: TwitchESChannelChatMessage.Event = data as TwitchESChannelChatMessage.Event
	if chat_message_data.cheer:
		var fragments: Array[TwitchESChannelChatMessage.Fragments] = chat_message_data.message.fragments
		for fragment: TwitchESChannelChatMessage.Fragments in fragments:
			if fragment.cheermote:
				var cheermote: TwitchESChannelChatMessage.Cheermote = fragment.cheermote
				show_cheermotes(cheermote)


func show_cheermotes(cheermote: TwitchESChannelChatMessage.Cheermote) -> void:
	var cheermote_definition: TwitchCheermoteDefinition = TwitchCheermoteDefinition.new(cheermote.prefix, str(cheermote.tier))
	var cheer_result = await TwitchMediaLoader.instance.get_cheer_info(cheermote_definition)
	var cheermote_obj: Cheermote = CHEERMOTE.instantiate()
	cheermote_obj.sprite_frames = cheer_result.spriteframes
	cheermote_obj.size = cheermote.bits / 4
	cheermote_obj.global_position = Vector2(randf_range(300, 700), randf_range(300, 700))
	add_child(cheermote_obj)
	cheermote_obj.apply_impulse(Vector2.RIGHT.rotated(randf() * TAU) * randf_range(1000, 2000))


func _show_notification(display_name: String, user_id: String, text: String) -> void:
	var notification: Notification = NOTIFICATION.instantiate()
	var user: TwitchUser = await TwitchService.instance.get_user_by_id(user_id)
	var profile: ImageTexture = await TwitchMediaLoader.instance.load_profile_image(user)

	notification.user_name = display_name
	notification.image = profile
	notification.text = text
	_notification_queue.append(notification)
	_process_notification()
