@tool
extends Node

static var _log: TwitchLogger = TwitchLogger.new("TwitchAPI")
const TrackedData = preload("res://addons/twitcher/tracked_data.gd")

## Maximal tries to reauthrorize before giving up the request.
const MAX_AUTH_ERRORS = 3

## Called when the API returns unauthenticated mostly cause the accesstoken is expired
signal unauthenticated

## Called when the API returns 403 means there are permissions / scopes missing
signal unauthorized

## To authorize against the Twitch API
@export var token: OAuthToken
## OAuth settings needed for client information
@export var oauth_setting: OAuthSetting
## URI to the Twitch API
@export var api_host: String = "https://api.twitch.tv/helix"

## Client to make HTTP requests
var client: BufferedHTTPClient
	

func request(path: String, method: int, body: Variant = "", content_type: String = "", error_count: int = 0) -> BufferedHTTPClient.ResponseData:
	var header : Dictionary = {
		"Authorization": "Bearer %s" % [await token.get_access_token()],
		"Client-ID": oauth_setting.client_id
	}
	if content_type != "":
		header["Content-Type"] = content_type

	var request_body: String = ""
	if body == null || (body is String && body == ""):
		request_body = ""
	elif body is Object && body.has_method("to_json"):
		request_body = body.to_json()
	else:
		request_body = JSON.stringify(body)

	var request = client.request(api_host + path, method, header, request_body)
	var response = await client.wait_for_request(request)

	# Token expired / or missing permissions
	if response.response_code == 403:
		_log.e("'%s' is unauthorized. It is probably your scopes." % path)
		unauthorized.emit()
	if response.response_code == 401:
		_log.i("'%s' is unauthenticated. Refresh token." % path)
		unauthenticated.emit()
		await token.authorized
		if error_count + 1 < MAX_AUTH_ERRORS:
			return await request(path, method, body, content_type, error_count + 1)
		else:
			# Give up the request after trying multiple times and
			# return an empty response with correct error code
			var empty_response: BufferedHTTPClient.ResponseData = client.empty_response(request)
			empty_response.response_code = response.response_code
			return empty_response
	return response
