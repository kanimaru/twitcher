@tool
extends Node

## Delegate class for the oOuch Library.
class_name TwitchAuth

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: OAuth.OAuthDeviceCodeResponse);

## Where to authorize. Nullable: fallback to the ProjectSettings
@export var setting: OAuthSetting:
	set(val):
		setting = val
		_update_setting(val)
## Shows the what to authorize page of twitch again. (for example you need to relogin with a different account aka bot account)
@export var force_verify: bool
## Where should the tokens be saved into
@export var token: OAuthToken
## Scopes for the token that should be requested
@export var scopes: OAuthScopes

@onready var auth: OAuth = %OAuth
@onready var token_handler: TwitchTokenHandler = %TokenHandler

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_AUTH)
var is_authenticated: bool:
	get(): return auth.is_authenticated()


func _ready() -> void:
	OAuth.set_logger(log.e, log.i, log.d);


func _enter_tree() -> void:
	if setting == null: setting = _get_setting()
	_update_setting(setting)
	%OAuth.force_verify = &"true" if force_verify else &"false"
	%OAuth.scopes = scopes
	%TokenHandler.token = token


func _update_setting(val: OAuthSetting) -> void:
	if not is_inside_tree(): return
	%OAuth.setting = setting
	%TokenHandler.setting = setting


func authorize() -> void:
	await auth.login();
	token_handler.process_mode = Node.PROCESS_MODE_INHERIT


func refresh_token() -> void:
	auth.refresh_token();


func _get_setting() -> OAuthSetting:
	var setting = OAuthSetting.new();
	setting.authorization_flow = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW;
	setting.device_authorization_url = "https://id.twitch.tv/oauth2/device";
	setting.token_url = "https://id.twitch.tv/oauth2/token";
	setting.authorization_url = "https://id.twitch.tv/oauth2/authorize";
	setting.cache_file = "user://auth.conf";
	setting.redirect_url = "http://localhost:7170";
	return setting;
