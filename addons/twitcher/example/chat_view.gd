extends Control

#
# basic chat view for examples
#

## Container where the messages get added
@onready var _chat_container: VBoxContainer = %ChatContainer
## Text to send
@onready var _input_line: LineEdit = %InputLine
## Button to send a message
@onready var _send: Button = %Send
## Warning in case you missed the confugration part above
@onready var _configuration_warning: Label = %ConfigurationWarning
@onready var _scroll_container: ScrollContainer = %ScrollContainer

var message: String:
	get(): return _input_line.text
	set(val): _input_line.text = val

## When a message should be send
signal message_sent(message: String)


func _ready() -> void:
	_configuration_warning.hide()
	
	# When the send button or enter was pressed send the message
	_send.pressed.connect(_on_send_pressed)
	_input_line.text_submitted.connect(_on_text_submitted)

		
func show_configuration_warning() -> void:
	_configuration_warning.show()


func show_message(msg: String) -> void:
	# Create the message container
	var chat_message : RichTextLabel = RichTextLabel.new()
	chat_message.bbcode_enabled = true # Enable BBCode for color and sprites etc.
	chat_message.fit_content = true # Message should stretch to its content

	# Prepare the emojis handler
	var sprite_effect : SpriteFrameEffect = SpriteFrameEffect.new()
	chat_message.install_effect(sprite_effect) # Install the emojihandler into the richtext label
	_chat_container.add_child(chat_message) # Add the complete message to the container
	
	# Perpare all the sprites for the richtext label
	msg = sprite_effect.prepare_message(msg, chat_message)
	chat_message.text = _get_time() + " " + msg
	
	_clean_old_messages()
	
	# Scroll to the bottom of the container
	_scroll_container.scroll_vertical = 9999
	
	
# Cleans old messages that are out of position
func _clean_old_messages() -> void:
	for child: RichTextLabel in _chat_container.get_children():
		if _scroll_container.global_position.y > child.global_position.y - child.size.y:
			child.queue_free()
		else: break # break cause childs are ordered and the other childs are all inside of the sight
	
	
# Formats the time to 02:03
func _get_time() -> String:
	var time_data : Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d" % [time_data["hour"], time_data["minute"]]


func _send_message() -> void:
	var msg : String = _input_line.text # Get the message from the input
	_input_line.text = "" # clean the input
	message_sent.emit(msg) # send the message to channel


## Callback when user pressed enter in text input
func _on_text_submitted(_new_text: String) -> void:
	_send_message()
	

## Callback when user pressed send button
func _on_send_pressed() -> void:
	_send_message()
