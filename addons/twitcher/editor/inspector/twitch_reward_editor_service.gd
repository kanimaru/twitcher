@tool
extends TwitchRewardService


func load_reward(twitch_reward: TwitchReward) -> TwitchRewardService.LoadError:
	var error: TwitchRewardService.LoadError = await super.load_reward(twitch_reward)
	var toaster: EditorToaster = EditorInterface.get_editor_toaster()
	match error:
		TwitchRewardService.LoadError.NO_ID_AVAILABLE:
			EditorInterface.get_editor_toaster().push_toast("Can't load %s it has no ID to load" % twitch_reward.title, EditorToaster.SEVERITY_ERROR)
		TwitchRewardService.LoadError.NO_REWARD_FOUND:
			pass
		TwitchRewardService.LoadError.OK:
			EditorInterface.get_editor_toaster().push_toast("Loaded '%s' from Twitch" % twitch_reward.title, EditorToaster.SEVERITY_INFO)
	return error


func save_reward(twitch_reward: TwitchReward) -> TwitchRewardService.SaveError:
	var error = await super.save_reward(twitch_reward)
	match error:
		TwitchRewardService.SaveError.OK:
			EditorInterface.get_editor_toaster().push_toast("Saved the reward %s" % twitch_reward.title, EditorToaster.SEVERITY_INFO)
		TwitchRewardService.SaveError.REWARD_NOT_OWNED:
			EditorInterface.get_editor_toaster().push_toast("You can only update custom rewards from the application that created it in the first place.", EditorToaster.SEVERITY_ERROR)
		TwitchRewardService.SaveError.UNKNOWN:
			EditorInterface.get_editor_toaster().push_toast("Something unexpected happend during save", EditorToaster.SEVERITY_ERROR)
	return error
	

func _convert_twitch_reward(twitch_reward: TwitchReward, reward: TwitchCustomReward) -> void:
	convert_to_twitch_reward(twitch_reward, reward, media_loader)


## Helper method to update values from a TwitchCustomReward -> TwitchReward
static func convert_to_twitch_reward(twitch_reward: TwitchReward, reward: TwitchCustomReward, media_loader: TwitchMediaLoader = null) -> void:
	var undo := EditorInterface.get_editor_undo_redo()
	undo.create_action("Update Twitch Reward '%s'" % reward.title)
	
	undo.add_undo_property(twitch_reward, &"id", twitch_reward.id)
	undo.add_undo_property(twitch_reward, &"title", twitch_reward.title)
	undo.add_undo_property(twitch_reward, &"description", twitch_reward.description)
	undo.add_undo_property(twitch_reward, &"cost", twitch_reward.cost)
	undo.add_undo_property(twitch_reward, &"background_color", twitch_reward.background_color)
	undo.add_undo_property(twitch_reward, &"is_enabled", twitch_reward.is_enabled)
	undo.add_undo_property(twitch_reward, &"is_user_input_required", twitch_reward.is_user_input_required)
	undo.add_undo_property(twitch_reward, &"is_max_per_stream_enabled", twitch_reward.is_max_per_stream_enabled)
	undo.add_undo_property(twitch_reward, &"max_per_stream", twitch_reward.max_per_stream)
	undo.add_undo_property(twitch_reward, &"is_max_per_user_per_stream_enabled", twitch_reward.is_max_per_user_per_stream_enabled)
	undo.add_undo_property(twitch_reward, &"max_per_user_per_stream", twitch_reward.max_per_user_per_stream)
	undo.add_undo_property(twitch_reward, &"is_global_cooldown_enabled", twitch_reward.is_global_cooldown_enabled)
	undo.add_undo_property(twitch_reward, &"global_cooldown_seconds", twitch_reward.global_cooldown_seconds)
	undo.add_undo_property(twitch_reward, &"is_paused", twitch_reward.is_paused)
	undo.add_undo_property(twitch_reward, &"should_redemptions_skip_request_queue", twitch_reward.should_redemptions_skip_request_queue)
	undo.add_undo_property(twitch_reward, &"is_in_stock", twitch_reward.is_in_stock)
	undo.add_undo_property(twitch_reward, &"redemptions_redeemed_current_stream", twitch_reward.redemptions_redeemed_current_stream)
	undo.add_undo_property(twitch_reward, &"cooldown_expires_at", twitch_reward.cooldown_expires_at)
	undo.add_undo_method(twitch_reward, &"emit_changed")
	
	undo.add_do_property(twitch_reward, &"id", reward.id)
	undo.add_do_property(twitch_reward, &"title", reward.title)
	undo.add_do_property(twitch_reward, &"description", reward.prompt)
	undo.add_do_property(twitch_reward, &"cost", reward.cost)
	undo.add_do_property(twitch_reward, &"background_color", Color.html(reward.background_color))
	undo.add_do_property(twitch_reward, &"is_enabled", reward.is_enabled)
	undo.add_do_property(twitch_reward, &"is_user_input_required", reward.is_user_input_required)
	undo.add_do_property(twitch_reward, &"is_max_per_stream_enabled", reward.max_per_stream_setting.is_enabled)
	undo.add_do_property(twitch_reward, &"max_per_stream", reward.max_per_stream_setting.max_per_stream)
	undo.add_do_property(twitch_reward, &"is_max_per_user_per_stream_enabled", reward.max_per_user_per_stream_setting.is_enabled)
	undo.add_do_property(twitch_reward, &"max_per_user_per_stream", reward.max_per_user_per_stream_setting.max_per_user_per_stream)
	undo.add_do_property(twitch_reward, &"is_global_cooldown_enabled", reward.global_cooldown_setting.is_enabled)
	undo.add_do_property(twitch_reward, &"global_cooldown_seconds", reward.global_cooldown_setting.global_cooldown_seconds)
	undo.add_do_property(twitch_reward, &"is_paused", reward.is_paused)
	undo.add_do_property(twitch_reward, &"should_redemptions_skip_request_queue", reward.should_redemptions_skip_request_queue)
	undo.add_do_property(twitch_reward, &"is_in_stock", twitch_reward.is_in_stock)
	undo.add_do_property(twitch_reward, &"redemptions_redeemed_current_stream", twitch_reward.redemptions_redeemed_current_stream)
	undo.add_do_property(twitch_reward, &"cooldown_expires_at", twitch_reward.cooldown_expires_at)
	undo.add_do_method(twitch_reward, &"emit_changed")
	
	undo.commit_action()
	
	# Doesn't undo this ones it doesn't make sense the value is temporary and the actual info from 
	# Twitch. With undoing them you wouldn't reset Twitch :D
	
	if reward.image && media_loader:
		twitch_reward.image_1 = await media_loader.load_image(reward.image.url_1x)
		twitch_reward.image_2 = await media_loader.load_image(reward.image.url_2x)
		twitch_reward.image_4 = await media_loader.load_image(reward.image.url_3x)

	twitch_reward.is_in_stock = reward.is_in_stock
	twitch_reward.redemptions_redeemed_current_stream = reward.redemptions_redeemed_current_stream
	twitch_reward.cooldown_expires_at = reward.cooldown_expires_at
