extends Node

signal twitch_ready;

var auth: TwitchAuth;
var repository: TwitchRepository;
var icon_loader: TwitchIconLoader;
var irc: TwitchIRC;
var eventsub: TwitchEventsub;
var eventsub_debug: TwitchEventsub;
var commands: TwitchCommandHandler;
var cheer_repository: TwitchCheerRepository;
var api: TwitchRestAPI
var reward_map: Dictionary;

var is_twitch_ready: bool;
var debug: bool :
	set(val):
		if val: eventsub_debug.connect_to_eventsub(TwitchSetting.eventsub_test_server_url);
		else: eventsub_debug.connect_to_eventsub(TwitchSetting.eventsub_test_server_url);

func _init() -> void:
	print("Twitch Service: init")
	TwitchSetting.setup();

func setup() -> void:
	print("Twitch Service: setup")
	auth = TwitchAuth.new();
	repository = TwitchRepository.new(auth);
	api = TwitchRestAPI.new(repository);
	icon_loader = TwitchIconLoader.new(api);
	eventsub = TwitchEventsub.new(api);
	eventsub_debug = TwitchEventsub.new(api);
	commands = TwitchCommandHandler.new();
	irc = TwitchIRC.new(auth);

	print("Twitch Service: start")
	await auth.ensure_authentication();
	await _init_chat();
	_init_eventsub();
	_init_custom_rewards();
	_init_cheermotes();
	print("Twitch Service: initialized")
	is_twitch_ready = true;
	twitch_ready.emit();

func is_ready() -> void:
	if !is_twitch_ready: await twitch_ready;

#region User
func get_user_by_id(user_id: String) -> TwitchUser:
	if user_id == null || user_id == "": return null;
	var user_data := await api.get_users([], [user_id]);
	if user_data['data'].is_empty(): return null;
	return TwitchUser.from_json(user_data['data'][0]);

func get_user(username: String) -> TwitchUser:
	var user_data := await api.get_users([username], []);
	return TwitchUser.from_json(user_data['data'][0]);

func load_profile_image(user: TwitchUser) -> ImageTexture:
	return await repository.load_image(user);

#endregion
#region EventSub

func _init_eventsub() -> void:
	eventsub.connect_to_eventsub(TwitchSetting.eventsub_live_server_url);

func wait_for_connection() -> void:
	await eventsub.wait_for_connection();

#endregion
#region CustomRewards

func _init_custom_rewards():
	_load_rewards();

func get_reward(reward_id: String) -> TwitchCustomRewardResource:
	if reward_map.has(reward_id):
		return reward_map[reward_id];
	return null;

func _load_rewards() -> void:
	var all_rewards = await TwitchService.get_custom_rewards();
	var reward_definition_paths := DirAccess.get_files_at("res://rewards/");
	for path in reward_definition_paths:
		path = path.trim_suffix(".remap");
		print("Load Reward %s " % [ path ]);

		var reward = load("res://rewards/" + path) as TwitchCustomRewardResource;
		var rewards_data = all_rewards.filter(func(r): return r.title == reward.title);
		if rewards_data.is_empty():
			var id = await add_custom_reward(reward.title, reward.cost, reward.prompt, reward.input_required, reward.enabled);
			reward.id = id;
		elif reward.is_dirty(rewards_data[0]):
			reward.id = rewards_data[0]['id'];
			update_custom_reward(reward.id, reward.title, reward.cost, reward.prompt, reward.input_required, reward.enabled, reward.pause, reward.auto_complete);
		else: reward.id = rewards_data[0]['id'];
		print("Reward %s for %s is loaded " % [ reward.id, path ]);
		reward_map[reward.id] = reward;

func get_custom_rewards(only_manageable_rewards: bool = false) -> Array:
	var response = await api.get_custom_reward([], only_manageable_rewards);
	if response.has("data"):
		return response['data'];
	return [];

func toggle_enable_custom_reward(id: String) -> void:
	var rewardDto = TwitchModifyRewardDto.new();
	rewardDto.is_enabled = true;
	repository.modify_custom_reward(id, rewardDto);

