## Tests for [OAuth].
##
## Covers the pure decision of the implicit flow which expiry a freshly received
## token gets after the validation endpoint was asked about it. The flow itself
## needs a browser redirect and isn't exercised here.
extends TwitcherTest


func _validation(response_code: int, body: String = "") -> BufferedHTTPClient.ResponseData:
	var response: BufferedHTTPClient.ResponseData = BufferedHTTPClient.ResponseData.new()
	response.response_code = response_code
	response.response_data = body.to_utf8_buffer()
	return response


func test_implicit_expiry_prefers_the_validated_expiry() -> void:
	var validation: BufferedHTTPClient.ResponseData = _validation(200, "{\"expires_in\": 42}")

	assert_eq(OAuth._implicit_token_expiry(validation, 3600), 42)


func test_implicit_expiry_keeps_the_redirect_expiry_when_twitch_omits_it() -> void:
	var validation: BufferedHTTPClient.ResponseData = _validation(200, "{}")

	assert_eq(OAuth._implicit_token_expiry(validation, 3600), 3600)


## Regression test: a 401 body is JSON too, so it got parsed like a success and
## the rejected token was stored right after the validation removed it.
func test_implicit_expiry_rejects_a_token_twitch_refused() -> void:
	var validation: BufferedHTTPClient.ResponseData = _validation(
			401, "{\"status\": 401, \"message\": \"invalid access token\"}")

	assert_eq(OAuth._implicit_token_expiry(validation, 3600), -1,
			"-1 tells the flow not to store the token")


## Regression test: an empty body (offline, timeout) skipped storing the token,
## so the login that just succeeded in the browser got lost.
func test_implicit_expiry_keeps_the_token_when_the_validation_could_not_run(
		params: Variant = use_parameters([0, 500, 503])) -> void:
	var response_code: int = params

	assert_eq(OAuth._implicit_token_expiry(_validation(response_code), 3600), 3600,
			"HTTP %s says nothing about the token" % response_code)


func test_implicit_expiry_keeps_the_redirect_expiry_without_a_validation() -> void:
	assert_eq(OAuth._implicit_token_expiry(null, 3600), 3600)


func test_implicit_expiry_survives_a_body_that_is_not_json() -> void:
	assert_eq(OAuth._implicit_token_expiry(_validation(200, "<html>"), 3600), 3600)
