extends RefCounted

## Meta information about the command sender
class_name TwitchCommandInfo

var sender_data : TwitchSenderData
var command : String
var whisper : bool

func _init(twitch_sender_data : TwitchSenderData, command_data : String, is_whisper : bool):
	sender_data = twitch_sender_data;
	command = command_data;
	whisper = is_whisper;
