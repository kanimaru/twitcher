extends RefCounted

## Delegate class for the oOuch Library.
class_name TwitchAuth

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: OAuth.OAuthDeviceCodeResponse);

## Called when the auth is ready to do auth things.
signal initialized();

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_AUTH)
var auth: OAuth;
var is_initialzied: bool;

func _init() -> void:
	OAuth.set_logger(log.e, log.i, log.d);
	auth = OAuth.new(await _get_setting());
	is_initialzied = true;
	initialized.emit();

func _is_initialized() -> void:
	if !is_initialzied: await initialized;

func login() -> void:
	await _is_initialized();
	await auth.login();

func ensure_authentication() -> void:
	await _is_initialized();
	await auth.ensure_authentication();

func get_access_token() -> String:
	await _is_initialized();
	return await auth.get_token();

func is_authenticated() -> bool:
	await _is_initialized();
	return auth.is_authenticated();

func refresh_token() -> void:
	await _is_initialized();
	auth.refresh_token();

func _get_setting() -> OAuth.Setting:
	var setting = OAuth.Setting.new();
	await setting.load_from_wellknown("https://id.twitch.tv/oauth2/.well-known/openid-configuration")
	setting.device_authorization_url = "https://id.twitch.tv/oauth2/device";
	setting.authorization_flow = _get_flow();
	setting.client_id = TwitchSetting.client_id;
	setting.client_secret = TwitchSetting.client_secret;
	setting.cache_file = TwitchSetting.auth_cache;
	setting.encryption_secret = TwitchSetting.client_secret;
	setting.scopes = TwitchSetting.get_scopes();
	return setting;

func _get_flow() -> OAuth.AuthorizationFlow:
	match TwitchSetting.authorization_flow:
		TwitchSetting.FLOW_AUTHORIZATION_CODE: return OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW;
		TwitchSetting.FLOW_CLIENT_CREDENTIALS: return OAuth.AuthorizationFlow.CLIENT_CREDENTIALS;
		TwitchSetting.FLOW_DEVICE_CODE_GRANT: return OAuth.AuthorizationFlow.DEVICE_CODE_FLOW;
		TwitchSetting.FLOW_IMPLICIT: return OAuth.AuthorizationFlow.IMPLICIT_FLOW;
	return OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW;
