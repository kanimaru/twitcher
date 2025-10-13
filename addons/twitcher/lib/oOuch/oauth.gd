@icon("./security-icon.svg")
@tool
extends Node

## Orchestrates the complete authentication process
class_name OAuth

const OAuthHTTPServer = preload("res://addons/twitcher/lib/http/http_server.gd")
const OAuthHTTPClient = preload("res://addons/twitcher/lib/http/buffered_http_client.gd")
const OAuthDeviceCodeResponse = preload("./oauth_device_code_response.gd")

## A static string in front of the sensible data to prevent accidental leak of tokens during debug sessions
const DEBUGGER_PROTECTION: String = "                                                               "

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
## Customize how you want to open the authorization page (advanced usage for example multi user authentication)
@export var shell_command: String
## Parameters for the shell command (advanced usage for example multi user authentication)
@export var shell_parameter: Array[String] = []
## Some oauth provide doesn't return the provided scopes so you can disable the scope check
@export var check_scope_changed: bool = true
## Should the Twitch special handling be activated (Twitch is behaving differntly as the normal Oauth provider and needs SpEcIal treatment)
@export var enable_twitch_hacks: bool = true

var login_in_process: bool
## Special solution just for twitch ignore it in all other providers
var force_verify: String
var _query_parser = RegEx.create_from_string("GET (.*?/?)\\??(.*?)? HTTP/1\\.1.*?")
var _auth_http_server: OAuthHTTPServer
var _last_login_attempt: int
## State for the current authcode request to compare with
var _current_state: String
var _client: OAuthHTTPClient
var _crypto: Crypto = Crypto.new()
var _login_timeout_timer: Timer
var _initialized: bool

enum AuthorizationFlow {
	AUTHORIZATION_CODE_FLOW,
	IMPLICIT_FLOW,
	DEVICE_CODE_FLOW,
	CLIENT_CREDENTIALS
}


func _on_unauthenticated() -> void:
	login()


func _on_token_resolved(token: OAuthToken) -> void:
	if token == null: return
	token_changed.emit(await token.get_access_token())


## Checks if the authentication is valid.
func is_authenticated() -> bool:
	return token_handler.is_token_valid()


## Starts the token refresh process to rotate the tokens
func refresh_token() -> void:
	await token_handler.refresh_tokens()


func _setup_nodes() -> void:
	if _initialized: return
	_initialized = true
	
	if _client == null:
		_client = OAuthHTTPClient.new()
		_client.name = "OAuthClient"
		add_child(_client)
	
	if _auth_http_server == null:
		_auth_http_server = OAuthHTTPServer.create(oauth_setting.redirect_port)
		_auth_http_server.name = "OAuthServer"
		add_child(_auth_http_server)
	
	if token_handler == null:
		token_handler = OAuthTokenHandler.new()
		add_child(token_handler)
		
	token_handler.unauthenticated.connect(_on_unauthenticated)
	token_handler.token_resolved.connect(_on_token_resolved)
	
	_login_timeout_timer = Timer.new()
	_login_timeout_timer.name = "LoginTimeoutTimer"
	_login_timeout_timer.one_shot = true
	_login_timeout_timer.wait_time = 30
	_login_timeout_timer.timeout.connect(_on_login_timeout)
	add_child(_login_timeout_timer)

func do_unsetup() -> void:
	_last_login_attempt = 0

## Depending on the authorization_flow it gets resolves the token via the different
## Flow types. Only one login process at the time. All other tries wait until the first process
## was succesful.
func login() -> bool:
	if not is_node_ready(): await ready
	_setup_nodes()
	if token_handler.is_token_valid() && not _got_scopes_changed(): return true
	logDebug("Token is valid (%s) and not scopes changed (%s)" % [ token_handler.is_token_valid(), _got_scopes_changed()])

	if login_in_process:
		logInfo("Another process tries already to login. Abort")
		if (await token_handler.token_resolved) == null:
			return false
		return true

	if _last_login_attempt != 0 && Time.get_ticks_msec() - 60 * 1000 < _last_login_attempt:
		print("[OAuth] Last Login attempt was within 1 minute wait 1 minute before trying again. Please enable and consult logs, cause there is an issue with your authentication!")
		await get_tree().create_timer(60, true, false, true).timeout

	_last_login_attempt = Time.get_ticks_msec()

	login_in_process = true
	_login_timeout_timer.start()
	logInfo("do login")
	match oauth_setting.authorization_flow:
		AuthorizationFlow.AUTHORIZATION_CODE_FLOW:
			await _start_login_process("code")
		AuthorizationFlow.CLIENT_CREDENTIALS:
			await _start_client_credential_process()
		AuthorizationFlow.IMPLICIT_FLOW:
			await _start_login_process("token")
		AuthorizationFlow.DEVICE_CODE_FLOW:
			await _start_device_login_process()

	login_in_process = false
	_login_timeout_timer.stop()
	return true


func _got_scopes_changed() -> bool:
	if not check_scope_changed: return false
	
	var existing_scopes = token_handler.get_scopes()
	var requested_scopes = scopes.used_scopes
	if existing_scopes.size() != requested_scopes.size():
		return true

	for scope in existing_scopes:
		if requested_scopes.find(scope) == -1:
			return true

	return false

	
## Called when the login process is timing out cause of misconfiguration or other natural catastrophes.
func _on_login_timeout() -> void:
	if token_handler.is_token_valid(): return
	logError("Login run into a timeout. Stop all login processes.")
	_auth_succeed.emit("")
	token_handler.token_resolved.emit(null)


