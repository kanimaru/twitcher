@icon("res://addons/twitcher/assets/service-icon.svg")
@tool
extends Twitcher

## Access to the Twitch API. Combines all the stuff the library provides.
## Makes some actions easier to use.
class_name TwitchService

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
## When the poll doesn't end after the offical endtime + POLL_TIMEOUT_MS. The wait loop for poll end 
## event will be stopped to prevent endless loops.
const POLL_TIMEOUT_MS: int = 30000

static var _log: TwitchLogger = TwitchLogger.new("TwitchService")

static var instance: TwitchService

@export var oauth_setting: OAuthSetting:
	set(val):
		if oauth_setting != null:
			oauth_setting.changed.disconnect(update_configuration_warnings)
		oauth_setting = val
		if val != null:
			oauth_setting.changed.connect(update_configuration_warnings)
			_set_in_child("oauth_setting", val)
		update_configuration_warnings()
@export var scopes: OAuthScopes:
	set(val):
		scopes = val
		if val != null:
			_set_in_child("scopes", val)
			update_configuration_warnings()
@export var token: OAuthToken:
	set(val):
		token = val
		if val != null:
			_set_in_child("token", val)
			update_configuration_warnings()

@onready var auth: TwitchAuth
@onready var eventsub: TwitchEventsub
@onready var api: TwitchAPI
@onready var irc: TwitchIRC
@onready var media_loader: TwitchMediaLoader

var _user_cache: Dictionary[String, TwitchUser] = {}

## Cache for the current user so that no roundtrip has to be done every time get_current_user will be called
var _current_user: TwitchUser

var _commands: Dictionary[String, TwitchCommand] = {}

func _init() -> void:
	child_entered_tree.connect(_on_child_entered)
	child_exiting_tree.connect(_on_child_exiting)


func _ready() -> void:
	_log.d("is ready")
	if not is_instance_valid(token): token = TwitchEditorSettings.game_oauth_token
	if not is_instance_valid(oauth_setting): oauth_setting = TwitchEditorSettings.game_oauth_setting


func _enter_tree() -> void:
	if instance == null: instance = self
	
	
func _exit_tree() -> void:
	if instance == self: instance = null
	

func _on_child_entered(node: Node) -> void:
	if node is TwitchAuth: auth = node
	if node is TwitchAPI: api = node
	if node is TwitchEventsub: eventsub = node
	if node is TwitchIRC: irc = node
	if node is TwitchMediaLoader: media_loader = node

	if "token" in node && token != null:
		node.token = token
	if "scopes" in node && scopes != null:
		node.scopes = scopes
	if "oauth_setting" in node && oauth_setting != null:
		node.oauth_setting = oauth_setting
	if node.has_signal(&"unauthenticated"):
		node.unauthenticated.connect(_on_unauthenticated)
	update_configuration_warnings()


func _set_in_child(property: String, value: Variant) -> void:
	for child in get_children():
		if property in child: child[property] = value


func _on_child_exiting(node: Node) -> void:
	if node is TwitchAuth: auth = null
	if node is TwitchAPI: api = null
	if node is TwitchEventsub: eventsub = null
	if node is TwitchIRC: irc = null
	if node is TwitchMediaLoader: media_loader = null
	
	if node.has_signal(&"unauthenticated"):
		node.unauthenticated.disconnect(_on_unauthenticated)
	update_configuration_warnings()


## Call this to setup the complete Twitch integration whenever you need.
## It boots everything up this Lib supports.
func setup() -> bool:
	if is_instance_valid(auth): 
		if not await auth.authorize(): return false
	else:
		push_error("Authorization Node got removed, can't setup twitch service")
		return false
	await propagate_call(&"do_setup")
	for child in get_children():
		if child.has_method(&"wait_setup"):
			await child.wait_setup()

	_log.i("TwitchService setup")
	return true

## Checks if the correctly setup
func is_configured() -> bool:
	return _get_configuration_warnings().is_empty()


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if oauth_setting == null:
		result.append("OAuthSetting Resource is missing")
	else:
		var oauth_setting_problems : PackedStringArray = oauth_setting.get_valididation_problems()
		if not oauth_setting_problems.is_empty():
			result.append("OAuthSetting Resource is invalid")
			result.append_array(oauth_setting_problems)
	if scopes == null:
		result.append("OAuthScopes Resource is missing")
	if token == null:
		result.append("OAuthToken Resource is missing")
	return result


func _on_unauthenticated() -> void:
	auth.authorize()

#
# Convinient Proxy Methods
#
#region User


