extends RefCounted

## Handles refreshing and resolving access and refresh tokens.
class_name TwitchTokenHandler

const HEADERS = {
	"User-Agent": "godot/twitcher/1.0 (Godot)",
	"Accept": "*/*",
	"Content-Type": "application/x-www-form-urlencoded"
};

## Called when new access token is available
signal token_resolved(access_token: Tokens);

## Called when token can't be refreshed cause auth was removed or refresh token expired
signal unauthenticated();

## Wrapper for the tokens. Hint never store the token value as string in
## your code to reduce the chance to dox the tokens always use the getter.
class Tokens extends RefCounted:

	var config_file: ConfigFile = ConfigFile.new();
	var access_token: String = "";
	var refresh_token: String = "";
	var expire_date: int;

	func _init() -> void:
		_load_tokens();

	func _update_values(access_tok: String, refresh_tok: String, expire_in: int):
		expire_date = roundi(Time.get_unix_time_from_system() + expire_in);
		access_token = access_tok
		refresh_token = refresh_tok

	## Persists the tokesn with the expire date
	func _persist_tokens():
		config_file.set_value("auth", "expire_date", expire_date);
		config_file.set_value("auth", "access_token", access_token);
		config_file.set_value("auth", "refresh_token", refresh_token);
		config_file.save_encrypted_pass(TwitchSetting.auth_cache, TwitchSetting.client_secret);

	## Loads the tokens and returns the information if the file got created
	func _load_tokens():
		var status = config_file.load_encrypted_pass(TwitchSetting.auth_cache, TwitchSetting.client_secret)
		if status == OK:
			expire_date = config_file.get_value("auth", "expire_date", 0);
			access_token = config_file.get_value("auth", "access_token");
			refresh_token = config_file.get_value("auth", "refresh_token");
			return true;
		return false;

	func get_token() -> String:
		return access_token;

	func has_refresh_token() -> bool:
		return refresh_token != "";

	func is_token_valid() -> bool:
		return Time.get_unix_time_from_system() < expire_date;

## Holds the current set of tokens
var tokens: Tokens = Tokens.new();

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
		print("Twitch Auth: token needs refresh");
		refresh_tokens();

## Uses the refresh token if possible to refresh all tokens
func refresh_tokens() -> void:
	if requesting_token: return;
	requesting_token = true;
	print("Twitch Auth: refresh token")
	var request_body = "client_id=%s&client_secret=%s&refresh_token=%s&grant_type=refresh_token" % [TwitchSetting.client_id, TwitchSetting.client_secret, tokens.refresh_token];
	var request = http_client.request(TwitchSetting.token_endpoint, HTTPClient.METHOD_POST, HEADERS, request_body);
	if(await _handle_token_request(request)):
		token_resolved.emit(tokens.access_token);
		print("Twitch Auth: token refreshed")
	else:
		unauthenticated.emit();
	requesting_token = false;

## Requests the tokens with the client credential flow
func request_token(auth_code: String):
	if requesting_token: return;
	requesting_token = true;
	print("Twitch Auth: request token")
	var request_body = "client_id=%s&client_secret=%s&code=%s&grant_type=authorization_code&redirect_uri=%s" % [TwitchSetting.client_id, TwitchSetting.client_secret, auth_code, TwitchSetting.redirect_url];
	var request = http_client.request(TwitchSetting.token_endpoint, HTTPClient.METHOD_POST, HEADERS, request_body);
	if(await _handle_token_request(request)):
		token_resolved.emit(tokens.access_token);
		print("Twitch Auth: token resolved")
	else:
		refresh_tokens();
	requesting_token = false;

## Gets information from the twitch response and update values
func _handle_token_request(request: BufferedHTTPClient.RequestData) -> bool:
	var response = await http_client.wait_for_request(request);
	var response_string = response.response_data.get_string_from_utf8();
	if response.response_code == 200:
		var result = JSON.parse_string(response_string);
		tokens._update_values(result["access_token"], result["refresh_token"], result["expires_in"])
		tokens._persist_tokens();
		return true;
	else:
		# Reset expiration cause token got not refreshed correctly.
		tokens.expire_date = 0;
	printerr("Twitch Auth: Token could not be fetched ResponseCode %s / Status %s" % [response.client.get_response_code(), response.client.get_status()])
	return false;

## Checks if the token are valud
func is_token_valid() -> bool:
	return tokens.is_token_valid();
