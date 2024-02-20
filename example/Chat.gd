extends Control

@onready var chat_container: VBoxContainer = %ChatContainer
@onready var input_line: LineEdit = %InputLine
@onready var send: Button = %Send
@onready var channel: TwitchIrcChannel = %TwitchIrcChannel

func _ready() -> void:
	TwitchService.setup();
	channel.message_received.connect(_on_chat_message);

func _on_chat_message(from_user: String, message: String, tags: TwitchTags.Message):
	var badges = await tags.get_badges() as Array[SpriteFrames];
	var emotes = await tags.get_emotes() as Array[TwitchIRC.EmoteLocation];
	var color = tags.get_color();

	var chat_message = RichTextLabel.new();
	chat_message.bbcode_enabled = true;
	chat_message.fit_content = true;
	var sprite_effect = SpriteFrameEffect.new();
	chat_message.install_effect(sprite_effect)
	chat_container.add_child(chat_message);

	var result_message = _get_time() + " "
	var badge_id = 0;
	for badge: SpriteFrames in badges:
		result_message += "[sprite id='b-%s']%s[/sprite]" % [badge_id, badge.resource_path];
		badge_id += 1;
	result_message += "[color=%s]%s[/color]: " % [color, from_user];

	var start : int = 0;
	for emote in emotes:
		var part := message.substr(start, emote.start - start);
		result_message += part;
		result_message += "[sprite id='%s']%s[/sprite]" % [emote.start, emote.sprite_frames.resource_path];
		start = emote.end + 1;

	var part := message.substr(start, message.length() - start);
	result_message += part;
	result_message = sprite_effect.prepare_message(result_message, chat_message);
	chat_message.text = result_message;
func _get_time() -> String:
	var time_data = Time.get_time_dict_from_system();
	return "%02d:%02d" % [time_data["hour"], time_data["minute"]];
