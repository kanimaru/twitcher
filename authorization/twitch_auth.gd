extends RefCounted

## Orchestrates the complete authentication process to Twitch
class_name TwitchAuth

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_AUTH);

## Called when the authorization is complete to handle the auth code
signal auth_succeed(code: String);

## In case the authorization wasn't succesfull
signal auth_error(error: String, error_description: String);

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

	var url = TwitchSetting.authorization_url;
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
		token_handler.set_access_token(access_token);
		pass
	elif query_params.has("code"):
		auth_succeed.emit(query_params['code']);

## Handles the error in case that Twitch Auth API has a problem
func _handle_error(server: HTTPServer, client: HTTPServer.Client, query_params : Dictionary) -> void:
	var msg = "Error %s: %s" % [query_params["error"], query_params["error_description"]];
	log.e(msg);
	server.send_response(client.peer, "400 BAD REQUEST",  msg.to_utf8_buffer());
