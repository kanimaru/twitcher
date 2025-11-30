@tool
extends RefCounted

## Loading and saving of Twitch rewards

class_name TwitchRewardService

static var _log: TwitchLogger = TwitchLogger.new("TwitchRewardService")

var api: TwitchAPI
var media_loader: TwitchMediaLoader

enum LoadError {
	## All fine
	OK,
	## When the reward has no id to load
	NO_ID_AVAILABLE,
	## When there is no reward on Twitch side
	NO_REWARD_FOUND
}

enum SaveError {
	## All fine
	OK,
	## When the reward was created by another application
	REWARD_NOT_OWNED,
	## Something unexpected happend during save
	UNKNOWN
}

enum DeleteError {
	## All fine
	OK,
	## The reward to delete didn't had an ID maybe was new reward?
	NO_ID,
	## The reward had no broadcaster user saved to it.
	NO_BROADCASTER_USER
}


func _init(twitch_api: TwitchAPI, twitch_media_loader: TwitchMediaLoader) -> void:
	api = twitch_api
	media_loader = twitch_media_loader


## Loads the reward data inplace from Twitch.
func load_reward(twitch_reward: TwitchReward) -> LoadError:
	if twitch_reward.id == "":
		_log.e("Can't load %s it has no ID to load" % twitch_reward.title)
		return LoadError.NO_ID_AVAILABLE
		
	var reward: TwitchCustomReward = await _get_custom_reward(twitch_reward)
	if reward == null: return LoadError.NO_REWARD_FOUND
	_convert_twitch_reward(twitch_reward, reward)
	
	_log.i("Loaded '%s' from Twitch" % twitch_reward.title)
	return LoadError.OK
	
	
func _convert_twitch_reward(twitch_reward: TwitchReward, reward: TwitchCustomReward) -> void:
	twitch_reward.id = reward.id
	twitch_reward.title = reward.title
	twitch_reward.description = reward.prompt
	twitch_reward.cost = reward.cost
	twitch_reward.background_color = Color.html(reward.background_color)
	twitch_reward.is_enabled = reward.is_enabled
	twitch_reward.is_user_input_required = reward.is_user_input_required
	twitch_reward.is_max_per_stream_enabled = reward.max_per_stream_setting.is_enabled
	twitch_reward.max_per_stream = reward.max_per_stream_setting.max_per_stream
	twitch_reward.is_max_per_user_per_stream_enabled = reward.max_per_user_per_stream_setting.is_enabled
	twitch_reward.max_per_user_per_stream = reward.max_per_user_per_stream_setting.max_per_user_per_stream
	twitch_reward.is_global_cooldown_enabled = reward.global_cooldown_setting.is_enabled
	twitch_reward.global_cooldown_seconds = reward.global_cooldown_setting.global_cooldown_seconds
	twitch_reward.is_paused = reward.is_paused
	twitch_reward.should_redemptions_skip_request_queue = reward.should_redemptions_skip_request_queue
	twitch_reward.emit_changed()
	

