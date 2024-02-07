extends RefCounted

class_name TwitchSenderData


var user : String
var channel : TwitchChannel
var tags : Dictionary

func _init(username : String, twitch_channel : TwitchChannel, tag_dict : Dictionary):
	user = username
	channel = twitch_channel
	tags = tag_dict
