@tool
extends Node

## Delegate class for the oOuch Library.
class_name TwitchAuth

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: OAuth.OAuthDeviceCodeResponse);

## Called when the authorization process is complete
signal authorized(success: bool);

## Where to authorize. Nullable: fallback to the ProjectSettings
@export var setting: OAuthSetting:
	set(val):
		setting = val
		_update_setting(val)
## When the project settings should be used instead of setting
@export var use_project_setting: bool
## Where should the tokens be saved into
@export var token: OAuthToken = OAuthToken.new()
## Scopes for the token that should be requested
@export var scopes: OAuthScopes = OAuthScopes.new()

@onready var auth: OAuth = %OAuth
@onready var token_handler: TwitchTokenHandler = %TokenHandler

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_AUTH)
var is_authenticated: bool:
	get(): return auth.is_authenticated()


func _ready() -> void:
	OAuth.set_logger(log.e, log.i, log.d);


func _enter_tree() -> void:
	if setting == null || use_project_setting: setting = _get_setting()
	_update_setting(setting)
	%OAuth.force_verify = TwitchSetting.force_verify
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
	setting.authorization_flow = _get_flow();
	setting.device_authorization_url = "https://id.twitch.tv/oauth2/device";
	setting.token_url = "https://id.twitch.tv/oauth2/token";
	setting.authorization_url = "https://id.twitch.tv/oauth2/authorize";
	setting.client_id = TwitchSetting.client_id;
	setting.client_secret = TwitchSetting.client_secret;
	setting.cache_file = TwitchSetting.auth_cache;
	return setting;


func _get_flow() -> OAuth.AuthorizationFlow:
	match TwitchSetting.authorization_flow:
		TwitchSetting.FLOW_AUTHORIZATION_CODE: return OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW;
		TwitchSetting.FLOW_CLIENT_CREDENTIALS: return OAuth.AuthorizationFlow.CLIENT_CREDENTIALS;
		TwitchSetting.FLOW_DEVICE_CODE_GRANT: return OAuth.AuthorizationFlow.DEVICE_CODE_FLOW;
		TwitchSetting.FLOW_IMPLICIT: return OAuth.AuthorizationFlow.IMPLICIT_FLOW;
	return OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW;
