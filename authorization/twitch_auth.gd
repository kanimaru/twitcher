extends RefCounted

## Orchestrates the complete authentication process to Twitch
class_name TwitchAuth

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_AUTH);

## Called when the authorization is complete to handle the auth code
signal auth_succeed(code: String);

## In case the authorization wasn't succesfull
signal auth_error(error: String, error_description: String);

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: DeviceCodeResponse);

var auth_http_server: HTTPServer;
var token_handler: TwitchTokenHandler;
var login_in_process: bool;

func _init() -> void:
	auth_http_server = HTTPServer.new(TwitchSetting.redirect_port);
	auth_http_server.add_request_handler(_process_request);
	token_handler = TwitchTokenHandler.new();
	token_handler.unauthenticated.connect(login);

## Checks if the authentication is valid.
func is_authenticated() -> bool:
	return token_handler.is_token_valid();

## Starts the token refresh process to rotate the tokens
func refresh_token() -> void:
	await token_handler.refresh_tokens();

## Checks if the authentication is done or requests a new authentication.
## Use this to ensure that the Twitch Auth is initialized
func ensure_authentication() -> void:
	if not token_handler.is_token_valid():
		log.i("Token is invalid.")
		await login();
	log.i("Login is done.")

## Gets the current token as soon as it is available
func get_token() -> String:
	if token_handler.tokens.access_token == "":
		await token_handler.token_resolved;
	return token_handler.tokens.access_token;

## Depending on the TwitchSetting.authorization_flow it gets resolves the token via the different
## Flow types. Only one login process at the time. All other tries wait until the first process
## was succesful.
func login() -> void:
	if login_in_process:
		log.i("another process tries already to login. Abort");
		await token_handler.token_resolved;
		return;

	login_in_process = true;
	log.i("do login")
	match TwitchSetting.authorization_flow:
		TwitchSetting.FLOW_AUTHORIZATION_CODE:
			await _start_login_process("code");
		TwitchSetting.FLOW_CLIENT_CREDENTIALS:
			await token_handler.request_token("client_credentials");
		# Implicit flow is activly deactivated. Don't use it in Backend Application FLOW_AUTHORIZATION_CODE
		# does the same but has advantages like refresh codes. I let this code in to remind you about that.
		# When you want to have it you have to solve the problem that Twitch redirects the token to a fragment
		# aka: /#access_token=.... that is not transfered to the backend for a good reason.
		# That means you need to transfere it from the frontend to the backend yourself.
		TwitchSetting.FLOW_IMPLICIT:
			log.e("Implicit Flow is currently disabled. Implicit flow is not recommended use Authorization Code Flow.")
		#	await _start_login_process("token");
		TwitchSetting.FLOW_DEVICE_CODE_GRANT:
			await _start_device_login_process();
	login_in_process = false;

func _start_login_process(response_type: String):
	auth_http_server.start();
	var query_param = [
			response_type,
			TwitchSetting.client_id,
			TwitchSetting.get_scopes(),
			TwitchSetting.redirect_url,
			TwitchSetting.force_verify
		].map(func (a : String): return a.uri_encode());

	var url = TwitchSetting.authorization_host + TwitchSetting.authorization_path;
	log.i("Start login process for %s" % TwitchSetting.get_scopes())
	url += "?response_type=%s&client_id=%s&scope=%s&redirect_uri=%s&force_verify=%s" % query_param;
	OS.shell_open(url);
	log.i("Waiting for user to login.")
	if response_type == "code":
		var auth_code = await auth_succeed;
		token_handler.request_token("authorization_code", auth_code);
		await token_handler.token_resolved;
	elif response_type == "token":
		await token_handler.token_resolved;
	auth_http_server.stop();

## Starts the device flow.
func _start_device_login_process():
	var scopes = TwitchSetting.get_scopes();

	var device_code_response = await _fetch_device_code_response(scopes);

	# print the information instead of opening the browser so that the developer can decide if
	# he want to open the browser manually. Also use print not the logger so that the information
	# is sent always.
	print("Visit %s and enter the code %s for authorization." % [device_code_response.verification_uri, device_code_response.user_code])

	var token = await token_handler.request_device_token(device_code_response, scopes);

