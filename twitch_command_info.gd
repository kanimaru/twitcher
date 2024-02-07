extends RefCounted
class_name TwitchCommandInfo

var sender_data : TwitchSenderData
var command : String
var whisper : bool

func _init(sndr_dt : TwitchSenderData, cmd : String, whspr : bool):
	sender_data = sndr_dt
	command = cmd
	whisper = whspr
