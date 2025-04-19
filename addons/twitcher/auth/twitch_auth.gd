@icon("res://addons/twitcher/assets/auth-icon.svg")
@tool
extends Twitcher

## Delegate class for the oOuch Library.
class_name TwitchAuth

const HttpUtil = preload("res://addons/twitcher/lib/http/http_util.gd")

static var _log: TwitchLogger = TwitchLogger.new("TwitchAuth")

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: OAuth.OAuthDeviceCodeResponse);

## Where and how to authorize.
@export var oauth_setting: OAuthSetting:
	set(val): 
		oauth_setting = val
		if auth != null: auth.oauth_setting = oauth_setting
		if token_handler != null: token_handler.oauth_setting = oauth_setting
		update_configuration_warnings()
## Shows the what to authorize page of twitch again. (for example you need to relogin with a different account aka bot account)
@export var force_verify: bool
## Where should the tokens be saved into
@export var token: OAuthToken:
	set(val):
		token = val
		if token_handler != null: token_handler.token = token
		update_configuration_warnings()
## Scopes for the token that should be requested
@export var scopes: OAuthScopes:
	set(val):
		scopes = val
		if auth != null: auth.scopes = scopes
		update_configuration_warnings()

## Takes care to authorize the user
@onready var auth: OAuth
## Takes care to fetch and refresh oauth tokens
@onready var token_handler: TwitchTokenHandler


var is_authenticated: bool:
	get(): return auth.is_authenticated()


func _init() -> void:
	child_entered_tree.connect(_on_enter_child)
	# There could be better locations but this ensures that its there when an 
	# auth is needed.
	var http_logger = TwitchLogger.new("Http")
	HttpUtil.set_logger(http_logger.e, http_logger.i, http_logger.d)


func _on_enter_child(node: Node) -> void:
	if node is OAuth: auth = node
	if node is TwitchTokenHandler: token_handler = node


func _ready() -> void:
	OAuth.set_logger(_log.e, _log.i, _log.d);
	if oauth_setting == null: oauth_setting = create_default_oauth_setting()
	_ensure_children()


func _ensure_children() -> void:
	if token_handler == null:
		token_handler = TwitchTokenHandler.new()
		token_handler.name = "TokenHandler"

	if auth == null:
		auth = OAuth.new()
		auth.name = "OAuth"
		
	_sync_childs()

	if not auth.is_inside_tree():
		add_child(auth)
		auth.owner = owner
	if not token_handler.is_inside_tree():
		add_child(token_handler)
		token_handler.owner = owner


func _sync_childs() -> void:
	token_handler.oauth_setting = oauth_setting
	token_handler.token = token
	auth.token_handler = token_handler
	auth.oauth_setting = oauth_setting
	auth.scopes = scopes
	auth.force_verify = &"true" if force_verify else &"false"
	

func authorize() -> bool:
	_sync_childs()
	if await auth.login():
		token_handler.process_mode = Node.PROCESS_MODE_INHERIT
		return true
	return false


func refresh_token() -> void:
	auth.refresh_token()


static func create_default_oauth_setting() -> OAuthSetting:
	var oauth_setting = OAuthSetting.new()
	oauth_setting.authorization_flow = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW
	oauth_setting.device_authorization_url = "https://id.twitch.tv/oauth2/device"
	oauth_setting.token_url = "https://id.twitch.tv/oauth2/token"
	oauth_setting.authorization_url = "https://id.twitch.tv/oauth2/authorize"
	oauth_setting.cache_file = "user://auth.conf"
	oauth_setting.redirect_url = "http://localhost:7170"
	return oauth_setting
	

## Checks if the correctly setup
func is_configured() -> bool:
	return _get_configuration_warnings().is_empty()
	
	
func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if oauth_setting == null:
		result.append("OAuthSetting missing")
	else:
		var oauth_setting_problems : PackedStringArray = oauth_setting.get_valididation_problems()
		if not oauth_setting_problems.is_empty():
			result.append("OAuthSetting is invalid")
			result.append_array(oauth_setting_problems)
	if scopes == null:
		result.append("OAuthScopes is missing")
	if token == null:
		result.append("OAuthToken is missing")
	return result
