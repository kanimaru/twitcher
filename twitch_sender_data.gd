extends RefCounted

class_name TwitchSenderData


var user : String
var channel : TwitchIrcChannel
var tags : Dictionary

func _init(username : String, twitch_channel : TwitchIrcChannel, tag_dict : Dictionary):
	user = username
	channel = twitch_channel
	tags = tag_dict
