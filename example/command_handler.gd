extends Control

func _ready() -> void:
	# !!! Change following in the project settings that the example works !!!
	# twitch/auth/broadcaster_id 	< Your broadcaster id you can convert it here https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/
	# twitch/auth/client_id 		< you find while registering the application see readme for howto
	# twitch/auth/client_secret		< you find while registering the application see readme for howto
	# twitch/websocket/irc/username < Your username needed for IRC
	# twitch/auth/scopes/chat		< Add both Scopes chat_read, chat_edit

	# Setup all of the library, connect to evensub, irc etc.
	TwitchService.setup();
	# Register the !hello command
	TwitchService.add_command("hello", _on_hello_world);

	# Create a channel programatically this get automatically joined as soon as it is attached to the scene
	var channel = TwitchIrcChannel.new();
	channel.channel_name = "kani_dev";
	add_child(channel);

	# Listen to the chat messages of this channel
	channel.message_received.connect(_on_message_received)

func _on_hello_world(info: TwitchCommandInfo):
	# Check if the message got send via whisper
	if info.tags is TwitchTags.Whisper:
		TwitchService.chat("/me whispers hello there %s!" % info.username);
	# Check if the message got send via chat message
	if info.tags is TwitchTags.PrivMsg:
		TwitchService.chat("Hello there %s!" % info.username);

func _on_message_received(from_user: String, message: String, tags: TwitchTags.Message):
	print("Received Message form %s: %s" % [from_user, message])
