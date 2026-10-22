## Tests for [TwitchTokenHandler].
##
## The handler is never added to the tree, so [method Node._ready] doesn't start
## the hourly validation or load tokens from disk. The HTTP client and the token
## are replaced by fakes, so no request leaves the process.
extends TwitcherTest


## Answers every request with a prepared response instead of sending it.
class FakeHttpClient extends BufferedHTTPClient:
	var response_code: int
	var body: String
	var requested_paths: PackedStringArray = []


	func request(path: String, method: int, headers: Dictionary, body_text: String) -> RequestData:
		requested_paths.append(path)
		var request_data: RequestData = RequestData.new()
		request_data.client = self
		request_data.path = path
		request_data.method = method
		request_data.headers = headers
		request_data.body = body_text
		return request_data


	func wait_for_request(request_data: RequestData) -> ResponseData:
		var response: ResponseData = ResponseData.new()
		response.request_data = request_data
		response.response_code = response_code
		response.response_data = body.to_utf8_buffer()
		response.error = response_code < 200 or response_code >= 300
		return response


## Counts removals instead of touching the encrypted token file.
class FakeToken extends OAuthToken:
	var removed: int


	func remove_tokens() -> void:
		removed += 1


var _http: FakeHttpClient
var _token: FakeToken
var _handler: TwitchTokenHandler


func before_each() -> void:
	super()
	_http = autofree(FakeHttpClient.new())
	_token = FakeToken.new()
	_handler = autofree(TwitchTokenHandler.new())
	_handler.token = _token
	_handler._http_client = _http


func _answer(response_code: int, body: String = "") -> void:
	_http.response_code = response_code
	_http.body = body


func test_validation_asks_the_twitch_validation_endpoint() -> void:
	_answer(200, "{\"expires_in\": 3600}")

	await _handler.validate_token("access")

	assert_eq(_http.requested_paths, PackedStringArray([TwitchTokenHandler.VALIDATION_URL]))


func test_a_rejected_token_gets_removed() -> void:
	_answer(401, "{\"status\": 401, \"message\": \"invalid access token\"}")
	watch_signals(_handler)

	await _handler.validate_token("access")

	assert_eq(_token.removed, 1, "Twitch said the token is invalid, it has to go")
	assert_signal_emitted(_handler, "unauthenticated")


func test_a_valid_token_is_kept() -> void:
	_answer(200, "{\"expires_in\": 3600}")
	watch_signals(_handler)

	var response: BufferedHTTPClient.ResponseData = await _handler.validate_token("access")

	assert_eq(response.response_code, 200)
	assert_eq(_token.removed, 0)
	assert_signal_not_emitted(_handler, "unauthenticated")


## Regression test: every answer other than 200 removed the tokens, so being
## offline (code 0), a timeout or a Twitch outage logged the user out even
## though nothing proved the token invalid.
func test_a_validation_that_could_not_run_keeps_the_token(
		params: Variant = use_parameters([0, 408, 429, 500, 502, 503])) -> void:
	var response_code: int = params
	_answer(response_code)
	watch_signals(_handler)

	var response: BufferedHTTPClient.ResponseData = await _handler.validate_token("access")

	assert_eq(response.response_code, response_code, "the caller still sees the failure")
	assert_eq(_token.removed, 0, "HTTP %s says nothing about the token" % response_code)
	assert_signal_not_emitted(_handler, "unauthenticated")
