extends Resource

class_name TwitchIrcSetting

const CAP_COMMANDS := &"twitch.tv/commands"
const CAP_MEMBERSHIP := &"twitch.tv/membership"
const CAP_TAGS := &"twitch.tv/tags"


## The name of the bot within the chat
@export var username := ""

## Join the channels after connect
@export var auto_join_channels: Array[StringName] = []

## Twitch IRC Server URL
@export var server := "wss://irc-ws.chat.twitch.tv:443"

## Needed because IRC may disconnect on to many message per second
@export var send_message_delay_ms := 320

@export_flags(CAP_COMMANDS, CAP_MEMBERSHIP, CAP_TAGS) var capabilities := 0

var irc_capabilities: Array[StringName]:
	get():
		var result : Array[StringName] = []
		if capabilities & 1 == 1:
			result.append(CAP_COMMANDS)
		if capabilities & 2 == 2:
			result.append(CAP_MEMBERSHIP)
		if capabilities & 4 == 4:
			result.append(CAP_TAGS)
		return result


static func get_all_capabillities() -> Array[StringName]:
	return [CAP_COMMANDS, CAP_MEMBERSHIP, CAP_TAGS];
