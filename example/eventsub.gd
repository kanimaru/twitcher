extends Control

@onready var channel_follow_event_listener: TwitchEventListener = %ChannelFollowEventListener
@onready var twitch_service: TwitchService = %TwitchService
@onready var api: TwitchAPI = %API
@onready var eventsub: TwitchEventsub = %Eventsub
@onready var thx: Label = %Thx

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Please set this settings first before running the example!
# In Node 'TwitchService.OauthSettings' set:
# - ClientID / ClientSecret
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


func _ready() -> void:
	await twitch_service.setup()

	var current_user: TwitchUser = await twitch_service.get_current_user()
	
	twitch_service.subscribe_event(TwitchEventsubDefinition.CHANNEL_FOLLOW, {
		&"broadcaster_user_id": current_user.id,
		&"moderator_user_id": current_user.id
	})
	channel_follow_event_listener.received.connect(_on_event)


func _on_event(data: Dictionary) -> void:
	show_follow(data["user_name"])
	
	
func show_follow(username: String) -> void:
	thx.text = "Thx for the follow! %s" % username
	var tween = get_tree().create_tween()
	tween.tween_property(thx.label_settings, ^"font_color", Color.WHITE, 1).from(Color.TRANSPARENT)
	tween.tween_property(thx.label_settings, ^"font_color", Color.TRANSPARENT, 1)
	
	