func _fetch_device_code_response(scopes: String) -> DeviceCodeResponse:
	log.i("Start login process DCF for %s" % scopes)
	var client = HttpClientManager.get_client(TwitchSetting.authorization_host) as BufferedHTTPClient;
	var body = "client_id=%s&scopes=%s" % [TwitchSetting.client_id, scopes.uri_encode()];
	var request = client.request(TwitchSetting.authorization_device_path, HTTPClient.METHOD_POST, {
		"Content-Type": "application/x-www-form-urlencoded"
	}, body);

	var initial_response_data = await client.wait_for_request(request);
	if initial_response_data.response_code != 200:
		log.e("Couldn't initiate device code flow response code %s" % initial_response_data.response_code)
	var initial_response_string = initial_response_data.response_data.get_string_from_ascii();
	var initial_response_dict = JSON.parse_string(initial_response_string) as Dictionary;
	return DeviceCodeResponse.new(initial_response_dict);

## Handles the response after Twitch auth endpoint redirects to our server with the response
func _process_request(server: HTTPServer, client: HTTPServer.Client) -> void:
	var request = client.peer.get_utf8_string(client.peer.get_available_bytes());
	if (request == ""):
		log.e("Empty response. Check if your redirect URL is set to %s." % TwitchSetting.redirect_url)
		return;

	# Firstline contains request path and parameters
	var first_line = request.substr(0, request.find("/n"));
	var query_params_str = first_line.split(" ")[1];
	query_params_str = query_params_str.substr(2); # remove /? or /# depending on auth flow

	# Don't send unauthorized cause it could be a favicon request
	if not _response_is_valid(first_line, client): return;
	var query_params = HttpUtil.parse_query(query_params_str);

	if not query_params.has("error"):
		_handle_success(server, client, query_params);
	else:
		_handle_error(server, client, query_params);
	client.peer.disconnect_from_host();

## Checks if the response has query parameters to be valid
func _response_is_valid(first_line: String, client: HTTPServer.Client) -> bool:
	# Tries to find the query parameters within request / response of Twitch auth
	var start_query : int = first_line.find("?"); # needed for auth code workflow
	var start_fragment : int = first_line.find("#"); # needed for implicit workflow
	if start_query == -1 && start_fragment == -1:
		log.e("Response from Twitch does not contain the required data.");
		client.peer.disconnect_from_host();
		return false;
	return true;

## Returns the response for the given auth request back to the browser also emits the auth code
func _handle_success(server: HTTPServer, client: HTTPServer.Client, query_params : Dictionary) -> void:
	log.i("authentication success.");
	server.send_response(client.peer, "200 OK", "<html><head><title>Twitch Login</title><script>window.close()</script></head><body>Success!</body></html>".to_utf8_buffer());

	# Handle implicit success
	if query_params.has("access_token"):
		var access_token = query_params.get("access_token");
		token_handler.update_tokens(access_token);
		pass
	elif query_params.has("code"):
		auth_succeed.emit(query_params['code']);

## Handles the error in case that Twitch Auth API has a problem
func _handle_error(server: HTTPServer, client: HTTPServer.Client, query_params : Dictionary) -> void:
	var msg = "Error %s: %s" % [query_params["error"], query_params["error_description"]];
	log.e(msg);
	server.send_response(client.peer, "400 BAD REQUEST",  msg.to_utf8_buffer());

## Response of the inital device code request
class DeviceCodeResponse extends RefCounted:
	var device_code: String;
	var expires_in: int;
	var interval: int;
	var user_code: String;
	var verification_uri: String;

	func _init(json: Dictionary):
		device_code = json["device_code"];
		expires_in = int(json["expires_in"]);
		interval = int(json["interval"]);
		user_code = json["user_code"];
		verification_uri = json["verification_uri"];
