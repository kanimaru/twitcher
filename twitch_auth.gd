extends RefCounted

## Orchestrates the complete authentication process to Twitch
class_name TwitchAuth

## Called when the authorization is complete to handle the auth code
signal auth_succeed(code: String);

## In case the authorization wasn't succesfull
signal auth_error(error: String, error_description: String);

#@export var SCOPES := " ".join([
	#"chat:edit",
	#"chat:read",
	#"moderator:read:followers",
	#"channel:manage:broadcast",
	#"channel:manage:raids",
	#"channel:manage:redemptions",
	#"channel:read:subscriptions",
	#"bits:read",
	#"moderator:manage:shoutouts",
	#"moderator:manage:announcements"
#]);

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
		print("Twitch Auth: token is invalid.")
		await login();
	print("Twitch Auth: is done.")

## Gets the current token as soon as it is available
func get_token() -> String:
	if token_handler.tokens.access_token == "":
		await token_handler.token_resolved;
	return token_handler.tokens.access_token;

## Opens the browser to login into twitch and waits for the response to be handled.
## Only one login process at the time. All other tries wait until the first process was succesful.
## Processes like:
## 1. Gets the Auth Code to authenticate
## 2. Uses the Auth Code to authorize at the token endpoint to receive a set of tokens
func login() -> void:
	if login_in_process:
		print("Twitch Auth: another process tries already to login. Abort");
		await token_handler.token_resolved;
		return;

	login_in_process = true;
	print("Twitch Auth: do login")
	auth_http_server.start();
	var query_param = [TwitchSetting.client_id, TwitchSetting.get_scopes(), TwitchSetting.redirect_url, TwitchSetting.force_verify].map(func (a : String): return a.uri_encode());
	OS.shell_open(TwitchSetting.authorization_url + "?response_type=code&client_id=%s&scope=%s&redirect_uri=%s&force_verify=%s" % query_param)
	print("Twitch Auth: Waiting for user to login.")
	var auth_code = await auth_succeed;
	token_handler.request_token(auth_code);
	await token_handler.token_resolved;
	auth_http_server.stop();
	login_in_process = false;

## Handles the response after Twitch auth endpoint redirects to our server with the response
func _process_request(server: HTTPServer, client: HTTPServer.Client) -> void:
	var request = client.peer.get_utf8_string(client.peer.get_available_bytes());
	if (request == ""):
		print("Empty response. Check if your redirect URL is set to %s." % TwitchSetting.redirect_url)
		return

	# Firstline contains request path and parameters
	var first_line = request.substr(0, request.find("/n"));
	var query_params_str = first_line.split(" ")[1];
	query_params_str = query_params_str.substr(2); # remove /?

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
	var start : int = first_line.find("?")
	if (start == -1):
		print ("Response from Twitch does not contain the required data.");
		client.peer.disconnect_from_host();
		return false;
	return true;

## Returns the response for the given auth request back to the browser also emits the auth code
func _handle_success(server: HTTPServer, client: HTTPServer.Client, query_params : Dictionary) -> void:
	print("Twitch Auth: authentication success.");
	server.send_response(client.peer, "200 OK", "<html><head><title>Twitch Login</title><script>window.close()</script></head><body>Success!</body></html>".to_utf8_buffer());
	auth_succeed.emit(query_params['code']);

## Handles the error in case that Twitch Auth API has a problem
func _handle_error(server: HTTPServer, client: HTTPServer.Client, query_params : Dictionary) -> void:
	var msg = "Error %s: %s" % [query_params["error"], query_params["error_description"]];
	print("Twitch Auth: Error ", msg);
	server.send_response(client.peer, "400 BAD REQUEST",  msg.to_utf8_buffer());