func toggle_pause_custom_reward(id: String) -> void:
	var rewardDto = TwitchModifyRewardDto.new();
	rewardDto.is_paused = true;
	repository.modify_custom_reward(id, rewardDto);

func update_custom_reward(id: String, title: String, cost: int, prompt: String, is_input_required: bool, enabled: bool, paused: bool, auto_complete: bool) -> void:
	var rewardDto = TwitchModifyRewardDto.new();
	rewardDto.cost = cost;
	rewardDto.title = title;
	rewardDto.prompt = prompt;
	rewardDto.is_user_input_required = is_input_required;
	rewardDto.is_enabled = enabled;
	rewardDto.is_paused = paused;
	rewardDto.should_redemptions_skip_request_queue = auto_complete;
	repository.modify_custom_reward(id, rewardDto);

func add_custom_reward(title: String, cost: int, prompt: String, is_input_required: bool, enabled: bool = true, auto_complete: bool = false) -> String:
	var reward = TwitchCreateRewardDto.new(title, cost);
	reward.prompt = prompt;
	reward.is_enabled = enabled;
	reward.is_user_input_required = is_input_required;
	reward.should_redemptions_skip_request_queue = auto_complete;
	var response = await repository.add_custom_reward(reward);
	return response['data'][0]['id'];

func remove_custom_reward(id: String) -> void: repository.remove_custom_reward(id);

func complete_redemption(redemption_id: String, reward_id: String) -> void:
	repository.update_redemtion(redemption_id, reward_id, TwitchRepository.STATUS_FULLFILLED);

func cancel_redemption(redemption_id: String, reward_id: String) -> void:
	repository.update_redemtion(redemption_id, reward_id, TwitchRepository.STATUS_CANCELED);

#endregion
#region Chat

func _init_chat() -> void:
	irc.chat_message.connect(commands.handle_command.bind(false))
	irc.whisper_message.connect(commands.handle_command.bind(true))
	irc.connect_to_irc();
	icon_loader.do_preload();
	await icon_loader.preload_done;

func get_channel(channel_name) -> TwitchChannel:
	return irc.get_channel(channel_name);

func shoutout(user_id: String) -> void:
	api.send_a_shoutout(TwitchSetting.broadcaster_id, user_id, TwitchSetting.broadcaster_id)

func announcment(message: String, color: TwitchAnnouncementColor = TwitchAnnouncementColor.PRIMARY):
	var broadcaster_id = TwitchSetting.broadcaster_id;
	api.send_chat_announcement(broadcaster_id, {
		"message": message,
		"color": color.value
	})

func add_command(command: String, callback: Callable, args_min: int, args_max: int) -> void:
	commands.add_command(command, callback, args_min, args_max);

func remove_command(command: String) -> void:
	commands.remove_command(command);

func chat(message: String) -> void:
	irc.chat(message);

func get_emotes_data(channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_cached_emotes(channel_id);

func get_badges_data(channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_cached_badges(channel_id);

func get_emotes(id: Array[String]) -> Dictionary:
	return await icon_loader.get_emotes(id);

func get_badges(badge: Array[String], channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_badges(badge, channel_id);

#endregion
#region Cheermotes

func _init_cheermotes() -> void:
	cheer_repository = await TwitchCheerRepository.new(api);

func get_cheermote_data() -> Array[TwitchCheerRepository.CheerData]:
	await cheer_repository.wait_is_ready();
	return cheer_repository.data;

func get_cheer_tier(cheer_word: String) -> TwitchCheerRepository.CheerTier:
	return cheer_repository.get_cheer_tier(cheer_word);

func is_cheermote_prefix_existing(prefix: String) -> bool:
	return cheer_repository.is_cheermote_prefix_existing(prefix);

func get_cheermotes(cheer_tier: Array[TwitchCheerRepository.CheerTier], theme: String, type: String, scale: String) -> Dictionary:
	return await cheer_repository.get_cheermotes(cheer_tier, theme, type, scale);

#endregion
