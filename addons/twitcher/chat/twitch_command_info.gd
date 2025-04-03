extends RefCounted

## Meta information about the command sender
class_name TwitchCommandInfo


var command : TwitchCommand
var channel_name : String
var username : String
var arguments : Array[String]
## Depending on the type it's either a TwitchChatMessage or a Dictionary of the whisper message data
var original_message : Variant


func _init(
	_command: TwitchCommand,
	_channel_name: String,
	_username: String,
	_arguments: Array[String],
	_original_message: Variant):
	command = _command
	channel_name = _channel_name
	username = _username
	arguments = _arguments
	original_message = _original_message