func _start_login_process(response_type: String) -> void:
	if scopes == null: scopes = OAuthScopes.new()

	_auth_http_server.start_listening()

	if response_type == "code":
		_auth_http_server.request_received.connect(_process_code_request.bind(_auth_http_server))
	elif response_type == "token":
		_auth_http_server.request_received.connect(_process_implicit_request.bind(_auth_http_server))

	_current_state = _crypto.generate_random_bytes(16).hex_encode()
	var query_param = "&".join([
			"force_verify=%s" % force_verify.uri_encode(),
			"response_type=%s" % response_type.uri_encode(),
			"client_id=%s" % oauth_setting.client_id.uri_encode(),
			"scope=%s" % scopes.ssv_scopes().uri_encode(),
			"redirect_uri=%s" % oauth_setting.redirect_url.uri_encode(),
			"state=%s" % _current_state
		])

	var url = oauth_setting.authorization_url + "?" + query_param
	logInfo("start login process to get token for scopes %s" % (",".join(scopes.used_scopes)))
	logDebug("login to %s" % url)
	if not shell_command.is_empty():
		var parameters: PackedStringArray = shell_parameter.duplicate() \
			.map(func(param: String): return param.format({"url": url}))
		OS.create_process(shell_command, parameters)
	else:
		OS.shell_open(url)
		
	logDebug("waiting for user to login.")
	if response_type == "code":
		var auth_code = await _auth_succeed
		if auth_code == "":
			logDebug("Auth code was empty. Abort Login.")
			return
		token_handler.request_token("authorization_code", auth_code)
		await token_handler.token_resolved
		_auth_http_server.request_received.disconnect(_process_code_request.bind(_auth_http_server))
	elif response_type == "token":
		await token_handler.token_resolved
		_auth_http_server.request_received.disconnect(_process_implicit_request.bind(_auth_http_server))
	logInfo("authorization is done stop server")
	_auth_http_server.stop_listening()

#region DeviceCodeFlow


## Starts the device flow.
func _start_device_login_process():
	var scopes: String = " ".join(scopes.used_scopes)
	var device_code_response: OAuthDeviceCodeResponse = await _fetch_device_code_response(scopes)
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
		var token_request: Variant = JSON.parse_string(json_body)
		if token_request["state"] != _current_state:
			server.send_response(client, "200 OK", "<html><head><title>Login</title></head><body>Unsuccessful someone tampered with the state! See <a href='https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#implicit-grant-flow'>Twitch Documentation</a> for more information.</body></html>".to_utf8_buffer())
			return
		
		var scopes: PackedStringArray = token_request["scope"].split(" ")
		if enable_twitch_hacks && token_handler is TwitchTokenHandler:
				var token: String = OAuth.DEBUGGER_PROTECTION + token_request["access_token"]
				var validation_response: BufferedHTTPClient.ResponseData = await token_handler.validate_token(token)
				var validation_data: Variant = JSON.parse_string(validation_response.response_data.get_string_from_utf8())
				token_handler.update_tokens(token, "", validation_data["expires_in"], scopes)
		else:
			token_handler.update_tokens(token_request["access_token"], "", token_request["expires_in"], scopes)
		logInfo("Received Access Token update it")
		server.send_response(client, "200 OK", "<html><head><title>Login</title><script>window.close()</script></head><body>Success!</body></html>".to_utf8_buffer())

#endregion
#region AuthCodeFlow
## Handles the response after auth endpoint redirects to our server with the response
func _process_code_request(client: OAuthHTTPServer.Client, server: OAuthHTTPServer) -> void:
	if client.peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		logError("Client not connected can't process code response.")
		return

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

	var state = query_params.get("state")
	if query_params.has("error"):
		_handle_error(server, client, query_params)
	elif state == _current_state:
		_handle_success(server, client, query_params)
	else:
		_handle_other_requests(server, client, first_line)
	client.peer.disconnect_from_host()


## Returns the response for the given auth request back to the browser also emits the auth code
func _handle_success(server: OAuthHTTPServer, client: OAuthHTTPServer.Client, query_params : Dictionary) -> void:
	logInfo("Authentication success. Send auth code.")
	if query_params.has("code"):
		var succes_page = FileAccess.get_file_as_bytes("res://addons/twitcher/assets/success-page.txt")
		server.send_response(client, "200 OK", succes_page)
		_auth_succeed.emit(query_params['code'])
	else:
		var error_page = FileAccess.get_file_as_bytes("res://addons/twitcher/assets/error-page.txt")
		server.send_response(client, "200 OK", error_page)
		logError("Auth code expected wasn't send!")


## Handles the error in case that Auth API has a problem
func _handle_error(server: OAuthHTTPServer, client: OAuthHTTPServer.Client, query_params : Dictionary) -> void:
	var msg = "Error %s: %s" % [query_params["error"], query_params["error_description"]]
	logError(msg)
	server.send_response(client, "400 BAD REQUEST",  msg.to_utf8_buffer())

#endregion
#region ClientCredentialFlow
func _start_client_credential_process() -> void:
	var token = await token_handler.request_token("client_credentials")
	if enable_twitch_hacks:
		# There is a reason why this is in twitch hacks =__= 
		# aka client credentials doesn't give you the scopes anywhere
		token._update_scopes(scopes.used_scopes)
	
#endregion

func _handle_other_requests(server: OAuthHTTPServer, client: OAuthHTTPServer.Client, fist_line: String) -> void:
	if fist_line.contains("favicon.ico"):
		var favicon: PackedByteArray = FileAccess.get_file_as_bytes("res://addons/twitcher/assets/favicon.ico")
		server.send_response(client, "200", favicon)


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
