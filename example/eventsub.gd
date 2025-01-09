extends Control

@onready var channel_follow_event_listener: TwitchEventListener = %ChannelFollowEventListener
@onready var twitch_service: TwitchService = %TwitchService
@onready var api: TwitchRestAPI = %API
@onready var eventsub: TwitchEventsub = %Eventsub

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Please set this settings first before running the example!
# In Node 'TwitchService.OauthSettings' set:
# - ClientID / ClientSecret
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


func _ready() -> void:
	await twitch_service.setup()

	var current_user: TwitchUser = await twitch_service.get_current_user()
	api.default_broadcaster_id = current_user.id

	twitch_service.subscribe_event(TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE, {
		"broadcaster_user_id": current_user.id,
		"user_id": current_user.id
	})
	channel_follow_event_listener.received.connect(_on_event)


func _on_event(data: Dictionary) -> void:
	print("Thx for following %s" % data["user_name"]);
