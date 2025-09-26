@icon("res://addons/twitcher/assets/auth-icon.svg")
@tool
extends OAuthTokenHandler

class_name TwitchTokenHandler

## Time between checking the validation of the tokens
var _last_validation_check: int = 0


func _ready() -> void:
	super._ready()
	# We don't need to check right after the start
	_last_validation_check = Time.get_ticks_msec() + 60 * 60 * 1000;


func _check_token_refresh() -> void:
	super._check_token_refresh()

	if _last_validation_check < Time.get_ticks_msec():
		_validate_token()


## Calles the validation endpoint of Twtich to make sure
func _validate_token() -> void:
	_last_validation_check = Time.get_ticks_msec() + 60 * 60 * 1000;
	var access_token = token._access_token # we need to use the internal access token here cause the get_access_token method won't returned until the token is authorized 
	var validation_request = _http_client.request("https://id.twitch.tv/oauth2/validate", HTTPClient.METHOD_GET, {
		"Authorization": "OAuth %s" % access_token
	}, "")
	var response = await _http_client.wait_for_request(validation_request)
	if response.response_code != 200:
		refresh_tokens()
		return

	var response_string: String = response.response_data.get_string_from_utf8();
	var response_data = JSON.parse_string(response_string);
	if response_data["expires_in"] <= 0:
		refresh_tokens()
		return
	else:
		# update expire date
		token._expire_date = Time.get_unix_time_from_system() + response_data["expires_in"]
		token.emit_changed()


func revoke_token() -> void:
	var request = _http_client.request("https://id.twitch.tv/oauth2/revoke", HTTPClient.METHOD_POST, 
		{ "Content-Type": "application/x-www-form-urlencoded" }, 
		"client_id=%s&token=%s" % [oauth_setting.client_id, await token.get_access_token()])
	var response: BufferedHTTPClient.ResponseData = await _http_client.wait_for_request(request)
	if response.error:
		var response_message = response.response_data.get_string_from_utf8()
		logError("Couldn't revoke Token cause of: %s" % response_message)
	token.remove_tokens()
