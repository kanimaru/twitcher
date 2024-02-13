extends Control

@onready var chat_container: VBoxContainer = %ChatContainer
@onready var input_line: LineEdit = %InputLine
@onready var send: Button = %Send

func _ready() -> void:
	TwitchService.setup();
	TwitchService.irc.chat_message.connect(_on_chat_message);

func _on_chat_message(sender_data: TwitchSenderData, text: String):
	var chat_message = Label.new();
	chat_container.add_child(chat_message);

	chat_message.text = _get_time() + " " + sender_data.user + ": " + text;

func _get_time() -> String:
	var time_data = Time.get_time_dict_from_system();
	return "%02d:%02d" % [time_data["hour"], time_data["minute"]];
