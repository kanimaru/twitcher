extends RefCounted
## Access to the Twitch API. Combines all the stuff the library provides.
## Makes some actions easier to use.

class_name TwitchService

static var log: TwitchLogger;
static var auth: TwitchAuth;
static var icon_loader: TwitchIconLoader;
static var irc: TwitchIRC;
static var eventsub: TwitchEventsub;
static var eventsub_debug: TwitchEventsub;
static var commands: TwitchCommandHandler;
static var cheer_repository: TwitchCheerRepository;
static var api: TwitchRestAPI

static func _static_init() -> void:
	# Setup Twitch setting before it is needed
	TwitchSetting.setup();
	log = TwitchLogger.new(TwitchSetting.LOGGER_NAME_SERVICE);
	log.i("Setup")
	auth = await TwitchAuth.new();
	api = TwitchRestAPI.new(auth);
	icon_loader = TwitchIconLoader.new(api);
	eventsub = TwitchEventsub.new(api);
	eventsub_debug = TwitchEventsub.new(api, false);
	commands = TwitchCommandHandler.new();
	irc = TwitchIRC.new(auth);

## Call this to setup the complete Twitch integration whenever you need.
## It boots everything up this Lib supports.
static func setup() -> void:
	log.i("Start")
	await auth.ensure_authentication();
	await _init_chat();
	_init_eventsub();
	if TwitchSetting.use_test_server:
		eventsub_debug.connect_to_eventsub(TwitchSetting.eventsub_test_server_url);
	_init_cheermotes();
	log.i("Initialized and ready")

#
# Convinient Methods
#

#region User

## Get data about a user by USER_ID see get_user for by username
static func get_user_by_id(user_id: String) -> TwitchUser:
	if user_id == null || user_id == "": return null;
	var user_data : TwitchGetUsersResponse = await api.get_users([user_id], []);
	if user_data.data.is_empty(): return null;
	return user_data.data[0];

## Get data about a user by USERNAME see get_user_by_id for by user_id
static func get_user(username: String) -> TwitchUser:
	var user_data : TwitchGetUsersResponse = await api.get_users([], [username]);
	if user_data.data.is_empty():
		printerr("Username was not found: %s" % username);
		return null;
	return user_data.data[0];

## Get the image of an user
static func load_profile_image(user: TwitchUser) -> ImageTexture:
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
		var content_type = response_data.response_header["Content-Type"];

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

static func _init_eventsub() -> void:
	eventsub.connect_to_eventsub(TwitchSetting.eventsub_live_server_url);

## Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
## which API versions are available and which conditions are required.
static func subscribe_event(event_name : String, version : String, conditions : Dictionary, session_id: String):
	eventsub.subscribe_event(event_name, version, conditions, session_id)

## Waits for connection to eventsub. Eventsub is ready to subscribe events.
static func wait_for_connection() -> void:
	await eventsub.wait_for_connection();

#endregion

#region Chat

## Initializes the chat connects to IRC and preloads everything
static func _init_chat() -> void:
	irc.received_privmsg.connect(commands.handle_chat_command);
	irc.received_whisper.connect(commands.handle_whisper_command);
	irc.connect_to_irc();
	icon_loader.do_preload();
	await icon_loader.preload_done;

## Sends out a shoutout to a specific user
static func shoutout(user: TwitchUser) -> void:
	api.send_a_shoutout(TwitchSetting.broadcaster_id, user.id, TwitchSetting.broadcaster_id)

## Sends a announcement message to the chat
static func announcment(message: String, color: TwitchAnnouncementColor = TwitchAnnouncementColor.PRIMARY):
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var body = TwitchSendChatAnnouncementBody.new();
	body.message = message;
	body.color = color.value;
	api.send_chat_announcement(broadcaster_id, body);

