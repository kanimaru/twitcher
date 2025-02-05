@tool
extends Node

## Access to the Twitch API. Combines all the stuff the library provides.
## Makes some actions easier to use.
class_name TwitchService

static var _log: TwitchLogger = TwitchLogger.new("TwitchService")

@export var oauth_setting: OAuthSetting = OAuthSetting.new():
	set(val):
		oauth_setting = val
		oauth_setting.changed.connect(update_configuration_warnings)
		update_configuration_warnings()
@export var scopes: OAuthScopes:
	set(val):
		scopes = val
		update_configuration_warnings()
@export var token: OAuthToken:
	set(val):
		token = val
		update_configuration_warnings()

@onready var auth: TwitchAuth
@onready var eventsub: TwitchEventsub
@onready var api: TwitchAPI
@onready var irc: TwitchIRC
@onready var media_loader: TwitchMediaLoader
@onready var command_handler: TwitchCommandHandler


func _init() -> void:
	child_entered_tree.connect(_on_child_entered)
	child_exiting_tree.connect(_on_child_exiting)


func _ready() -> void:
	_ensure_required_nodes()
	_log.d("is ready")
	

func _ensure_required_nodes() -> void:
	if auth == null:
		auth = TwitchAuth.new()
		auth.oauth_setting = oauth_setting
		add_child(auth)


func _on_child_entered(node: Node) -> void:
	if node is TwitchAuth: auth = node
	if node is TwitchAPI: api = node
	if node is TwitchEventsub: eventsub = node
	if node is TwitchIRC: irc = node
	if node is TwitchMediaLoader: media_loader = node
	if node is TwitchCommandHandler: command_handler = node

	if "token" in node && token != null:
		node.token = token
	if "scopes" in node && scopes != null:
		node.scopes = scopes
	if "oauth_setting" in node && oauth_setting != null:
		node.oauth_setting = oauth_setting
	if node.has_signal(&"unauthenticated"):
		node.unauthenticated.connect(_on_unauthenticated)


func _on_child_exiting(node: Node) -> void:
	if node.has_signal(&"unauthenticated"):
		node.unauthenticated.disconnect(_on_unauthenticated)


## Call this to setup the complete Twitch integration whenever you need.
## It boots everything up this Lib supports.
func setup() -> void:
	await auth.authorize()
	await propagate_call(&"do_setup")
	for child in get_children():
		if child.has_method(&"wait_setup"):
			await child.wait_setup()

	_log.i("TwitchService setup")


## Checks if the correctly setup
func is_configured() -> bool:
	return _get_configuration_warnings().is_empty()


func _on_unauthenticated() -> void:
	auth.authorize()

#
# Convinient Proxy Methods
#
#region User


## Get data about a user by USER_ID see get_user for by username
func get_user_by_id(user_id: String) -> TwitchUser:
	if api == null:
		_log.e("Please setup a TwitchAPI Node into TwitchService.")
		return null
	if user_id == null || user_id == "": return null
	var user_data : TwitchGetUsersResponse = await api.get_users([user_id], [])
	if user_data.data.is_empty(): return null
	return user_data.data[0]


## Get data about a user by USERNAME see get_user_by_id for by user_id
func get_user(username: String) -> TwitchUser:
	if api == null:
		_log.e("Please setup a TwitchAPI Node into TwitchService.")
		return null

	var user_data : TwitchGetUsersResponse = await api.get_users([], [username])
	if user_data.data.is_empty():
		_log.e("Username was not found: %s" % username)
		return null
	return user_data.data[0]


## Get data about a currently authenticated user
func get_current_user() -> TwitchUser:
	if api == null:
		_log.e("Please setup a TwitchAPI Node into TwitchService.")
		return null

	var user_data : TwitchGetUsersResponse = await api.get_users([], [])
	return user_data.data[0]


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

## Sends out a shoutout to a specific user
func shoutout(user: TwitchUser) -> void:
	var broadcaster_id = api.default_broadcaster_login
	if broadcaster_id == "": return
	api.send_a_shoutout(broadcaster_id, user.id, broadcaster_id)


## Sends a announcement message to the chat
func announcment(message: String, color: TwitchAnnouncementColor = TwitchAnnouncementColor.PRIMARY):
	var broadcaster_id = api.default_broadcaster_login
	if broadcaster_id == "": return
	var body = TwitchSendChatAnnouncementBody.new()
	body.message = message
	body.color = color.value
	api.send_chat_announcement(broadcaster_id, body)


## Add a new command handler and register it for a command.
## The callback will receive [code]info: TwitchCommandInfo, args: Array[String][/code][br]
## Args are optional depending on the configuration.[br]
## args_max == -1 => no upper limit for arguments
func add_command(command: String, callback: Callable, args_min: int = 0, args_max: int = -1,
	permission_level : TwitchCommandHandler.PermissionFlag = TwitchCommandHandler.PermissionFlag.EVERYONE,
	where : TwitchCommandHandler.WhereFlag = TwitchCommandHandler.WhereFlag.CHAT) -> void:

	_log.i("Register command %s" % command)
	command_handler.add_command(command, callback, args_min, args_max, permission_level, where)


## Removes a command
func remove_command(command: String) -> void:
	_log.i("Remove command %s" % command)
	command_handler.remove_command(command)


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
func get_badges_data(channel_id: String = "global") -> Dictionary:
	return await media_loader.get_cached_badges(channel_id)


## Gets the requested emotes.
## Key: EmoteID as String | Value: SpriteFrame
func get_emotes(ids: Array[String]) -> Dictionary:
	return await media_loader.get_emotes(ids)


## Gets the requested emotes in the specified theme, scale and type.
## Loads from cache if possible otherwise downloads and transforms them.
## Key: TwitchEmoteDefinition | Value SpriteFrames
func get_emotes_by_definition(emotes: Array[TwitchEmoteDefinition]) -> Dictionary:
	return await media_loader.get_emotes_by_definition(emotes)


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

func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	
	if oauth_setting == null:
		result.append("OAuthSetting is missing")
	else:
		var oauth_setting_problems : PackedStringArray = oauth_setting.is_valid()
		if not oauth_setting_problems.is_empty():
			result.append("OAuthSetting is invalid")
			result.append_array(oauth_setting_problems)
	if scopes == null:
		result.append("OAuthScopes is missing")
	if token == null:
		result.append("OAuthToken is missing")
	return result
