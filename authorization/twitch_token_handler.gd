extends RefCounted

## Handles refreshing and resolving access and refresh tokens.
class_name TwitchTokenHandler

var log : TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_AUTH);

const HEADERS = {
	"User-Agent": "godot/twitcher/1.0 (Godot)",
	"Accept": "*/*",
	"Content-Type": "application/x-www-form-urlencoded"
};

## Called when new access token is available
signal token_resolved(access_token: TwitchTokens);

## Called when token can't be refreshed cause auth was removed or refresh token expired
signal unauthenticated();

## Holds the current set of tokens
var tokens: TwitchTokens = TwitchTokens.new();

## Client to request new tokens
var http_client : BufferedHTTPClient;

## Is currently requesting tokens
var requesting_token: bool = false;

func _init() -> void:
	http_client = BufferedHTTPClient.new(TwitchSetting.token_host);
	Engine.get_main_loop().process_frame.connect(_check_token_refresh);

## Checks if tokens runs up and starts refreshing it. (called often hold footprint small)
func _check_token_refresh() -> void:
	if requesting_token: return;
	if !tokens.is_token_valid() && tokens.has_refresh_token():
		log.i("token needs refresh");
		refresh_tokens();

## Requests the tokens with the client credential flow
func request_token(grant_type: String, auth_code: String = ""):
	if requesting_token: return;
	requesting_token = true;
	log.i("request token via %s" % grant_type)
	var request_params = [
		"grant_type=%s" % grant_type,
		"client_id=%s" % TwitchSetting.client_id,
		"client_secret=%s" % TwitchSetting.client_secret
	]

	if auth_code != "":
		request_params.append("code=%s" % auth_code);
	if grant_type == "authorization_code":
		request_params.append("&redirect_uri=%s" % TwitchSetting.redirect_url);

	var request_body = "&".join(request_params);
	var request = http_client.request(TwitchSetting.token_endpoint, HTTPClient.METHOD_POST, HEADERS, request_body);
	if(await _handle_token_request(request)):
		log.i("token resolved")
	else:
		refresh_tokens();
	requesting_token = false;

func request_device_token(device_code_repsonse: TwitchAuth.DeviceCodeResponse, scopes: String):
	if requesting_token: return;
	requesting_token = true;
	log.i("request token via urn:ietf:params:oauth:grant-type:device_code")

	var request_body = "&".join([
		"client_id=%s" % TwitchSetting.client_id,
		"grant_type=urn:ietf:params:oauth:grant-type:device_code",
		"device_code=%s" % device_code_repsonse.device_code,
		"scopes=%s" % scopes
	]);

	# Time when the code is expired and we don't poll anymore
	var expire_data = Time.get_unix_time_from_system() + device_code_repsonse.expires_in;

	while true:
		var request = http_client.request(TwitchSetting.token_endpoint, HTTPClient.METHOD_POST, HEADERS, request_body);
		var response = await http_client.wait_for_request(request);
		var response_string = response.response_data.get_string_from_utf8();
		var response_data = JSON.parse_string(response_string);
		if response.response_code == 200:
			_update_tokens_from_response(response_data);
			return true;
		elif response.response_code == 400 && response_data["message"] == "authorization_pending":
			# Awaits for this amount of time until retry
			await Engine.get_main_loop().create_timer(device_code_repsonse.interval).timeout
		elif response.response_code == 400:
			unauthenticated.emit();
			return;

		# Handle Timeout
		if expire_data < Time.get_unix_time_from_system():
			unauthenticated.emit();
			return

## Uses the refresh token if possible to refresh all tokens
func refresh_tokens() -> void:
	if requesting_token: return;
	requesting_token = true;
	log.i("refresh token")
	var request_body = "client_id=%s&client_secret=%s&refresh_token=%s&grant_type=refresh_token" % [TwitchSetting.client_id, TwitchSetting.client_secret, tokens.refresh_token];
	var request = http_client.request(TwitchSetting.token_endpoint, HTTPClient.METHOD_POST, HEADERS, request_body);
	if(await _handle_token_request(request)):
		log.i("token refreshed")
	else:
		unauthenticated.emit();
	requesting_token = false;

## Gets information from the twitch response and update values
func _handle_token_request(request: BufferedHTTPClient.RequestData) -> bool:
	var response = await http_client.wait_for_request(request);
	var response_string = response.response_data.get_string_from_utf8();
	var result = JSON.parse_string(response_string);
	if response.response_code == 200:
		_update_tokens_from_response(result);
		return true;
	else:
		# Reset expiration cause token got not refreshed correctly.
		tokens.expire_date = 0;
	log.e("Token could not be fetched ResponseCode %s / Status %s / Body %s" % [response.client.get_response_code(), response.client.get_status(), response_string])
	return false;

func _update_tokens_from_response(result: Dictionary):
	update_tokens(result["access_token"], result.get("refresh_token", ""), result["expires_in"])

## Updates the token. Result is the response data of an token request.
func update_tokens(access_token: String, refresh_token: String = "", expires_in: int = -1):
	tokens._update_values(access_token, refresh_token, expires_in);
	tokens._persist_tokens();
	token_resolved.emit(tokens.access_token);
	log.i("token received")

## Checks if the token are valud
func is_token_valid() -> bool:
	return tokens.is_token_valid();