## Add a new command handler and register it for a command.
## The callback will receive [code]info: TwitchCommandInfo, args: Array[String][/code][br]
## Args are optional depending on the configuration.[br]
## args_max == -1 => no upper limit for arguments
static func add_command(command: String, callback: Callable, args_min: int = 0, args_max: int = -1,
	permission_level : TwitchCommandHandler.PermissionFlag = TwitchCommandHandler.PermissionFlag.EVERYONE,
	where : TwitchCommandHandler.WhereFlag = TwitchCommandHandler.WhereFlag.CHAT) -> void:

	log.i("Register command %s" % command)
	commands.add_command(command, callback, args_min, args_max, permission_level, where);

## Removes a command
static func remove_command(command: String) -> void:
	log.i("Remove command %s" % command)
	commands.remove_command(command);

## Sends a chat to the only connected channel or in case of multiple channels doesn't do anything see
## join_channel to get a specific channel to send to it.
static func chat(message: String, channel_name: String = "") -> void:
	irc.chat(message, channel_name);

## Whispers to another user.
## @deprecated not supported by twitch anymore
static func whisper(message: String, username: String) -> void:
	log.e("Whipser from bots aren't supported by Twitch anymore. See https://dev.twitch.tv/docs/irc/chat-commands/ at /w")

## Returns the definition of emotes for given channel or for the global emotes.
## Key: EmoteID as String ; Value: TwitchGlobalEmote | TwitchChannelEmote
static func get_emotes_data(channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_cached_emotes(channel_id);

## Returns the definition of badges for given channel or for the global bages.
## Key: category / versions / badge_id ; Value: TwitchChatBadge
static func get_badges_data(channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_cached_badges(channel_id);

## Gets the requested emotes.
## Key: EmoteID as String ; Value: SpriteFrame
static func get_emotes(ids: Array[String]) -> Dictionary:
	return await icon_loader.get_emotes(ids);

## Gets the requested emotes in the specified theme, scale and type.
## Loads from cache if possible otherwise downloads and transforms them.
## Key: TwitchEmoteDefinition ; Value SpriteFrames
static func get_emotes_by_definition(emotes: Array[TwitchEmoteDefinition]) -> Dictionary:
	return await icon_loader.get_emotes_by_definition(emotes);

## Get the requested badges. (valid scale values are 1,2,3)
## Loads from cache if possible otherwise downloads and transforms them.
## Key: Badge Composite ; Value: SpriteFrames
static func get_badges(badge: Array[String], channel_id: String = "global", scale: int = 1) -> Dictionary:
	return await icon_loader.get_badges(badge, channel_id);

#endregion
#region Cheermotes

static func _init_cheermotes() -> void:
	cheer_repository = await TwitchCheerRepository.new(api);

## Returns the complete parsed data out of a cheer word.
static func get_cheer_tier(cheer_word: String,
	theme: TwitchCheerRepository.Themes = TwitchCheerRepository.Themes.DARK,
	type: TwitchCheerRepository.Types = TwitchCheerRepository.Types.ANIMATED,
	scale: TwitchCheerRepository.Scales = TwitchCheerRepository.Scales._1) -> TwitchCheerRepository.CheerResult:
	return await cheer_repository.get_cheer_tier(cheer_word, theme, type, scale);

## Returns the data of the Cheermotes.
static func get_cheermote_data() -> Array[TwitchCheermote]:
	await cheer_repository.wait_is_ready();
	return cheer_repository.data;

## Checks if a prefix is existing.
static func is_cheermote_prefix_existing(prefix: String) -> bool:
	return cheer_repository.is_cheermote_prefix_existing(prefix);

## Returns all cheertiers in form of:
## Key: TwitchCheermote.Tiers ; Value: SpriteFrames
static func get_cheermotes(cheermote: TwitchCheermote,
	theme: TwitchCheerRepository.Themes = TwitchCheerRepository.Themes.DARK,
	type: TwitchCheerRepository.Types = TwitchCheerRepository.Types.ANIMATED,
	scale: TwitchCheerRepository.Scales = TwitchCheerRepository.Scales._1) -> Dictionary:
	return await cheer_repository.get_cheermotes(cheermote, theme, type, scale);

#endregion
