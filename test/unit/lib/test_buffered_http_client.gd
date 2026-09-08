## Unit tests for [BufferedHTTPClient].
##
## The client is exercised against a real [HTTPServer] on the loopback interface,
## because Godot doesn't allow overriding native methods and therefore
## [HTTPRequest] can't be doubled in a meaningful way. The server never answers
## on its own; each test decides when connections get a response (or get
## dropped), which is what makes the queue, the parallel limit and the retry path
## observable.
##
## Background: PR #130 — several threaded requests started in the same frame
## stalled and timed out, so API clients must be sequential by default, while
## emote and badge downloads still need parallelism to stay fast.
extends TwitcherTest

const HttpServer := preload("res://addons/twitcher/lib/http/http_server.gd")
const Subject := preload("res://addons/twitcher/lib/http/buffered_http_client.gd")

## Each test listens on its own port so a socket lingering from the previous
## test can never make the next one flaky.
static var _next_port := 48131

var _port: int
var _server: HTTPServer
## Connections that sent a request and now wait for an answer.
var _open: Array[HTTPServer.Client] = []
## Connections we already counted, so a request arriving in two TCP chunks is
## counted once.
var _seen: Array[HTTPServer.Client] = []
## Request paths in the order they hit the server.
var _paths: PackedStringArray = []
## How many of the upcoming requests get their connection dropped without an answer.
var _drop_next := 0


func before_each() -> void:
	super()
	_open = []
	_seen = []
	_paths = []
	_drop_next = 0
	_port = _next_port
	_next_port += 1
	_server = HttpServer.create(_port, "127.0.0.1")
	add_child_autofree(_server)
	_server.request_received.connect(_on_request)
	_server.start_listening()


func after_each() -> void:
	_server.stop_listening()
	super()


#region Helpers

func _url(path: String) -> String:
	return "http://127.0.0.1:%d/%s" % [_port, path]


func _make_client(max_parallel: int, max_errors: int = -1) -> BufferedHTTPClient:
	var client: BufferedHTTPClient = Subject.new()
	client.max_parallel_requests = max_parallel
	client.max_error_count = max_errors
	add_child_autofree(client)
	return client


func _on_request(client: HTTPServer.Client) -> void:
	var peer := client.peer
	var data: Array = peer.get_data(peer.get_available_bytes())
	if _seen.has(client):
		return
	_seen.append(client)
	var request_line: String = (data[1] as PackedByteArray).get_string_from_utf8().get_slice("\r\n", 0)
	_paths.append(request_line.get_slice(" ", 1).trim_prefix("/"))
	if _drop_next > 0:
		_drop_next -= 1
		peer.disconnect_from_host()
		return
	_open.append(client)


func _received() -> int:
	return _seen.size()


## Answers every connection that is waiting for a response with 200 OK.
func _respond_all() -> void:
	for client: HTTPServer.Client in _open:
		_server.send_response(client, "200 OK", "ok".to_utf8_buffer())
	_open = []


## Waits until the server has seen [param count] requests, or gives up after [param timeout] seconds.
func _wait_until_received(count: int, timeout := 3.0) -> void:
	var deadline := Time.get_ticks_msec() + int(timeout * 1000)
	while _received() < count and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame


## Waits until [param request] has a response, or gives up after [param timeout] seconds.
func _wait_for_response(client: BufferedHTTPClient, request: BufferedHTTPClient.RequestData, timeout := 5.0) -> BufferedHTTPClient.ResponseData:
	var deadline := Time.get_ticks_msec() + int(timeout * 1000)
	while not client.responses.has(request) and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	if not client.responses.has(request):
		fail_test("No response for %s within %ss" % [request.path, timeout])
		return null
	return await client.wait_for_request(request)

#endregion


func test_default_limit_is_sequential() -> void:
	var client: BufferedHTTPClient = Subject.new()
	autofree(client)
	assert_eq(client.max_parallel_requests, 1, "API clients must not fire requests in parallel by default")


