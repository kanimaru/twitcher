extends RefCounted

## Orchestrates the complete authentication process
class_name OAuth

const OAuthHTTPServer = preload("./http_server.gd");
const OAuthHTTPClient = preload("./http_client.gd");
const OAuthTokenHandler = preload("./token_handler.gd");
const OAuthDeviceCodeResponse = preload("./device_code_response.gd");

## Called when the authorization for AuthCodeFlow is complete to handle the auth code
signal _auth_succeed(code: String);

## In case the authorization wasn't succesfull
signal auth_error(error: String, error_description: String);

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: OAuthDeviceCodeResponse);

## Called when the token has changed
signal token_changed(access_token: String);

var login_in_process: bool;

var _query_parser = RegEx.create_from_string("GET (.*?/?)\\??(.*?)? HTTP/1\\.1.*?")
var _auth_http_server: OAuthHTTPServer;
var _token_handler: OAuthTokenHandler;
var _setting: OAuthSetting;
var _last_login_attempt: int;

enum AuthorizationFlow {
	AUTHORIZATION_CODE_FLOW,
	IMPLICIT_FLOW,
	DEVICE_CODE_FLOW,
	CLIENT_CREDENTIALS,
	PASSWORD_FLOW
}

func _init(setting: OAuthSetting, token_handler: OAuthTokenHandler) -> void:
	_setting = setting;
	_auth_http_server = OAuthHTTPServer.new(setting.get_redirect_port());
	_token_handler = token_handler;
	_token_handler.unauthenticated.connect(_on_unauthenticated);
	_token_handler.token_resolved.connect(_on_token_resolved);

func _on_unauthenticated() -> void:
	login()

func _on_token_resolved(token: OAuthTokenHandler.OAuthToken) -> void:
	token_changed.emit(token.get_access_token());

## Checks if the authentication is valid.
func is_authenticated() -> bool:
	return _token_handler.is_token_valid();

## Starts the token refresh process to rotate the tokens
func refresh_token() -> void:
	await _token_handler.refresh_tokens();

## Checks if the authentication is done or requests a new authentication.
## Use this to ensure that the OAuth is initialized
func ensure_authentication() -> void:
	if not _token_handler.is_token_valid():
		logInfo("Token is invalid.");
		await login();
	logDebug("Login is done.");

## Gets the current token as soon as it is available
func get_token() -> String:
	if _token_handler.get_access_token() == "":
		await _token_handler.token_resolved;
	return _token_handler.get_access_token();

## Depending on the authorization_flow it gets resolves the token via the different
## Flow types. Only one login process at the time. All other tries wait until the first process
## was succesful.
func login() -> void:
	if _last_login_attempt != 0 && Time.get_ticks_msec() - 60 * 1000 < _last_login_attempt:
		print("[OAuth] Last Login attempt was within 1 minute wait 1 minute before trying again. Please enable and consult logs, cause there is an issue with your authentication!")
		await Engine.get_main_loop().create_timer(60).timeout;

	_last_login_attempt = Time.get_ticks_msec()
	if login_in_process:
		logDebug("Another process tries already to login. Abort");
		await _token_handler.token_resolved;
		return;

	login_in_process = true;
	logInfo("do login")
	match _setting.authorization_flow:
		AuthorizationFlow.AUTHORIZATION_CODE_FLOW:
			await _start_login_process("code");
		AuthorizationFlow.CLIENT_CREDENTIALS:
			await _token_handler.request_token("client_credentials");
		AuthorizationFlow.IMPLICIT_FLOW:
			await _start_login_process("token");
		AuthorizationFlow.DEVICE_CODE_FLOW:
			await _start_device_login_process();
		AuthorizationFlow.PASSWORD_FLOW:
			logInfo("Password flow is not yet supported");
			pass
	login_in_process = false;

func _start_login_process(response_type: String):
	_auth_http_server.start();

	if response_type == "code":
		_auth_http_server.request_received.connect(_process_code_request.bind(_auth_http_server));
	elif response_type == "token":
		_auth_http_server.request_received.connect(_process_implicit_request.bind(_auth_http_server));

	var query_param = "&".join([
			"response_type=%s" % response_type.uri_encode(),
			"client_id=%s" % _setting.client_id.uri_encode(),
			"scope=%s" % _setting.get_scopes().uri_encode(),
			"redirect_uri=%s" % _setting.redirect_url.uri_encode()
		]);

	var url = _setting.get_authorization_host() + _setting.get_authorization_path() + "?" + query_param;
	logInfo("Start login process %s" % url);
	logDebug("Request Scopes: %s" % _setting.get_scopes());
	OS.shell_open(url);
	logDebug("Waiting for user to login.")
	if response_type == "code":
		var auth_code = await _auth_succeed;
		_token_handler.request_token("authorization_code", auth_code);
		await _token_handler.token_resolved;
		_auth_http_server.request_received.disconnect(_process_code_request.bind(_auth_http_server));
	elif response_type == "token":
		await _token_handler.token_resolved;
		_auth_http_server.request_received.disconnect(_process_implicit_request.bind(_auth_http_server));
	logInfo("Request is done stop")
	_auth_http_server.stop();

#region DeviceCodeFlow

