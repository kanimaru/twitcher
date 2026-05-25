extends Node

const ChatView = preload("uid://dac0roqrgssf1")

@onready var twitch_chat: TwitchChat = %TwitchChat
@onready var chat_view: ChatView = %ChatView
@onready var hide_timer: Timer = %HideTimer

var _current_tween: Tween

func _ready() -> void:
	twitch_chat.message_received.connect(_on_chat_message)
	hide_timer.timeout.connect(do_hide)


func do_hide() -> void:
	if _current_tween: _current_tween.stop()
	_current_tween = create_tween()
	_current_tween.tween_property(owner, ^"modulate", Color.TRANSPARENT, 2)
	hide_timer.stop()


func do_show() -> void:
	if _current_tween: _current_tween.stop()
	_current_tween = create_tween()
	_current_tween.tween_property(owner, ^"modulate", Color.WHITE, .3)


func _on_chat_message(message: TwitchChatMessage) -> void:
	do_show()
	hide_timer.start()

	# Get all badges from the user that sends the message
	var badges_dict : Dictionary = await message.get_badges(TwitchMediaLoader.instance)
	var badges : Array[SpriteFrames] = []
	badges.assign(badges_dict.values())

	# Start creating the message to show
	var result_message : String = ""
	# The sprite effect needs unique ids for every sprite that it manages
	var badge_id : int = 0
	# Add all badges to the message
	for badge: SpriteFrames in badges:
		result_message += "[sprite id='b-%s']%s[/sprite]" % [badge_id, badge.resource_path]
		badge_id += 1
	# Add the user with its color to the message
	result_message += "[color=%s]%s[/color]: " % [message.get_color(), message.chatter_user_name]

	# Show different effects depending on the message types
	match message.message_type:
		# The default message style
		TwitchChatMessage.MessageType.text:
			result_message = await show_text(message, result_message)

		# When someone is using the gigantified emotes
		TwitchChatMessage.MessageType.power_ups_gigantified_emote:
			result_message = await show_text(message, result_message, 3)

		# When someone is using the highlight my message from the channel point rewards
		TwitchChatMessage.MessageType.channel_points_highlighted:
			result_message += "[bgcolor=#755ebc][color=#e9fffb]"
			result_message = await show_text(message, result_message)
			result_message += "[/color][/bgcolor]"

		# When someone is using the message effect bit reward
		TwitchChatMessage.MessageType.power_ups_message_effect:
			result_message += "[shake rate=20.0 level=5 connected=1]"
			result_message = await show_text(message, result_message)
			result_message += "[/shake]"

	# Perpare all the sprites for the richtext label
	chat_view.show_message(result_message)


## Prepares the message so that all fragments will be shown correctly
func show_text(message: TwitchChatMessage, current_text: String, emote_scale: int = 1) -> String:
	var media_loader: TwitchMediaLoader = TwitchMediaLoader.instance
	# Load emotes and badges in parallel to improve the speed
	await message.load_emotes_from_fragment(media_loader)
	# Unique Id for the spriteframes to identify them
	var fragment_id : int = 0
	for fragment : TwitchChatMessage.Fragment in message.message.fragments:
		fragment_id += 1
		match fragment.type:
			TwitchChatMessage.FragmentType.text:
				current_text += fragment.text
			TwitchChatMessage.FragmentType.cheermote:
				var cheermote_scale: StringName = TwitchCheermoteDefinition.SCALE_MAP.get(emote_scale, TwitchCheermoteDefinition.SCALE_1)
				var cheermote : SpriteFrames = await fragment.cheermote.get_sprite_frames(media_loader, cheermote_scale)
				current_text += "[sprite id='f-%s']%s[/sprite]" % [fragment_id, cheermote.resource_path]
			TwitchChatMessage.FragmentType.emote:
				var emote : SpriteFrames = await fragment.emote.get_sprite_frames(media_loader, emote_scale)
				current_text += "[sprite id='f-%s']%s[/sprite]" % [fragment_id, emote.resource_path]
			TwitchChatMessage.FragmentType.mention:
				current_text += "[color=%s]@%s[/color]" % ["#00a0b6", fragment.mention.user_name]
	return current_text
