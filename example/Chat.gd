extends Control

@onready var chat_container: VBoxContainer = %ChatContainer
@onready var input_line: LineEdit = %InputLine
@onready var send: Button = %Send
@onready var channel: TwitchIrcChannel = %TwitchIrcChannel

func _ready() -> void:
	TwitchService.setup();
	var badges = await TwitchService.get_badges(["broadcaster/1"]);
	channel.message_received.connect(_on_chat_message);
	send.button_up.connect(_on_chat_message.bind("Test:", "", Color.BLACK, badges["broadcaster/1"]))

func _on_chat_message(from_user: String, message: String, tags: TwitchTags.Message):
	var badges = await tags.get_badges();
	add(from_user, message, tags.get_color(), badges[0])

func add(from_user: String, message: String, color: Color, badges: Array[SpriteFrames]):
	var chat_message = RichTextLabel.new();
	chat_message.bbcode_enabled = true;
	chat_message.fit_content = true;
	chat_container.add_child(chat_message);
	# Users Color
	chat_message.push_color(color);

	#for badge in badges:
	chat_message.push_customfx(SpriteFrameEffect.new(badges[0], chat_message), {});
	chat_message.append_text(_get_time() + " " + from_user + ": " + message);
	#for badge in badges:
	#	chat_message.push_customfx(SpriteFrameEffect.new(badge, chat_message), {});


func _get_time() -> String:
	var time_data = Time.get_time_dict_from_system();
	return "%02d:%02d" % [time_data["hour"], time_data["minute"]];
