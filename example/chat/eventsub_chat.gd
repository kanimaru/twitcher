extends Control


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Please set this settings first before running the example!
# In Node 'TwitchService.OauthSettings' set:
# - ClientID / ClientSecret
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

const ChatView = preload("res://example/chat_view.gd")

## View to display everything
@onready var chat_view: ChatView = %ChatView
## Channel to send / receive the messages
@onready var twitch_chat: TwitchChat = %TwitchChat
## A wrapper to the Twitch services
@onready var twitch_service: TwitchService = %TwitchService
## Loader to get the emotes, badges etc.
@onready var media_loader: TwitchMediaLoader = %MediaLoader
## Hello command receiver
@onready var hello_command: TwitchCommand = %HelloCommand

@export var token: OAuthToken


func _ready() -> void:
	if twitch_service.oauth_setting.client_id == "":
		chat_view.show_configuration_warning()
		return

	# Setup the library
	await twitch_service.setup()
	
	# You can skip this when 
	var current_user: TwitchUser = await twitch_service.get_current_user()
	twitch_chat.broadcaster_user = current_user

	# Listen to the message received of the chat
	twitch_chat.message_received.connect(_on_chat_message)
	chat_view.message_sent.connect(_on_sent_message)
	hello_command.command_received.connect(_on_hello)


func _on_hello(from_username: String, info: TwitchCommandInfo, args: PackedStringArray) -> void:
	var message: TwitchChatMessage = info.original_message as TwitchChatMessage
	twitch_chat.send_message("Hello to you too %s" % from_username, message.message_id)
	

func _on_chat_message(message: TwitchChatMessage) -> void:
	# Get all badges from the user that sends the message
	var badges_dict : Dictionary = await message.get_badges(media_loader)
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
				var definition : TwitchCheermoteDefinition = TwitchCheermoteDefinition.new(fragment.cheermote.prefix, "%s" % fragment.cheermote.tier)
				var cheermote : SpriteFrames = await fragment.cheermote.get_sprite_frames(media_loader, definition)
				current_text += "[sprite id='f-%s']%s[/sprite]" % [fragment_id, cheermote.resource_path]
			TwitchChatMessage.FragmentType.emote:
				var emote : SpriteFrames = await fragment.emote.get_sprite_frames(media_loader, "", emote_scale)
				current_text += "[sprite id='f-%s']%s[/sprite]" % [fragment_id, emote.resource_path]
			TwitchChatMessage.FragmentType.mention:
				current_text += "[color=%s]@%s[/color]" % ["#00a0b6", fragment.mention.user_name]
	return current_text


func _on_sent_message(message: String) -> void:
	twitch_chat.send_message(message) # send the message to channel
