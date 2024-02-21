extends Control

func _ready() -> void:
	# You can also go directly to Project -> Project Settings -> Twitch -> Eventsub
	# and setup this one there.
	var broadcaster_id = TwitchSetting.broadcaster_id;
	ProjectSettings.set_setting("twitch/eventsub/channel_follow/subscribed", true);
	ProjectSettings.set_setting("twitch/eventsub/channel_follow/broadcaster_user_id", broadcaster_id);
	ProjectSettings.set_setting("twitch/eventsub/channel_follow/moderator_user_id", broadcaster_id);

	TwitchService.setup();
	TwitchService.eventsub.event.connect(_on_event)

func _on_event(type: String, data: Dictionary):
	match type:
		"channel.follow":
			print("Thx for following %s" % data["user_name"]);