func test_sequential_client_puts_only_one_request_on_the_wire() -> void:
	var client := _make_client(1)
	var a := client.request(_url("a"), HTTPClient.METHOD_GET, {}, "")
	var b := client.request(_url("b"), HTTPClient.METHOD_GET, {}, "")
	var c := client.request(_url("c"), HTTPClient.METHOD_GET, {}, "")
	assert_eq(client.queued_request_size(), 3, "all three requests are pending")

	await _wait_until_received(1)
	await wait_seconds(0.3)
	assert_eq(_received(), 1, "only one request may be on the wire")
	assert_eq(client.active_requests.size(), 1)
	assert_eq(client.queued_requests.size(), 2)

	_respond_all()
	await _wait_until_received(2)
	await wait_seconds(0.3)
	assert_eq(_received(), 2, "the second request starts once the first one is answered")

	_respond_all()
	await _wait_until_received(3)
	_respond_all()

	assert_eq(_paths, PackedStringArray(["a", "b", "c"]), "requests are sent in the order they were queued")
	for request: BufferedHTTPClient.RequestData in [a, b, c]:
		var response := await _wait_for_response(client, request)
		if response != null:
			assert_eq(response.response_code, 200, "%s answered" % request.path)
	assert_eq(client.queued_request_size(), 0, "nothing pending after all responses were consumed")
	assert_false(client.processing)


func test_parallel_limit_allows_that_many_requests_at_once() -> void:
	var client := _make_client(2)
	client.request(_url("a"), HTTPClient.METHOD_GET, {}, "")
	client.request(_url("b"), HTTPClient.METHOD_GET, {}, "")
	client.request(_url("c"), HTTPClient.METHOD_GET, {}, "")

	await _wait_until_received(2)
	await wait_seconds(0.3)
	assert_eq(_received(), 2, "two requests may be on the wire")
	assert_eq(client.queued_requests.size(), 1)

	_respond_all()
	await _wait_until_received(3)
	assert_eq(_received(), 3, "the third request follows as soon as a slot is free")
	_respond_all()
	await wait_for_signal(client.request_done, 5)


func test_zero_limit_means_unlimited() -> void:
	var client := _make_client(0)
	for i: int in 5:
		client.request(_url(str(i)), HTTPClient.METHOD_GET, {}, "")

	await _wait_until_received(5)
	assert_eq(_received(), 5, "no limit: everything goes out immediately")
	assert_eq(client.queued_requests.size(), 0)
	_respond_all()
	await wait_for_signal(client.request_done, 5)


## Before PR #130 an exhausted retry budget just returned, leaving `wait_for_request`
## hanging forever and (now) the slot occupied for good.
func test_exhausted_retries_deliver_an_error_response_and_free_the_slot() -> void:
	var client := _make_client(1, 0)
	_drop_next = 1
	var a := client.request(_url("a"), HTTPClient.METHOD_GET, {}, "")
	var b := client.request(_url("b"), HTTPClient.METHOD_GET, {}, "")

	var response_a := await _wait_for_response(client, a)
	if response_a == null:
		return
	assert_true(response_a.error, "dropped connection is reported as error")
	assert_eq(response_a.result, HTTPRequest.RESULT_CONNECTION_ERROR)
	assert_eq(a.retry, 0, "max_error_count 0 means no retry at all")

	await _wait_until_received(2)
	assert_eq(_received(), 2, "the failed request released its slot for the next one")
	_respond_all()
	var response_b := await _wait_for_response(client, b)
	if response_b != null:
		assert_eq(response_b.response_code, 200)


## The retry used to reconnect `request_completed` bound to the new HTTPRequest node
## instead of the RequestData, so a retried request could never be completed.
func test_retry_completes_the_original_request() -> void:
	var client := _make_client(1, 1)
	_drop_next = 1
	var a := client.request(_url("a"), HTTPClient.METHOD_GET, {}, "")

	await _wait_until_received(2, 6.0) # first attempt fails, retry follows after a 1s backoff
	assert_eq(_received(), 2, "the request was sent a second time")
	_respond_all()

	var response := await _wait_for_response(client, a)
	if response == null:
		return
	assert_eq(response.response_code, 200, "the retry answers the original request")
	assert_false(response.error)
	assert_eq(a.retry, 1)
	assert_eq(client.active_requests.size(), 0, "the retried request released its slot")
	await get_tree().process_frame # queue_free is deferred
	assert_eq(client.get_child_count(), 0, "the HTTPRequest nodes of the failed attempt and of the retry were both freed")
