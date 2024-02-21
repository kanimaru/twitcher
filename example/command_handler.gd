extends Control

func _ready() -> void:
	TwitchService.setup();
	TwitchService.add_command("hello", _on_hello_world);

	var channel = TwitchIrcChannel.new();
	channel.channel_name = "kani_dev";
	add_child(channel);

	channel.message_received.connect(_on_message_received)

func _on_hello_world(info: TwitchCommandInfo):
	if info.tags is TwitchTags.Whisper:
		TwitchService.chat("/me whispers hello there %s!" % info.username);
	if info.tags is TwitchTags.PrivMsg:
		TwitchService.chat("Hello there %s!" % info.username);

func _on_message_received(from_user: String, message: String, tags: TwitchTags.Message):
	print("Received Message form %s: %s" % [from_user, message])
