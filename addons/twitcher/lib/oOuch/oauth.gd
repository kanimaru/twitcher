@tool
extends Node

## Orchestrates the complete authentication process
class_name OAuth

const OAuthHTTPServer = preload("res://addons/twitcher/lib/http/http_server.gd")
const OAuthHTTPClient = preload("res://addons/twitcher/lib/http/buffered_http_client.gd")
const OAuthDeviceCodeResponse = preload("./oauth_device_code_response.gd")

## Called when the authorization for AuthCodeFlow is complete to handle the auth code
signal _auth_succeed(code: String)

## In case the authorization wasn't succesfull
signal auth_error(error: String, error_description: String)

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: OAuthDeviceCodeResponse)

## Called when the token has changed
signal token_changed(access_token: String)

@export var oauth_setting: OAuthSetting
@export var scopes: OAuthScopes
@export var token_handler: OAuthTokenHandler

var login_in_process: bool
## Special solution just for twitch ignore it in all other providers
var force_verify: String
var _query_parser = RegEx.create_from_string("GET (.*?/?)\\??(.*?)? HTTP/1\\.1.*?")
var _auth_http_server: OAuthHTTPServer
var _last_login_attempt: int
var _client: OAuthHTTPClient

enum AuthorizationFlow {
	AUTHORIZATION_CODE_FLOW,
	IMPLICIT_FLOW,
	DEVICE_CODE_FLOW,
	CLIENT_CREDENTIALS
}


func _ready() -> void:
	_client = OAuthHTTPClient.new()
	add_child(_client)
	_auth_http_server = OAuthHTTPServer.new(oauth_setting.redirect_port)
	if token_handler == null:
		token_handler = OAuthTokenHandler.new()
		add_child(token_handler)
	token_handler.unauthenticated.connect(_on_unauthenticated)
	token_handler.token_resolved.connect(_on_token_resolved)


func _on_unauthenticated() -> void:
	login()


func _on_token_resolved(token: OAuthToken) -> void:
	token_changed.emit(token.get_access_token())


## Checks if the authentication is valid.
func is_authenticated() -> bool:
	return token_handler.is_token_valid()


## Starts the token refresh process to rotate the tokens
func refresh_token() -> void:
	await token_handler.refresh_tokens()


## Gets the current token as soon as it is available
func get_token() -> String:
	if token_handler.get_access_token() == "":
		await token_handler.token_resolved
	return token_handler.get_access_token()


## Depending on the authorization_flow it gets resolves the token via the different
## Flow types. Only one login process at the time. All other tries wait until the first process
## was succesful.
func login() -> void:
	if not is_node_ready(): await ready
	if token_handler.is_token_valid() && not _got_scopes_changed(): return

	if login_in_process:
		# TODO Find away to implement a proper timeout for previous requests.
		# Problem is that awaits are not canceable
		logInfo("Another process tries already to login. Abort")
		await token_handler.token_resolved
		return

	if _last_login_attempt != 0 && Time.get_ticks_msec() - 60 * 1000 < _last_login_attempt:
		print("[OAuth] Last Login attempt was within 1 minute wait 1 minute before trying again. Please enable and consult logs, cause there is an issue with your authentication!")
		await get_tree().create_timer(60).timeout

	_last_login_attempt = Time.get_ticks_msec()

	login_in_process = true
	logInfo("do login")
	match oauth_setting.authorization_flow:
		AuthorizationFlow.AUTHORIZATION_CODE_FLOW:
			await _start_login_process("code")
		AuthorizationFlow.CLIENT_CREDENTIALS:
			await token_handler.request_token("client_credentials")
		AuthorizationFlow.IMPLICIT_FLOW:
			await _start_login_process("token")
		AuthorizationFlow.DEVICE_CODE_FLOW:
			await _start_device_login_process()

	login_in_process = false

