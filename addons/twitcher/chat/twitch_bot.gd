@icon("res://addons/twitcher/assets/chat-bot-icon.svg")
@tool
extends Node

## Helper to send messages with a second bot user and the corrosponding bot badge.
## Take care that setup is needed that it actually works! The right scopes for the target channel 
## and the sender user has to be set. 
## See also https://dev.twitch.tv/docs/api/reference/#send-chat-message
class_name TwitchBot

static var _log: TwitchLogger = TwitchLogger.new("TwitchBot")
static var _instance: TwitchBot

const TWITCH_BOT_SCOPES = preload("res://addons/twitcher/chat/twitch_bot_scopes.tres")

## The base settings of the game / overlay the bot will inherit from
@export var oauth_setting: OAuthSetting:
	set = _update_setting
	
## A token used for the bot specificially
@export var bot_token: OAuthToken

## Sender user that should be used. Requires user:bot scope from chatting user, 
## and either channel:bot scope from broadcaster or moderator status.
@export var sender: TwitchUser:
	set = _update_sender

## Receive user you will need the channel:bot scope from broadcaster or moderator status. Fallbacks to sender.
@export var receiver: TwitchUser:
	set = _update_receiver

var _bot_auth: TwitchAuth
var _bot_api: TwitchAPI


func _init() -> void:
	child_entered_tree.connect(_on_enter_child)
	
	
func _ready() -> void:
	if bot_token == null: 
		bot_token = OAuthToken.new()
		bot_token._identifier = "Bot-Token"
	_ensure_children()
	_update_setting(oauth_setting)
	
	
func _enter_tree() -> void:
	if _instance == null: _instance = self
	
	
func _exit_tree() -> void:
	if _instance == self: _instance = null
	
	
func _on_enter_child(node: Node) -> void:
	if node is TwitchAuth: _bot_auth = node
	if node is TwitchAPI: _bot_api = node
	
	
func _ensure_children() -> void:
	if _bot_api == null: 
		_bot_api = TwitchAPI.new()
		_bot_api.name = "BotApi"
		add_child(_bot_api)
		_bot_api.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else owner

	if _bot_auth == null: 
		_bot_auth = TwitchAuth.new()
		_bot_auth.name = "BotAuth"
		_bot_auth.scopes = TWITCH_BOT_SCOPES
		add_child(_bot_auth)
		_bot_auth.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else owner
	
	_bot_auth.token = bot_token
	_bot_api.token = bot_token
	
	# Reset the API. The default shouldn't be the Bot API. It has way to less scopes!
	if TwitchAPI.instance == _bot_api:
		TwitchAPI.instance = null


## Sends a message as the bot user the target broadcaster default to the sender user.
## for_source_only: see https://dev.twitch.tv/docs/api/reference/#send-chat-message
static func chat(message: String, reply_parent_message_id: String = "", for_source_only = true, broadcaster: TwitchUser = null) -> void:
	if _instance != null:
		_instance.send_message(message, reply_parent_message_id, for_source_only, broadcaster)


## Sends a message as the bot user the target broadcaster default to the sender user.
## for_source_only: see https://dev.twitch.tv/docs/api/reference/#send-chat-message
func send_message(message: String, reply_parent_message_id: String = "", for_source_only = true, broadcaster: TwitchUser = null) -> void:
	if not _bot_auth.is_authenticated: await _bot_auth.authorize()
	if broadcaster == null: 
		broadcaster = receiver if receiver != null else sender
	_log.d("Send message from %s to %s: %s" % [sender.display_name, broadcaster.display_name, message])
	var body: TwitchSendChatMessage.Body = TwitchSendChatMessage.Body.create(broadcaster.id, sender.id, message)
	if reply_parent_message_id != "":
		body.reply_parent_message_id = reply_parent_message_id
	var response: TwitchSendChatMessage.Response = await _bot_api.send_chat_message(body)
	for data in response.data:
		if data.is_sent: _log.d("Message was sent %s" % [data.message_id])
		else: _log.e("Message couldn't be send cause of [%s]: %s" % [data.drop_reason.code, data.drop_reason.message])
	
	
func _update_setting(val: OAuthSetting) -> void:
	oauth_setting = val
	update_configuration_warnings()
	
	if oauth_setting == null || not is_inside_tree(): return
	
	var bot_setting = oauth_setting.duplicate()
	bot_setting.authorization_flow = OAuth.AuthorizationFlow.CLIENT_CREDENTIALS
	_bot_auth.oauth_setting = bot_setting
	_bot_api.oauth_setting = bot_setting
	
	
func _update_sender(val: TwitchUser) -> void:
	sender = val
	update_configuration_warnings()
	
	
func _update_receiver(val: TwitchUser) -> void:
	receiver = val
	update_configuration_warnings()
	
	
func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if oauth_setting == null:
		result.append("Proper OAuth settings are needed.")
	elif oauth_setting.client_secret == "":
		result.append("Client Secret is needed for using the bot node.")
		
	if sender == null:
		result.append("Sender is missing.")
	elif receiver != null && sender.id == receiver.id:
		result.append("Sender and receiver are the same -> you won't see the bot badge.")
	return result
