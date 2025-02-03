@tool
extends Node

class_name OAuthTokenHandler

const OAuthHTTPClient = preload("res://addons/twitcher/lib/http/buffered_http_client.gd")
const OAuthDeviceCodeResponse = preload("./oauth_device_code_response.gd")

## Handles refreshing and resolving access and refresh tokens.

const HEADERS = {
	"Accept": "*/*",
	"Content-Type": "application/x-www-form-urlencoded"
}

## Called when new access token is available
signal token_resolved(tokens: OAuthToken)

## Called when token can't be refreshed cause auth was removed or refresh token expired
signal unauthenticated()

## Where to get the tokens from
@export var oauth_setting: OAuthSetting

## Holds the current set of tokens
@export var token: OAuthToken

## Client to request new tokens
var _http_client : OAuthHTTPClient

## Is currently requesting tokens
var _requesting_token: bool = false


func _ready() -> void:
	if token == null: token = OAuthToken.new()
	_http_client = OAuthHTTPClient.new()
	_http_client.name = "OAuthClient"
	add_child(_http_client)


func _process(_delta: float) -> void:
	_check_token_refresh()


## Checks if tokens runs up and starts refreshing it. (called often hold footprint small)
func _check_token_refresh() -> void:
	if _requesting_token: return

	if !token.is_token_valid() && token.has_refresh_token():
		logInfo("Token needs refresh")
		refresh_tokens()


## Requests the tokens
func request_token(grant_type: String, auth_code: String = ""):
	if _requesting_token: return
	_requesting_token = true
	logInfo("Request token via '%s'" % grant_type)
	var request_params = [
		"grant_type=%s" % grant_type,
		"client_id=%s" % oauth_setting.client_id,
		"client_secret=%s" % oauth_setting.get_client_secret()
	]

	if auth_code != "":
		request_params.append("code=%s" % auth_code)
	if grant_type == "authorization_code":
		request_params.append("&redirect_uri=%s" % oauth_setting.redirect_url)

	var request_body = "&".join(request_params)
	var request = _http_client.request(oauth_setting.token_url, HTTPClient.METHOD_POST, HEADERS, request_body)
	await _handle_token_request(request)
	_requesting_token = false


func request_device_token(device_code_repsonse: OAuthDeviceCodeResponse, scopes: String, grant_type: String = "urn:ietf:params:oauth:grant-type:device_code") -> void:
	if _requesting_token: return
	_requesting_token = true
	logInfo("request token via urn:ietf:params:oauth:grant-type:device_code")
	var parameters = [
		"client_id=%s" % oauth_setting.client_id,
		"grant_type=%s" % grant_type,
		"device_code=%s" % device_code_repsonse.device_code,
		"scopes=%s" % scopes
	]
	if oauth_setting.client_secret != "":
		parameters.append("client_secret=%s" % oauth_setting.get_client_secret())

	var request_body = "&".join(parameters)

	# Time when the code is expired and we don't poll anymore
	var expire_data = Time.get_unix_time_from_system() + device_code_repsonse.expires_in

	while expire_data > Time.get_unix_time_from_system():
		var request = _http_client.request(oauth_setting.token_url, HTTPClient.METHOD_POST, HEADERS, request_body)
		var response = await _http_client.wait_for_request(request)
		var response_string: String = response.response_data.get_string_from_utf8()
		var response_data = JSON.parse_string(response_string)
		if response.response_code == 200:
			_update_tokens_from_response(response_data)
			_requesting_token = false
			return
		elif response.response_code == 400 && response_string.contains("authorization_pending"):
			# Awaits for this amount of time until retry
			await get_tree().create_timer(device_code_repsonse.interval).timeout
		elif response.response_code == 400:
			unauthenticated.emit()
			_requesting_token = false
			return

	# Handle Timeout
	unauthenticated.emit()
	_requesting_token = false


## Uses the refresh token if possible to refresh all tokens
func refresh_tokens() -> void:
	if _requesting_token: return
	_requesting_token = true
	logInfo("refresh token")
	if token.has_refresh_token():
		var request_body = "client_id=%s&client_secret=%s&refresh_token=%s&grant_type=refresh_token" % [oauth_setting.client_id, oauth_setting.get_client_secret(), token.get_refresh_token()]
		var request = _http_client.request(oauth_setting.token_url, HTTPClient.METHOD_POST, HEADERS, request_body)
		if await _handle_token_request(request):
			logInfo("token got refreshed")
		else:
			unauthenticated.emit()
	else:
		unauthenticated.emit()
	_requesting_token = false


## Gets information from the response and update values returns true when success otherwise false
func _handle_token_request(request: OAuthHTTPClient.RequestData) -> bool:
	var response = await _http_client.wait_for_request(request)
	var response_string = response.response_data.get_string_from_utf8()
	var result = JSON.parse_string(response_string)
	if response.response_code == 200:
		_update_tokens_from_response(result)
		return true
	else:
		# Reset expiration cause token wasn't refreshed correctly.
		token.invalidate()
	logError("token could not be fetched ResponseCode %s / Body %s" % [response.response_code, response_string])
	return false


func _update_tokens_from_response(result: Dictionary):
	var scopes: Array[String] = []
	for scope in result.get("scope", []): scopes.append(scope)

	update_tokens(result["access_token"], \
		result.get("refresh_token", ""), \
		result.get("expires_in", -1), \
		scopes)


## Updates the token. Result is the response data of an token request.
func update_tokens(access_token: String, refresh_token: String = "", expires_in: int = -1, scopes: Array[String] = []):
	token.update_values(access_token, refresh_token, expires_in, scopes)
	token_resolved.emit(token)
	logInfo("token resolved")


func get_token_expiration() -> String:
	return Time.get_datetime_string_from_unix_time(token._expire_date)


## Checks if the token are valud
func is_token_valid() -> bool:
	var current_time = Time.get_datetime_string_from_system(true)
	var expire_data = get_token_expiration()
	logDebug("check expiration: " + current_time + " < " + expire_data)
	return token.is_token_valid()


func get_access_token() -> String: return token.get_access_token()


func has_refresh_token() -> bool: return token.has_refresh_token()


func get_scopes() -> PackedStringArray: return token.get_scopes()


# === LOGGER ===
static var logger: Dictionary = {}


static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug
	logger.info = info
	logger.error = error


static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text)


static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text)


static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text)
