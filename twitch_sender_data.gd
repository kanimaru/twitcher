extends RefCounted

class_name TwitchSenderData


var user : String
var channel : TwitchIrcChannel
var tags : Variant

func _init(username : String, twitch_channel : TwitchIrcChannel, tag_impl : Variant):
	user = username
	channel = twitch_channel
	tags = tag_impl
