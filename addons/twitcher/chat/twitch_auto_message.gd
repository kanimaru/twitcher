extends Node

## Experimental: Node is not stable yet. For suggestions and feedback please use discord. 
class_name TwitchAutoMessage

static var all_rotational_messages: Array[TwitchAutoMessage] = []

## Should the TwitchBot Node be used to send the message
@export var use_bot: bool
## Should it send an announcement
@export var announcement: bool
## The color of the announcement obviously :D
@export var announcement_color: TwitchAnnouncementColor.Enum
## The message that should be send
@export_multiline var message: String
## only send it on source streamer when stream together
@export var source_only: bool = true
## Weight of how often this message will be picked over every other message
@export var weight: int = 1

## Optional when empty it will use the user of the current token
@export var broadcaster: TwitchUser
## Optional sender if empty will use the broadcaster
@export var sender: TwitchUser

var last_send: int

func _enter_tree() -> void:
	all_rotational_messages.append(self)
	

func _exit_tree() -> void:
	all_rotational_messages.erase(self)


func send() -> void:
	var color: TwitchAnnouncementColor = TwitchAnnouncementColor.all_colors[announcement_color]
	
	if use_bot: 
		if announcement:
			TwitchBot.announcement(message, color, source_only, broadcaster)
		else:
			TwitchBot.chat(message, "", source_only, broadcaster)
		return
	
	if not broadcaster: broadcaster = await TwitchService.get_current_user_via_api(TwitchAPI.instance)
	if not sender: sender = broadcaster
	if announcement:
		var body: TwitchSendChatAnnouncement.Body = TwitchSendChatAnnouncement.Body.new()
		body.color = color.value
		body.message = message
		body.source_only = source_only
		TwitchAPI.instance.send_chat_announcement(body, sender.id, broadcaster.id)
	else:
		var body: TwitchSendChatMessage.Body = TwitchSendChatMessage.Body.new()
		body.broadcaster_id = broadcaster.id
		body.for_source_only = source_only
		body.sender_id = sender.id
		body.message = message
		TwitchAPI.instance.send_chat_message(body)
