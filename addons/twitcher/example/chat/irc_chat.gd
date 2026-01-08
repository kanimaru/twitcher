extends Control

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Please set this settings first before running the example!
# In Node 'TwitchService.OauthSettings' set:
# - ClientID / ClientSecret
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

const ChatView = preload("res://addons/twitcher/example/chat_view.gd")

## A wrapper to the Twitch services
@onready var twitch_service: TwitchService = %TwitchService
## Direct IRC Access / old chat access
@onready var irc: TwitchIRC = %TwitchIRC
## A simplification for IRC channel access
@onready var channel: TwitchIrcChannel = %TwitchIrcChannel

@onready var chat_view: ChatView = %ChatView

func _ready() -> void:
	if not twitch_service.is_configured():
		chat_view.show_configuration_warning()
		push_error("Please configure client credentials according to the readme")
		return

	# Setup all of the library
	await twitch_service.setup()
	# You should do this manually and set your username directly in the settings that your program
	# doesn't need to make a roundtrip to the Twitch API everytime it starts. This is for example purpose.
	var current_user: TwitchUser = await twitch_service.get_current_user()
	# Set username that Twitch IRC knows who is talking to it
	irc.setting.username = current_user.login
	# Set the channel name that the node listens to the channel messages
	channel.channel_name = current_user.display_name
	# Listen to the message received of the chat
	channel.message_received.connect(_on_chat_message)

	# When the send button is pressed send the message
	chat_view.message_sent.connect(_on_message_sent)


func _on_chat_message(from_user: String, message: String, tags: TwitchTags.Message) -> void:
	# Get all badges from the user that sends the message
	var badges : Array[SpriteFrames] = tags.badges as Array[SpriteFrames]
	# Get all emotes within the message
	var emotes : Array[TwitchIRC.EmoteLocation] = tags.emotes as Array[TwitchIRC.EmoteLocation]
	# Color of the user
	var color : String = tags.get_color()

	# Start creating the message to show
	# adds time
	var result_message : String
	# The sprite effect needs unique ids for every sprite that it manages
	var badge_id : int = 0
	# Add all badges to the message
	for badge: SpriteFrames in badges:
		result_message += "[sprite id='b-%s']%s[/sprite]" % [badge_id, badge.resource_path]
		badge_id += 1
	# Add the user with its color to the message
	result_message += "[color=%s]%s[/color]: " % [color, from_user]

	# Replace all the emoji names with the appropriate emojis
	# Tracks the start where to replace next
	var start : int = 0
	for emote : TwitchIRC.EmoteLocation in emotes:
		# Takes text between the start / the last emoji and the next emoji
		var part : String = message.substr(start, emote.start - start)
		# Adds this text to the message
		result_message += part
		# Adds the sprite after the text
		result_message += "[sprite id='%s']%s[/sprite]" % [emote.start, emote.sprite_frames.resource_path]
		# Marks the start of the next text
		start = emote.end + 1

	# get the text between the last emoji and the end
	var text_part : String = message.substr(start, message.length() - start)
	# adds it to the message
	result_message += text_part
	
	chat_view.show_message(result_message)


## Callback when user pressed send button
func _on_message_sent(message: String) -> void:
	channel.chat(message) # send the message to channel
