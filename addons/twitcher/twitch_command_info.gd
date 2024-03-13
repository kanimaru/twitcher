extends RefCounted

## Meta information about the command sender
class_name TwitchCommandInfo

var command_name : String
var command : TwitchCommand
var message : String
var channel_name : String
var username : String
var tags : Variant

func _init(cmd_name: String,
	cmd: TwitchCommand,
	msg: String,
	channel: String,
	user: String,
	tag: Variant):
	command = cmd;
	command_name = cmd_name;
	channel_name = channel;
	username = user;
	tags = tag;

