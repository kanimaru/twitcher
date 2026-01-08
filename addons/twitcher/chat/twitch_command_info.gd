extends RefCounted

## Meta information about the command sender
class_name TwitchCommandInfo


var command : TwitchCommandBase
var channel_name : String
var username : String
var arguments : PackedStringArray = []
## The original received message as string
var text_message : String
## Depending on the type it's either a TwitchChatMessage or a Dictionary of the whisper message data
var original_message : Variant


func _init(
	_command: TwitchCommandBase,
	_channel_name: String,
	_username: String,
	_original_message: Variant,
	_text_message: String):
	command = _command
	channel_name = _channel_name
	username = _username
	original_message = _original_message
	text_message = _text_message
