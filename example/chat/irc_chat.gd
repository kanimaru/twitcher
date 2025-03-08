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
## A wrapper to the Twitch services
@onready var twitch_service: TwitchService = %TwitchService
## Warning in case you missed the confugration part above
@onready var configuration_warning: Label = %ConfigurationWarning
## Direct IRC Access / old chat access
@onready var irc: TwitchIRC = %TwitchIRC
## A simplification for IRC channel access
@onready var channel: TwitchIrcChannel = %TwitchIrcChannel


func _ready() -> void:
	configuration_warning.hide()
	if not twitch_service.is_configured():
		configuration_warning.show()
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
	send.pressed.connect(_on_send_pressed)
	input_line.text_submitted.connect(_on_text_submitted)


func _on_chat_message(from_user: String, message: String, tags: TwitchTags.Message) -> void:
	# Get all badges from the user that sends the message
	var badges : Array[SpriteFrames] = tags.badges as Array[SpriteFrames]
	# Get all emotes within the message
	var emotes : Array[TwitchIRC.EmoteLocation] = tags.emotes as Array[TwitchIRC.EmoteLocation]
	# Color of the user
	var color : String = tags.get_color()

	# Create the message container
	var chat_message : RichTextLabel = RichTextLabel.new()
	# Enable BBCode for color and sprites etc.
	chat_message.bbcode_enabled = true
	# Fit the minimum size to the content
	chat_message.fit_content = true
	# Prepare the emojis handler
	var sprite_effect : SpriteFrameEffect = SpriteFrameEffect.new()
	# Install the emojihandler into the richtext label
	chat_message.install_effect(sprite_effect)
	# Add the complete message to the container
	chat_container.add_child(chat_message)

	# Start creating the message to show
	# adds time
	var result_message : String = _get_time() + " "
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
	# adds all the emojis to the richtext and registers them to be processed
	result_message = sprite_effect.prepare_message(result_message, chat_message)
	# Add the whole message to the richtext
	chat_message.text = result_message


# Formats the time to 02:03
func _get_time() -> String:
	var time_data : Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d" % [time_data["hour"], time_data["minute"]]


func _send_message() -> void:
	var message : String = input_line.text # Get the message from the input
	await channel.chat(message) # send the message to channel
	input_line.text = "" # clean the input


## Callback when user pressed enter in text input
func _on_text_submitted(new_text: String) -> void:
	_send_message()
	

## Callback when user pressed send button
func _on_send_pressed() -> void:
	_send_message()