## Tries to create or update an existing reward.
func save_reward(twitch_reward: TwitchReward) -> SaveError:
	# The reward got deleted via UI
	if twitch_reward.id != "":
		if await _get_custom_reward(twitch_reward) == null:
			twitch_reward.id = ""
	
	if twitch_reward.id == "":
		var create: TwitchCreateCustomRewards.Body = TwitchCreateCustomRewards.Body.new()
		create.title = twitch_reward.title
		create.prompt = twitch_reward.description
		create.cost = twitch_reward.cost
		var color: String = twitch_reward.background_color.to_html(false)
		if color: create.background_color = "#" + color
		create.is_enabled = twitch_reward.is_enabled
		create.is_user_input_required = twitch_reward.is_user_input_required
		create.is_max_per_stream_enabled = twitch_reward.is_max_per_stream_enabled
		create.max_per_stream = twitch_reward.max_per_stream
		create.max_per_user_per_stream = twitch_reward.max_per_user_per_stream
		create.is_max_per_user_per_stream_enabled = twitch_reward.is_max_per_user_per_stream_enabled
		create.is_global_cooldown_enabled = twitch_reward.is_global_cooldown_enabled
		create.global_cooldown_seconds = twitch_reward.global_cooldown_seconds
		create.should_redemptions_skip_request_queue = twitch_reward.should_redemptions_skip_request_queue
		if not twitch_reward.broadcaster_user:
			var current_user: TwitchUser = await TwitchService.get_current_user_via_api(api)
			twitch_reward.broadcaster_user = current_user
		
		var response = await api.create_custom_rewards(create, twitch_reward.broadcaster_user.id)
		if response.response.response_code == 200:
			var saved_reward: TwitchCustomReward = response.data[0]
			twitch_reward.id = saved_reward.id 
			ResourceSaver.save(twitch_reward)
			twitch_reward.emit_changed()
			_log.i("Saved the reward %s" % twitch_reward.title)
			return SaveError.OK
		else:
			return SaveError.UNKNOWN
	else:
		var update: TwitchUpdateCustomReward.Body = TwitchUpdateCustomReward.Body.new()
		update.title = twitch_reward.title
		update.prompt = twitch_reward.description
		update.cost = twitch_reward.cost
		var color: String = twitch_reward.background_color.to_html(false)
		if color: update.background_color = "#" + color
		update.is_enabled = twitch_reward.is_enabled
		update.is_user_input_required = twitch_reward.is_user_input_required
		update.is_max_per_stream_enabled = twitch_reward.is_max_per_stream_enabled
		update.max_per_stream = twitch_reward.max_per_stream
		update.max_per_user_per_stream = twitch_reward.max_per_user_per_stream
		update.is_max_per_user_per_stream_enabled = twitch_reward.is_max_per_user_per_stream_enabled
		update.is_global_cooldown_enabled = twitch_reward.is_global_cooldown_enabled
		update.global_cooldown_seconds = twitch_reward.global_cooldown_seconds
		update.should_redemptions_skip_request_queue = twitch_reward.should_redemptions_skip_request_queue
		update.is_paused = twitch_reward.is_paused
		var response = await api.update_custom_reward(update, twitch_reward.id, twitch_reward.broadcaster_user.id)
		if response.response.response_code == 403:
			_log.e("You can only update custom rewards from the application that created it in the first place.")
			return SaveError.REWARD_NOT_OWNED
		else:
			_log.i("Updated the reward %s" % twitch_reward.title)
			return SaveError.OK


## Deletes a reward on Twitch side. Will also remove the ID when succesfully.
func delete_reward(twitch_reward: TwitchReward) -> DeleteError:
	if not twitch_reward.id: 
		_log.e("Can't delete reward has not id %s" % twitch_reward.title)
		return DeleteError.NO_ID
	if not twitch_reward.broadcaster_user: 
		_log.e("Can't delete reward has not broadcaster %s" % twitch_reward.title)
		return DeleteError.NO_BROADCASTER_USER
	var response: BufferedHTTPClient.ResponseData = await api.delete_custom_reward(twitch_reward.id, twitch_reward.broadcaster_user.id)
	if response.response_code <= 300:
		_reset_reward(twitch_reward)
	else:
		var error_message: String = response.response_data.get_string_from_utf8()
		push_error("Couldn't delete! Twitch Response (%s): %s" % [response.response_code, error_message])
		
	return DeleteError.OK


func _reset_reward(twitch_reward: TwitchReward) -> void:
	twitch_reward.id = ""
	ResourceSaver.save(twitch_reward)
	twitch_reward.emit_changed()


func _get_custom_reward(twitch_reward: TwitchReward) -> TwitchCustomReward:
	if twitch_reward.id == "": 
		return null
	var opt: TwitchGetCustomReward.Opt = TwitchGetCustomReward.Opt.create()
	opt.id = [twitch_reward.id]
	var reward_response = await api.get_custom_reward(opt, twitch_reward.broadcaster_user.id)
	if reward_response.data.is_empty(): 
		var msg: String = "Can't load Twitch reward %s with id %s from Twitch. It doesn't exist!" % [twitch_reward.title, twitch_reward.id]
		_reset_reward(twitch_reward)
		_log.e(msg)
		if Engine.is_editor_hint():
			EditorInterface.get_editor_toaster().push_toast(msg, EditorToaster.SEVERITY_WARNING)
		return null
	return reward_response.data[0]