## Starts the device flow.
func _start_device_login_process():
	var scopes = _setting.get_scopes();
	var device_code_response = await _fetch_device_code_response(scopes);
	device_code_requested.emit(device_code_response);

	# print the information instead of opening the browser so that the developer can decide if
	# he want to open the browser manually. Also use print not the logger so that the information
	# is sent always.
	print("Visit %s and enter the code %s for authorization." % [device_code_response.verification_uri, device_code_response.user_code])
	await _token_handler.request_device_token(device_code_response, scopes);

func _fetch_device_code_response(scopes: String) -> OAuthDeviceCodeResponse:
	logInfo("Start device code flow")
	logDebug("Request Scopes: %s" % scopes);
	var client = OAuthHTTPClient.new(_setting.get_device_authorization_host());
	var body = "client_id=%s&scopes=%s" % [_setting.client_id, scopes.uri_encode()];
	if _setting.client_secret != "":
		body += "&client_secret=%s" % _setting.client_secret;
	var request = client.request(_setting.get_device_authorization_path(), HTTPClient.METHOD_POST, {
		"Content-Type": "application/x-www-form-urlencoded"
	}, body);

	var initial_response_data = await client.wait_for_request(request);
	if initial_response_data.response_code != 200:
		logError("Couldn't initiate device code flow response code %s" % initial_response_data.response_code)
	var initial_response_string = initial_response_data.response_data.get_string_from_ascii();
	var initial_response_dict = JSON.parse_string(initial_response_string) as Dictionary;
	return OAuthDeviceCodeResponse.new(initial_response_dict);

#endregion
#region ImplicitFlow

## Handles the response after auth endpoint redirects to our server with the response
func _process_implicit_request(client: OAuthHTTPServer.Client, server: OAuthHTTPServer) -> void:
	var request = client.peer.get_utf8_string(client.peer.get_available_bytes());
	if request == "":
		logError("Empty response. Check if your redirect URL is set to %s." % _setting.redirect_url)
		client.peer.disconnect_from_host();
		return;

	var first_linebreak = request.find("\n");
	var first_line = request.substr(0, first_linebreak);
	if first_line.begins_with("GET"):
		var matcher = _query_parser.search(first_line);
		if matcher == null:
			logDebug("Response from auth server was not right expected redirect url. It's ok browser asked probably for favicon etc.")
			return;
		var redirect_path = _setting.get_redirect_path();
		var request_path = matcher.get_string(1);
		if redirect_path == request_path:
			server.send_response(client, "200 OK", ("<html><head><title>Login</title></head><body>
				<script>
					var params = Object.fromEntries(new URLSearchParams(window.location.hash.substring(1)));
					fetch('" + _setting.redirect_url + "', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(params) })
					.then(window.close)
				</script>
				Redirect Token to Godot
			</body></html>").to_utf8_buffer());
		logInfo("Send Response to send it via POST")
	elif first_line.begins_with("POST"):
		var parts = request.split("\r\n\r\n")
		if parts.size() < 2:
			return  # Not a valid request
		var json_body = parts[1];
		var token_request = JSON.parse_string(json_body);
		_token_handler.update_tokens(token_request["access_token"]);
		logInfo("Received Access Token update it")
		server.send_response(client, "200 OK", "<html><head><title>Login</title><script>window.close()</script></head><body>Success!</body></html>".to_utf8_buffer());

#endregion
#region AuthCodeFlow
## Handles the response after auth endpoint redirects to our server with the response
func _process_code_request(client: OAuthHTTPServer.Client, server: OAuthHTTPServer) -> void:
	var request = client.peer.get_utf8_string(client.peer.get_available_bytes());
	if request == "":
		logError("Empty response. Check if your redirect URL is set to %s." % _setting.redirect_url)
		client.peer.disconnect_from_host();
		return;

	# Firstline contains request path and parameters
	var first_line = request.substr(0, request.find("\n"));
	var matcher = _query_parser.search(first_line);
	if matcher == null:
		logDebug("Response from auth server was not right expected query params. It's ok browser asked probably for favicon etc.")
		client.peer.disconnect_from_host();
		return

	var query_params_str = matcher.get_string(2);
	var query_params = parse_query(query_params_str);

	if not query_params.has("error"):
		_handle_success(server, client, query_params);
	else:
		_handle_error(server, client, query_params);
	client.peer.disconnect_from_host();

## Returns the response for the given auth request back to the browser also emits the auth code
func _handle_success(server: OAuthHTTPServer, client: OAuthHTTPServer.Client, query_params : Dictionary) -> void:
	logInfo("Authentication success redirect to authorization.");
	server.send_response(client, "200 OK", "<html><head><title>Login</title><script>window.close()</script></head><body>Success!</body></html>".to_utf8_buffer());
	if query_params.has("code"):
		_auth_succeed.emit(query_params['code']);
	else:
		logError("Auth code expected wasn't send!")

## Handles the error in case that Auth API has a problem
func _handle_error(server: OAuthHTTPServer, client: OAuthHTTPServer.Client, query_params : Dictionary) -> void:
	var msg = "Error %s: %s" % [query_params["error"], query_params["error_description"]];
	logError(msg);
	server.send_response(client, "400 BAD REQUEST",  msg.to_utf8_buffer());

#endregion

func get_all_token() -> OAuthTokenHandler.OAuthToken:
	return _token_handler._tokens;

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
static var logger: Dictionary = {};
static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug;
	logger.info = info;
	logger.error = error;
	OAuthHTTPClient.set_logger(error, info, debug);
	OAuthHTTPServer.set_logger(error, info, debug);
	OAuthTokenHandler.set_logger(error, info, debug);

static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text);

static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text);

static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text);
