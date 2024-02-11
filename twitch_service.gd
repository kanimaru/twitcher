extends Node
## Access to the Twitch API. Combines all the stuff the library provides.
## Makes some actions easier to use.

## Send when the Twitch API was succesfully initialized
signal twitch_ready;

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_SERVICE)

var auth: TwitchAuth;
var icon_loader: TwitchIconLoader;
var irc: TwitchIRC;
var eventsub: TwitchEventsub;
var eventsub_debug: TwitchEventsub;
var commands: TwitchCommandHandler;
var cheer_repository: TwitchCheerRepository;
var api: TwitchRestAPI

var is_twitch_ready: bool;

func _init() -> void:
	log.i("Init")
	TwitchSetting.setup();

func setup() -> void:
	log.i("Setup")
	auth = TwitchAuth.new();
	api = TwitchRestAPI.new(auth);
	icon_loader = TwitchIconLoader.new(api);
	eventsub = TwitchEventsub.new(api);
	eventsub_debug = TwitchEventsub.new(api);
	if TwitchSetting.use_test_server:
		eventsub_debug.connect_to_eventsub(TwitchSetting.eventsub_test_server_url);
	commands = TwitchCommandHandler.new();
	irc = TwitchIRC.new(auth);

	log.i("Start")
	await auth.ensure_authentication();
	await _init_chat();
	_init_eventsub();
	_init_cheermotes();
	log.i("Initialized and ready")
	is_twitch_ready = true;
	twitch_ready.emit();

func is_ready() -> void:
	if !is_twitch_ready: await twitch_ready;

#region User
func get_user_by_id(user_id: String) -> TwitchUser:
	if user_id == null || user_id == "": return null;
	var user_data : TwitchGetUsersResponse = await api.get_users([user_id], []);
	if user_data.data.is_empty(): return null;
	return user_data.data[0];

func get_user(username: String) -> TwitchUser:
	var user_data : TwitchGetUsersResponse = await api.get_users([], [username]);
	return user_data.data[0];

func load_profile_image(user: TwitchUser) -> ImageTexture:
	if user == null: return TwitchSetting.fallback_profile;
	if(ResourceLoader.has_cached(user.profile_image_url)):
		return ResourceLoader.load(user.profile_image_url);
	var client : BufferedHTTPClient = HttpClientManager.get_client(TwitchSetting.twitch_image_cdn_host);
	var request := client.request(user.profile_image_url, HTTPClient.METHOD_GET, BufferedHTTPClient.HEADERS, "")
	var response_data := await client.wait_for_request(request);
	var texture : ImageTexture = ImageTexture.new();
	var response = response_data.response_data;
	if !response.is_empty():
		var img := Image.new();
		var content_type = HttpUtil.get_header(response_data.client.get_response_headers(), "Content-Type")

		match content_type:
			"image/png": img.load_png_from_buffer(response);
			"image/jpeg": img.load_jpg_from_buffer(response);
			_: return TwitchSetting.fallback_profile;
		texture.set_image(img);
	else:
		# Don't use `texture = TwitchSetting.fallback_profile` as texture cause the path will be taken over
		# for caching purpose!
		texture.set_image(TwitchSetting.fallback_profile.get_image());
	texture.take_over_path(user.profile_image_url);
	return texture;

#endregion
#region EventSub

func _init_eventsub() -> void:
	eventsub.connect_to_eventsub(TwitchSetting.eventsub_live_server_url);

func wait_for_connection() -> void:
	await eventsub.wait_for_connection();

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
	var body = TwitchSendChatAnnouncementBody.new();
	body.message = message;
	body.color = color.value;
	api.send_chat_announcement(broadcaster_id, body);

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
