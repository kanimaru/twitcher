extends RefCounted

const OAuthHTTPClient = preload("./http_client.gd");
const OAuthToken = preload("./token.gd");
const OAuthDeviceCodeResponse = preload("./device_code_response.gd");

## Handles refreshing and resolving access and refresh tokens.

const HEADERS = {
	"User-Agent": "OAuth/1.0 (Godot)",
	"Accept": "*/*",
	"Content-Type": "application/x-www-form-urlencoded"
};

## Called when new access token is available
signal token_resolved(tokens: OAuthToken);

## Called when token can't be refreshed cause auth was removed or refresh token expired
signal unauthenticated();

## Holds the current set of tokens
var _tokens: OAuthToken;

## Client to request new tokens
var _http_client : OAuthHTTPClient;

## Is currently requesting tokens
var _requesting_token: bool = false;

var _setting: OAuth.Setting;

func _init(setting: OAuth.Setting) -> void:
	_setting = setting;
	_tokens = OAuthToken.new(setting.cache_file, setting.encryption_secret)
	_http_client = OAuthHTTPClient.new(setting.get_token_host());
	Engine.get_main_loop().process_frame.connect(_check_token_refresh);

## Checks if tokens runs up and starts refreshing it. (called often hold footprint small)
func _check_token_refresh() -> void:
	if _requesting_token: return;
	if !_tokens.is_token_valid() && _tokens.has_refresh_token():
		logInfo("Token needs refresh");
		refresh_tokens();

## Requests the tokens
func request_token(grant_type: String, auth_code: String = ""):
	if _requesting_token: return;
	_requesting_token = true;
	logInfo("Request token via '%s'" % grant_type)
	var request_params = [
		"grant_type=%s" % grant_type,
		"client_id=%s" % _setting.client_id,
		"client_secret=%s" % _setting.client_secret
	]

	if auth_code != "":
		request_params.append("code=%s" % auth_code);
	if grant_type == "authorization_code":
		request_params.append("&redirect_uri=%s" % _setting.redirect_url);

	var request_body = "&".join(request_params);
	var request = _http_client.request(_setting.get_token_path(), HTTPClient.METHOD_POST, HEADERS, request_body);
	if(await _handle_token_request(request)):
		logInfo("token resolved")
	_requesting_token = false;

func request_device_token(device_code_repsonse: OAuthDeviceCodeResponse, scopes: String, grant_type: String = "urn:ietf:params:oauth:grant-type:device_code") -> void:
	if _requesting_token: return;
	_requesting_token = true;
	logInfo("request token via urn:ietf:params:oauth:grant-type:device_code")
	var parameters = [
		"client_id=%s" % _setting.client_id,
		"grant_type=%s" % grant_type,
		"device_code=%s" % device_code_repsonse.device_code,
		"scopes=%s" % scopes
	]
	if _setting.client_secret != "":
		parameters.append("client_secret=%s" % _setting.client_secret);

	var request_body = "&".join(parameters);

	# Time when the code is expired and we don't poll anymore
	var expire_data = Time.get_unix_time_from_system() + device_code_repsonse.expires_in;

	while expire_data > Time.get_unix_time_from_system():
		var request = _http_client.request(_setting.get_token_path(), HTTPClient.METHOD_POST, HEADERS, request_body);
		var response = await _http_client.wait_for_request(request);
		var response_string: String = response.response_data.get_string_from_utf8();
		var response_data = JSON.parse_string(response_string);
		if response.response_code == 200:
			_update_tokens_from_response(response_data);
			_requesting_token = false;
			return;
		elif response.response_code == 400 && response_string.contains("authorization_pending"):
			# Awaits for this amount of time until retry
			await Engine.get_main_loop().create_timer(device_code_repsonse.interval).timeout
		elif response.response_code == 400:
			unauthenticated.emit();
			_requesting_token = false;
			return;

	# Handle Timeout
	unauthenticated.emit();
	_requesting_token = false;

## Uses the refresh token if possible to refresh all tokens
func refresh_tokens() -> void:
	if _requesting_token: return;
	_requesting_token = true;
	logInfo("Refresh token")
	var request_body = "client_id=%s&client_secret=%s&refresh_token=%s&grant_type=refresh_token" % [_setting.client_id, _setting.client_secret, _tokens.get_refresh_token()];
	var request = _http_client.request(_setting.get_token_path(), HTTPClient.METHOD_POST, HEADERS, request_body);
	if await _handle_token_request(request):
		logInfo("Token got refreshed")
	else:
		unauthenticated.emit();
	_requesting_token = false;

## Gets information from the response and update values returns true when success otherwise false
func _handle_token_request(request: OAuthHTTPClient.RequestData) -> bool:
	var response = await _http_client.wait_for_request(request);
	var response_string = response.response_data.get_string_from_utf8();
	var result = JSON.parse_string(response_string);
	if response.response_code == 200:
		_update_tokens_from_response(result);
		return true;
	else:
		# Reset expiration cause token wasn't refreshed correctly.
		_tokens.invalidate();
	logError("Token could not be fetched ResponseCode %s / Client Status %s / Body %s" % [response.client.get_response_code(), response.client.get_status(), response_string])
	return false;

func _update_tokens_from_response(result: Dictionary):
	update_tokens(result["access_token"], result.get("refresh_token", ""), result.get("expires_in", -1));

## Updates the token. Result is the response data of an token request.
func update_tokens(access_token: String, refresh_token: String = "", expires_in: int = -1):
	_tokens.update_values(access_token, refresh_token, expires_in);
	token_resolved.emit(_tokens);
	logInfo("Token received");

## Checks if the token are valud
func is_token_valid() -> bool:
	var current_time = Time.get_datetime_string_from_system(true);
	var expire_data = Time.get_datetime_string_from_unix_time(_tokens._expire_date);
	logDebug("Check expiration: " + current_time + " < " + expire_data)
	return _tokens.is_token_valid();
func get_access_token() -> String: return _tokens.get_access_token();

# === LOGGER ===
static var logger: Dictionary = {};
static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug;
	logger.info = info;
	logger.error = error;

static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text);

static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text);

static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text);