func _got_scopes_changed() -> bool:
	var existing_scopes = token_handler.get_scopes()
	var requested_scopes = scopes.used_scopes
	if existing_scopes.size() != requested_scopes.size():
		return true

	for scope in existing_scopes:
		if requested_scopes.find(scope) == -1:
			return true

	return false

func _start_login_process(response_type: String) -> void:
	if scopes == null: scopes = OAuthScopes.new()

	_auth_http_server.start()

	if response_type == "code":
		_auth_http_server.request_received.connect(_process_code_request.bind(_auth_http_server))
	elif response_type == "token":
		_auth_http_server.request_received.connect(_process_implicit_request.bind(_auth_http_server))

	var query_param = "&".join([
			"force_verify=%s" % force_verify.uri_encode(),
			"response_type=%s" % response_type.uri_encode(),
			"client_id=%s" % oauth_setting.client_id.uri_encode(),
			"scope=%s" % scopes.ssv_scopes().uri_encode(),
			"redirect_uri=%s" % oauth_setting.redirect_url.uri_encode()
		])

	var url = oauth_setting.authorization_url + "?" + query_param
	logInfo("start login process to get token for scopes %s" % (",".join(scopes.used_scopes)))
	logDebug("login to %s" % url)
	OS.shell_open(url)
	logDebug("waiting for user to login.")
	if response_type == "code":
		var auth_code = await _auth_succeed
		token_handler.request_token("authorization_code", auth_code)
		await token_handler.token_resolved
		_auth_http_server.request_received.disconnect(_process_code_request.bind(_auth_http_server))
	elif response_type == "token":
		await token_handler.token_resolved
		_auth_http_server.request_received.disconnect(_process_implicit_request.bind(_auth_http_server))
	logInfo("authorization is done stop server")
	_auth_http_server.stop()

#region DeviceCodeFlow

## Starts the device flow.
func _start_device_login_process():
	var scopes = scopes.used_scopes
	var device_code_response = await _fetch_device_code_response(scopes)
	device_code_requested.emit(device_code_response)

	# print the information instead of opening the browser so that the developer can decide if
	# he want to open the browser manually. Also use print not the logger so that the information
	# is sent always.
	print("Visit %s and enter the code %s for authorization." % [device_code_response.verification_uri, device_code_response.user_code])
	await token_handler.request_device_token(device_code_response, scopes)

func _fetch_device_code_response(scopes: String) -> OAuthDeviceCodeResponse:
	logInfo("Start device code flow")
	logDebug("Request Scopes: %s" % scopes)
	var body = "client_id=%s&scopes=%s" % [oauth_setting.client_id, scopes.uri_encode()]
	if oauth_setting.client_secret != "":
		body += "&client_secret=%s" % oauth_setting.client_secret
	var request = _client.request(oauth_setting.device_authorization_url, HTTPClient.METHOD_POST, {
		"Content-Type": "application/x-www-form-urlencoded"
	}, body)

	var initial_response_data = await _client.wait_for_request(request)
	if initial_response_data.response_code != 200:
		logError("Couldn't initiate device code flow response code %s" % initial_response_data.response_code)
	var initial_response_string = initial_response_data.response_data.get_string_from_ascii()
	var initial_response_dict = JSON.parse_string(initial_response_string) as Dictionary
	return OAuthDeviceCodeResponse.new(initial_response_dict)

#endregion
#region ImplicitFlow

