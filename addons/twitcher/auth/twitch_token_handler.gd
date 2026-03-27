@icon("res://addons/twitcher/assets/auth-icon.svg")
@tool
extends OAuthTokenHandler

class_name TwitchTokenHandler

## Validate that the token is still valid
var _validation_timer: Timer

func _ready() -> void:
	super._ready()
	_validation_timer = Timer.new()
	_validation_timer.name = "ValidationTimer"
	_validation_timer.wait_time = 60*60 # 1 Hour
	_validation_timer.timeout.connect(validate_token)
	add_child(_validation_timer)
	validate_token()


## Calles the validation endpoint of Twtich to make sure
func validate_token() -> BufferedHTTPClient.ResponseData:
	var validation_request = _http_client.request("https://id.twitch.tv/oauth2/validate", HTTPClient.METHOD_GET, {
		"Authorization": "OAuth %s" % await token.get_access_token()
	}, "")
	var response: BufferedHTTPClient.ResponseData = await _http_client.wait_for_request(validation_request)
	if response.response_code != 200:
		logInfo("Token (%s) is not valid anymore. Tokens got reset please reauthenticate! Twitch: %s " % [ token, response.response_data.get_string_from_utf8() ] )
		token.remove_tokens()
		unauthenticated.emit()
		return response

	var response_string: String = response.response_data.get_string_from_utf8();
	var response_data: Variant = JSON.parse_string(response_string);
	if response_data["expires_in"] <= 0:
		logInfo("Token is valid! (%s)" % token)
		refresh_tokens()
	return response


func revoke_token() -> void:
	var request = _http_client.request("https://id.twitch.tv/oauth2/revoke", HTTPClient.METHOD_POST, 
		{ "Content-Type": "application/x-www-form-urlencoded" }, 
		"client_id=%s&token=%s" % [oauth_setting.client_id, await token.get_access_token()])
	var response: BufferedHTTPClient.ResponseData = await _http_client.wait_for_request(request)
	if response.error:
		var response_message = response.response_data.get_string_from_utf8()
		logError("Couldn't revoke Token cause of: %s" % response_message)
	token.remove_tokens()
