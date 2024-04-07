extends Control

## Container where the messages get added
@onready var chat_container: VBoxContainer = %ChatContainer
## Text to send
@onready var input_line: LineEdit = %InputLine
## Button to send a message
@onready var send: Button = %Send
## Channel to send / receive the messages
@onready var channel: TwitchIrcChannel = %TwitchIrcChannel

func _ready() -> void:
	# !!! Change following in the project settings that the example works !!!
	# twitch/auth/broadcaster_id 	< Your broadcaster id you can convert it here https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/
	# twitch/auth/client_id 		< you find while registering the application see readme for howto
	# twitch/auth/client_secret		< you find while registering the application see readme for howto
	# twitch/websocket/irc/username < Your username needed for IRC
	# twitch/auth/scopes/chat		< Add both Scopes chat_read, chat_edit

	# Setup all of the library, connect to evensub, irc etc.
	await TwitchService.setup();
	# Listen to the message received of the chat
	channel.message_received.connect(_on_chat_message);
	# When the send button is pressed send the message
	send.pressed.connect(_send_message);

func _on_chat_message(from_user: String, message: String, tags: TwitchTags.Message):
	# Get all badges from the user that sends the message
	var badges = await tags.get_badges() as Array[SpriteFrames];
	# Get all emotes within the message
	var emotes = await tags.get_emotes() as Array[TwitchIRC.EmoteLocation];
	# Color of the user
	var color = tags.get_color();

	# Create the message container
	var chat_message = RichTextLabel.new();
	# Enable BBCode for color and sprites etc.
	chat_message.bbcode_enabled = true;
	# Fit the minimum size to the content
	chat_message.fit_content = true;
	# Prepare the emojis handler
	var sprite_effect = SpriteFrameEffect.new();
	# Install the emojihandler into the richtext label
	chat_message.install_effect(sprite_effect)
	# Add the complete message to the container
	chat_container.add_child(chat_message);

	# Start creating the message to show
	# adds time
	var result_message = _get_time() + " "
	# The sprite effect needs unique ids for every sprite that it manages
	var badge_id = 0;
	# Add all badges to the message
	for badge: SpriteFrames in badges:
		result_message += "[sprite id='b-%s']%s[/sprite]" % [badge_id, badge.resource_path];
		badge_id += 1;
	# Add the user with its color to the message
	result_message += "[color=%s]%s[/color]: " % [color, from_user];

	# Replace all the emoji names with the appropriate emojis
	# Tracks the start where to replace next
	var start : int = 0;
	for emote in emotes:
		# Takes text between the start / the last emoji and the next emoji
		var part := message.substr(start, emote.start - start);
		# Adds this text to the message
		result_message += part;
		# Adds the sprite after the text
		result_message += "[sprite id='%s']%s[/sprite]" % [emote.start, emote.sprite_frames.resource_path];
		# Marks the start of the next text
		start = emote.end + 1;

	# get the text between the last emoji and the end
	var text_part := message.substr(start, message.length() - start);
	# adds it to the message
	result_message += text_part;
	# adds all the emojis to the richtext and registers them to be processed
	result_message = sprite_effect.prepare_message(result_message, chat_message);
	# Add the whole message to the richtext
	chat_message.text = result_message;

# Formats the time to 02:03
func _get_time() -> String:
	var time_data = Time.get_time_dict_from_system();
	return "%02d:%02d" % [time_data["hour"], time_data["minute"]];

func _send_message():
	# Get the message from the input
	var message = input_line.text;
	# clean the input
	input_line.text = "";
	# send the message to channel
	channel.chat(message);