## Get data about a user by USER_ID see get_user for by username
func get_user_by_id(user_id: String) -> TwitchUser:
	if _user_cache.has(user_id): return _user_cache[user_id]
	if api == null:
		_log.e("Please setup a TwitchAPI Node into TwitchService.")
		return null
	if user_id == null || user_id == "": return null
	var opt = TwitchGetUsers.Opt.new()
	opt.id = [user_id] as Array[String]
	var user_data : TwitchGetUsers.Response = await api.get_users(opt)
	if user_data.data.is_empty(): return null
	var user: TwitchUser = user_data.data[0]
	_user_cache[user_id] = user
	return user


## Get data about a user by USERNAME see get_user_by_id for by user_id
func get_user(username: String) -> TwitchUser:
	username = username.trim_prefix("@")
	if _user_cache.has(username): return _user_cache[username]
	if api == null:
		_log.e("Please setup a TwitchAPI Node into TwitchService.")
		return null
	var opt = TwitchGetUsers.Opt.new()
	opt.login = [username] as Array[String]
	var user_data : TwitchGetUsers.Response = await api.get_users(opt)
	if user_data.data.is_empty():
		_log.e("Username was not found: %s" % username)
		return null
	var user: TwitchUser = user_data.data[0]
	_user_cache[username] = user
	return user



## Get data about a currently authenticated user (caches the value)
func get_current_user() -> TwitchUser:
	if _current_user != null:
		return _current_user
		
	if api == null:
		_log.e("Please setup a TwitchAPI Node into TwitchService.")
		return null
		
	var user_data : TwitchGetUsers.Response = await api.get_users(null)
	_current_user = user_data.data[0]
	return _current_user

## Get the image of an user
func load_profile_image(user: TwitchUser) -> ImageTexture:
	return await media_loader.load_profile_image(user)

#endregion
#region EventSub


## Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
## which API versions are available and which conditions are required.
func subscribe_event(definition: TwitchEventsubDefinition, conditions: Dictionary) -> TwitchEventsubConfig:
	if definition == null:
		_log.e("TwitchEventsubDefinition is null")
		return

	var config = TwitchEventsubConfig.create(definition, conditions)
	await eventsub.subscribe(config)
	return config


## Waits for connection to eventsub. Eventsub is ready to subscribe events.
func wait_for_eventsub_connection() -> void:
	if eventsub == null:
		_log.e("TwitchEventsub Node is missing")
		return
	await eventsub.wait_for_connection()


## Returns all of the eventsub subscriptions (variable is a copy so you can freely modify it)
func get_subscriptions() -> Array[TwitchEventsubConfig]:
	if eventsub == null:
		_log.e("TwitchEventsub Node is missing")
		return []
	return eventsub.get_subscriptions()

#endregion

#region Chat

func chat(message: String, broadcaster: TwitchUser = null, sender: TwitchUser = null) -> void:
	var current_user = await get_current_user()
	if not sender:
		if not current_user: return
		sender = current_user
	if not broadcaster: 
		if not current_user: return
		broadcaster = current_user
	var body = TwitchSendChatMessage.Body.create(broadcaster.id, sender.id, message)
	api.send_chat_message(body)


## Sends out a shoutout to a specific user
func shoutout(user: TwitchUser, broadcaster: TwitchUser = null, moderator: TwitchUser = null) -> void:
	var current_user: TwitchUser = await get_current_user()
	
	if not broadcaster:
		if not current_user: return
		broadcaster = current_user
		
	if not moderator:
		if not current_user: return
		moderator = current_user
	api.send_a_shoutout(broadcaster.id, moderator.id, user.id)


## Sends a announcement message to the chat
func announcment(message: String, color: TwitchAnnouncementColor = TwitchAnnouncementColor.PRIMARY, broadcaster: TwitchUser = null, moderator: TwitchUser = null):
	var current_user: TwitchUser = await get_current_user()
	if not broadcaster:
		if not current_user: return
		broadcaster = current_user
	
	if not moderator:
		if not current_user: return
		moderator = current_user
	
	var body = TwitchSendChatAnnouncement.Body.new()
	body.message = message
	body.color = color.value
	api.send_chat_announcement(body, moderator.id, broadcaster.id)


## Add a new command handler and register it for a command.
## The callback will receive [code]from_username: String, info: TwitchCommandInfo, args: PackedStringArray[/code][br]
## Args are optional depending on the configuration.[br]
## args_max == -1 => no upper limit for arguments
func add_command(command: String, callback: Callable, args_min: int = 0, args_max: int = -1,
	permission_level : TwitchCommand.PermissionFlag = TwitchCommand.PermissionFlag.EVERYONE,
	where : TwitchCommand.WhereFlag = TwitchCommand.WhereFlag.CHAT) -> TwitchCommand:
	var command_node = TwitchCommand.new()
	command_node.command = command
	command_node.command_received.connect(callback) 
	command_node.args_min = args_min
	command_node.args_max = args_max
	command_node.permission_level = permission_level
	command_node.where = where
	add_child(command_node)
	_log.i("Register command %s" % command)
	return command_node


