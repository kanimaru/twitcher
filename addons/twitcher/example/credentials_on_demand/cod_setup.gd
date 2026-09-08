extends Control

# This basic example demonstrates how you can provide software that isn't 
# preconfigured with client credentials. For example a streamerbot alternative.
# Or a custom overlay that you want to distribute to other persons.
#
# Disclaimer: When you provide such a service please take care to save the secrets encrypted!

const Auth = preload("res://addons/twitcher/example/credentials_on_demand/auth.gd")
const ChatView = preload("res://addons/twitcher/example/chat_view.gd")

@onready var auth: Auth = %Auth
@onready var chat_view: ChatView = %ChatView
@onready var twitch_service: TwitchService = %TwitchService
@onready var twitch_eventsub: TwitchEventsub = %TwitchEventsub
@onready var twitch_chat: TwitchChat = %TwitchChat


func _ready() -> void:
	auth.authorized.connect(_on_authorized)
	chat_view.hide()


func _on_authorized(token: OAuthToken) -> void:
	auth.hide()
	twitch_service.token = token
	await twitch_service.setup()
	
	var user: TwitchUser = await twitch_service.get_current_user()
	
	var config: TwitchEventsubConfig = TwitchEventsubConfig.create(TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE, {
		&"broadcaster_user_id": user.id,
		&"user_id": user.id
	})
	
	twitch_eventsub.subscribe(config)
	chat_view.show()