## Handles the response after auth endpoint redirects to our server with the response
func _process_implicit_request(client: OAuthHTTPServer.Client, server: OAuthHTTPServer) -> void:
	var request = client.peer.get_utf8_string(client.peer.get_available_bytes())
	if request == "":
		logError("Empty response. Check if your redirect URL is set to %s." % oauth_setting.redirect_url)
		client.peer.disconnect_from_host()
		return

	var first_linebreak = request.find("\n")
	var first_line = request.substr(0, first_linebreak)
	if first_line.begins_with("GET"):
		var matcher = _query_parser.search(first_line)
		if matcher == null:
			logDebug("Response from auth server was not right expected redirect url. It's ok browser asked probably for favicon etc.")
			return
		var redirect_path = oauth_setting.redirect_path
		var request_path = matcher.get_string(1)
		if redirect_path == request_path:
			server.send_response(client, "200 OK", ("<html><head><title>Login</title></head><body>
				<script>
					var params = Object.fromEntries(new URLSearchParams(window.location.hash.substring(1)));
					fetch('" + oauth_setting.redirect_url + "', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(params) })
					.then(window.close);
				</script>
				Redirect Token to Godot
			</body></html>").to_utf8_buffer())
		logInfo("Send Response to send it via POST")
	elif first_line.begins_with("POST"):
		var parts = request.split("\r\n\r\n")
		if parts.size() < 2:
			return  # Not a valid request
		var json_body = parts[1]
		var token_request = JSON.parse_string(json_body)
		token_handler.update_tokens(token_request["access_token"])
		logInfo("Received Access Token update it")
		server.send_response(client, "200 OK", "<html><head><title>Login</title><script>window.close()</script></head><body>Success!</body></html>".to_utf8_buffer())

#endregion
#region AuthCodeFlow
## Handles the response after auth endpoint redirects to our server with the response
func _process_code_request(client: OAuthHTTPServer.Client, server: OAuthHTTPServer) -> void:
	var request = client.peer.get_utf8_string(client.peer.get_available_bytes())
	if request == "":
		logError("Empty response. Check if your redirect URL is set to %s." % oauth_setting.redirect_url)
		client.peer.disconnect_from_host()
		return

	# Firstline contains request path and parameters
	var first_line = request.substr(0, request.find("\n"))
	var matcher = _query_parser.search(first_line)
	if matcher == null:
		logDebug("Response from auth server was not right expected query params. It's ok browser asked probably for favicon etc.")
		client.peer.disconnect_from_host()
		return

	var query_params_str = matcher.get_string(2)
	var query_params = parse_query(query_params_str)

	if not query_params.has("error"):
		_handle_success(server, client, query_params)
	else:
		_handle_error(server, client, query_params)
	client.peer.disconnect_from_host()

## Returns the response for the given auth request back to the browser also emits the auth code
func _handle_success(server: OAuthHTTPServer, client: OAuthHTTPServer.Client, query_params : Dictionary) -> void:
	logInfo("Authentication success. Send auth code.")
	server.send_response(client, "200 OK", "<html><head><title>Login</title><script>window.close()</script></head><body>Success!</body></html>".to_utf8_buffer())
	if query_params.has("code"):
		_auth_succeed.emit(query_params['code'])
	else:
		logError("Auth code expected wasn't send!")

## Handles the error in case that Auth API has a problem
func _handle_error(server: OAuthHTTPServer, client: OAuthHTTPServer.Client, query_params : Dictionary) -> void:
	var msg = "Error %s: %s" % [query_params["error"], query_params["error_description"]]
	logError(msg)
	server.send_response(client, "400 BAD REQUEST",  msg.to_utf8_buffer())

#endregion


## Parses a query string and returns a dictionary with the parameters.
static func parse_query(query: String) -> Dictionary:
	var parameters = Dictionary()
	# Split the query by '&' to separate different parameters.
	var pairs = query.split("&")
	# Iterate over each pair of key-value.
	for pair in pairs:
		# Split the pair by '=' to separate the key from the value.
		var kv = pair.split("=")
		if kv.size() == 2:
			var key = kv[0].strip_edges()
			var value = kv[1].strip_edges()
			var decoded_key = key.uri_decode()
			var decoded_value = value.uri_decode()
			parameters[decoded_key] = decoded_value
	return parameters


# === LOGGER ===
static var logger: Dictionary = {}
static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug
	logger.info = info
	logger.error = error
	OAuthTokenHandler.set_logger(error, info, debug)

static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text)

static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text)

static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text)