## Removes a command
func remove_command(command: String) -> void:
	_log.i("Remove command %s" % command)
	var command_node: TwitchCommand = _commands.get(command, null)
	if command_node != null:
		command_node.queue_free()
		_commands.erase(command)


## Whispers to another user.
## @deprecated not supported by twitch anymore
func whisper(message: String, username: String) -> void:
	_log.e("Whipser from bots aren't supported by Twitch anymore. See https://dev.twitch.tv/docs/irc/chat-commands/ at /w")


## Returns the definition of emotes for given channel or for the global emotes.
## Key: EmoteID as String | Value: TwitchGlobalEmote / TwitchChannelEmote
func get_emotes_data(channel_id: String = "global") -> Dictionary:
	return await media_loader.get_cached_emotes(channel_id)


## Returns the definition of badges for given channel or for the global bages.
## Key: category / versions / badge_id | Value: TwitchChatBadge
func get_badges_data(channel_id: String = "global") -> Dictionary[String, TwitchChatBadge]:
	return await media_loader.get_cached_badges(channel_id)


## Gets the requested emotes.
## Key: EmoteID as String | Value: SpriteFrame
func get_emotes(ids: Array[String]) -> Dictionary[String, SpriteFrames]:
	return await media_loader.get_emotes(ids)


## Gets the requested emotes in the specified theme, scale and type.
## Loads from cache if possible otherwise downloads and transforms them.
## Key: TwitchEmoteDefinition | Value SpriteFrames
func get_emotes_by_definition(emotes: Array[TwitchEmoteDefinition]) -> Dictionary[TwitchEmoteDefinition, SpriteFrames]:
	return await media_loader.get_emotes_by_definition(emotes)


func poll(title: String, choices: Array[String], duration: int = 60, channel_points_voting_enabled: bool = false, channel_points_per_vote: int = 1000, broadcaster_id: String = "") -> Dictionary:
	if broadcaster_id == "": broadcaster_id = _current_user.id
	var body_choices: Array[TwitchCreatePoll.BodyChoices] = []
	for choice: String in choices:
		var body_choice = TwitchCreatePoll.BodyChoices.create(choice)
		body_choices.append(body_choice)
	duration = clamp(duration, 15, 1800)
	var poll_body: TwitchCreatePoll.Body = TwitchCreatePoll.Body.create(broadcaster_id, title, body_choices, duration)
	if channel_points_voting_enabled:
		poll_body.channel_points_per_vote = channel_points_per_vote
		poll_body.channel_points_voting_enabled = channel_points_voting_enabled
	var poll_response: TwitchCreatePoll.Response = await api.create_poll(poll_body)
	if poll_response.response.response_code != 200:
		var error_message: String = poll_response.response.response_data.get_string_from_utf8()
		push_error("Can't create poll response cause of ", error_message)
		return {}
	var poll: TwitchPoll = poll_response.data[0]
	var poll_end_time: int = Time.get_ticks_msec() + duration * 1000 + POLL_TIMEOUT_MS
	var event: TwitchEventsub.Event
	if eventsub && eventsub.has_subscription(TwitchEventsubDefinition.CHANNEL_POLL_END, {&"broadcaster_user_id": broadcaster_id}):
		var poll_ended: bool
		while not poll_ended:
			if poll_end_time < Time.get_ticks_msec():
				return {}
			event = await eventsub.event_received
			if event.type != TwitchEventsubDefinition.CHANNEL_POLL_END: continue
			if event.data[&"id"] != poll.id: continue
			break
	else:
		_log.i("Can't wait for poll end. Either eventsub is not set ot it is not listenting to ending polls")
		return {}
	return event.data

#endregion
#region Cheermotes

## Returns the data of the Cheermotes.
func get_cheermote_data() -> Array[TwitchCheermote]:
	if media_loader == null:
		_log.e("TwitchMediaLoader was not set within %s" % get_tree_string())
		return []
	await media_loader.preload_cheemote()
	return media_loader.all_cheermotes()


## Returns all cheertiers in form of:
## Key: TwitchCheermote.Tiers | Value: SpriteFrames
func get_cheermotes(definition: TwitchCheermoteDefinition) -> Dictionary:
	return await media_loader.get_cheermotes(definition)

#endregion
