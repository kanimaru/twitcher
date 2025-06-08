extends "res://example/chat/eventsub_chat.gd"

@onready var broadcaster_usage: CheckBox = %BroadcasterUsage
@onready var broadcaster_status: Label = %BroadcasterStatus
@onready var authorize_broadcaster: Button = %AuthorizeBroadcaster
@onready var broadcaster_auth: TwitchAuth = %BroadcasterAuth
@onready var broadcaster_user: UserConverter = %BroadcasterUser

@onready var bot_usage: CheckBox = %BotUsage
@onready var bot_status: Label = %BotStatus
@onready var authorize_bot: Button = %AuthorizeBot
@onready var bot_auth: TwitchAuth = %BotAuth
@onready var bot_user: UserConverter = %BotUser

@onready var api: TwitchAPI = %API

func _ready() -> void:
	super._ready()
	authorize_broadcaster.pressed.connect(_on_broadcaster_authorize)
	authorize_bot.pressed.connect(_on_bot_authorize)


func _on_sent_message(message: String) -> void:
	if broadcaster_usage.button_pressed:
		api.token = broadcaster_auth.token
		twitch_chat.sender_user = broadcaster_user.user
	if bot_usage.button_pressed:
		api.token = bot_auth.token
		twitch_chat.sender_user = bot_user.user
	super._on_sent_message(message)


func _on_broadcaster_authorize() -> void:
	broadcaster_status.text = "Auth ongoing..."
	await broadcaster_auth.authorize()
	broadcaster_status.text = "Setup correctly" if broadcaster_auth.is_authenticated else "Setup failed"


func _on_bot_authorize() -> void:
	bot_status.text = "Auth ongoing..."
	await bot_auth.authorize()
	bot_status.text = "Setup correctly" if bot_auth.is_authenticated else "Setup failed"
	
	
