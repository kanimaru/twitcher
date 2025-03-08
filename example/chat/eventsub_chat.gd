extends Control


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Please set this settings first before running the example!
# In Node 'TwitchService.OauthSettings' set:
# - ClientID / ClientSecret
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


## Container where the messages get added
@onready var chat_container: VBoxContainer = %ChatContainer
## Text to send
@onready var input_line: LineEdit = %InputLine
## Button to send a message
@onready var send: Button = %Send
## Channel to send / receive the messages
@onready var twitch_chat: TwitchChat = %TwitchChat
## A wrapper to the Twitch services
@onready var twitch_service: TwitchService = %TwitchService
## Warning in case you missed the confugration part above
@onready var configuration_warning: Label = %ConfigurationWarning

@export var token: OAuthToken


func _ready() -> void:
	configuration_warning.hide()
	if twitch_service.oauth_setting.client_id == "":
		configuration_warning.show()
		push_error("Please configure client credentials according to the readme")
		return

	# Setup the library
	await twitch_service.setup()
	var current_user: TwitchUser = await twitch_service.get_current_user()
	twitch_chat.broadcaster_user = current_user

	# Listen to the message received of the chat
	twitch_chat.message_received.connect(_on_chat_message)
	# When the send button or enter was pressed send the message
	send.pressed.connect(_on_send_pressed)
	input_line.text_submitted.connect(_on_text_submitted)


func _on_chat_message(message: TwitchChatMessage) -> void:
	# Get all badges from the user that sends the message
	var badges_dict : Dictionary = await message.get_badges()
	var badges : Array[SpriteFrames] = []
	badges.assign(badges_dict.values())

	# Create the message container
	var chat_message : RichTextLabel = RichTextLabel.new()
	chat_message.bbcode_enabled = true # Enable BBCode for color and sprites etc.
	chat_message.fit_content = true # Message should stretch to its content
	
	# Prepare the emojis handler
	var sprite_effect : SpriteFrameEffect = SpriteFrameEffect.new()
	chat_message.install_effect(sprite_effect) # Install the emojihandler into the richtext label
	chat_container.add_child(chat_message) # Add the complete message to the container

	# Start creating the message to show
	var result_message : String = _get_time() + " " # adds time
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
	result_message = sprite_effect.prepare_message(result_message, chat_message)
	chat_message.text = result_message


## Prepares the message so that all fragments will be shown correctly
func show_text(message: TwitchChatMessage, current_text: String, emote_scale: int = 1) -> String:
	# Load emotes and badges in parallel to improve the speed
	await message.load_emotes_from_fragment()
	# Unique Id for the spriteframes to identify them
	var fragment_id : int = 0
	for fragment : TwitchChatMessage.Fragment in message.message.fragments:
		fragment_id += 1
		match fragment.type:
			TwitchChatMessage.FragmentType.text:
				current_text += fragment.text
			TwitchChatMessage.FragmentType.cheermote:
				var definition : TwitchCheermoteDefinition = TwitchCheermoteDefinition.new(fragment.cheermote.prefix, "%s" % fragment.cheermote.tier)
				var cheermote : SpriteFrames = await fragment.cheermote.get_sprite_frames(definition)
				current_text += "[sprite id='f-%s']%s[/sprite]" % [fragment_id, cheermote.resource_path]
			TwitchChatMessage.FragmentType.emote:
				var emote : SpriteFrames = await fragment.emote.get_sprite_frames("", emote_scale)
				current_text += "[sprite id='f-%s']%s[/sprite]" % [fragment_id, emote.resource_path]
			TwitchChatMessage.FragmentType.mention:
				current_text += "[color=%s]@%s[/color]" % ["#00a0b6", fragment.mention.user_name]
	return current_text


# Formats the time to 02:03
func _get_time() -> String:
	var time_data : Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d" % [time_data["hour"], time_data["minute"]]


func _send_message() -> void:
	var message : String = input_line.text # Get the message from the input
	input_line.text = "" # clean the input
	twitch_chat.send_message(message) # send the message to channel


## Callback when user pressed enter in text input
func _on_text_submitted(_new_text: String) -> void:
	_send_message()
	

## Callback when user pressed send button
func _on_send_pressed() -> void:
	_send_message()
