## Tests for [WebsocketClient].
##
## The client talks to a real [WebsocketTestServer] on the loopback interface,
## because [WebSocketPeer] is native and can't be doubled in a meaningful way.
## [member WebsocketClient.reconnect_base_delay] is 0 unless a test needs a
## pending attempt, so connecting only takes a few frames.
extends TwitcherTest

## Upper bound for anything that needs the network, generous for slow CI runners.
const TIMEOUT: float = 3.0
## Long enough that a pending attempt never finishes within a test.
const PENDING_DELAY: float = 30.0

var _server: WebsocketTestServer
var _url: String


func before_each() -> void:
	super()
	_server = add_child_autofree(WebsocketTestServer.new())
	_url = _server.start()


func _make_client(in_tree: bool = true) -> WebsocketClient:
	var client: WebsocketClient = WebsocketClient.new()
	client.connection_url = _url
	client.reconnect_base_delay = 0.0
	if in_tree:
		add_child_autofree(client)
	else:
		autofree(client)
	return client


## Waits for the state the client reports with its signals. [member WebsocketClient.is_open]
## reads the socket directly and can be true a frame before
## [signal WebsocketClient.connection_established] got emitted.
func _await_open(client: WebsocketClient) -> bool:
	return await wait_until(func() -> bool:
		return client.connection_state == WebSocketPeer.STATE_OPEN, TIMEOUT)


func _await_connections(count: int) -> bool:
	return await wait_until(func() -> bool: return _server.peers.size() >= count, TIMEOUT)


func _connected_client() -> WebsocketClient:
	var client: WebsocketClient = _make_client()
	client.open_connection()
	assert_true(await _await_open(client), "the client has to connect to the test server")
	return client


#region Reconnect delay

func test_reconnect_delay_doubles_with_every_failed_attempt() -> void:
	var client: WebsocketClient = _make_client(false)
	client.reconnect_base_delay = 1.0

	assert_eq(client.get_reconnect_delay(0), 1.0)
	assert_eq(client.get_reconnect_delay(1), 2.0)
	assert_eq(client.get_reconnect_delay(3), 8.0)


## Regression test: the delay was [code]pow(2, tries)[/code] without a limit, so
## after a long outage the next attempt was hours away.
func test_reconnect_delay_is_capped(params: Variant = use_parameters([6, 10, 1000])) -> void:
	var tries: int = params
	var client: WebsocketClient = _make_client(false)
	client.reconnect_base_delay = 1.0

	assert_eq(client.get_reconnect_delay(tries), client.max_reconnect_delay)

#endregion


#region Connecting

func test_open_connection_connects_to_the_server() -> void:
	var client: WebsocketClient = _make_client()
	watch_signals(client)

	client.open_connection()

	assert_true(await _await_open(client), "the client has to connect")
	assert_signal_emitted(client, "connection_established")
	assert_true(await _await_connections(1), "the server has to see the connection")


func test_open_connection_outside_the_tree_connects_once_added() -> void:
	var client: WebsocketClient = _make_client(false)

	client.open_connection()
	add_child(client)

	assert_true(await _await_open(client), "entering the tree has to start the connection")


## Regression test: [method WebsocketClient.close] didn't cancel the attempt that
## was waiting for its delay. The client stayed "already connecting" until the
## wait ended, so opening it again in the meantime did nothing.
func test_close_cancels_the_pending_attempt() -> void:
	var client: WebsocketClient = _make_client()
	client.reconnect_base_delay = PENDING_DELAY
	client.open_connection()
	assert_true(client._is_already_connecting, "test setup: the attempt has to wait")

	client.close()

	assert_false(client._is_already_connecting, "the pending attempt has to end at once")
	client.reconnect_base_delay = 0.0
	client.open_connection()
	assert_true(await _await_open(client), "a new attempt must not wait for the cancelled one")


func test_a_cancelled_attempt_does_not_connect() -> void:
	var client: WebsocketClient = _make_client()
	client.reconnect_base_delay = PENDING_DELAY
	client.open_connection()

	client.close()
	await wait_process_frames(5)
	_server.poll()

	assert_eq(_server.peers.size(), 0, "a closed client must not connect")
	assert_true(client.is_closed)

#endregion


#region Abort

func test_abort_drops_the_connection_at_once() -> void:
	var client: WebsocketClient = await _connected_client()

	client.abort()

	assert_true(client.is_closed, "an abort must not wait for a close handshake")
	assert_false(client.auto_reconnect, "an abort stops reconnecting like close does")


func test_an_aborted_client_reconnects_when_asked_to() -> void:
	var client: WebsocketClient = await _connected_client()

	client.abort()
	client.auto_reconnect = true

	assert_true(await _await_connections(2), "turning auto_reconnect back on has to reconnect")
	assert_true(await _await_open(client))

#endregion


#region Leaving the tree

func test_leaving_the_tree_cancels_the_pending_attempt() -> void:
	var client: WebsocketClient = _make_client()
	client.reconnect_base_delay = PENDING_DELAY
	client.open_connection()

	remove_child(client)

	assert_false(client._is_already_connecting,
			"the attempt must end while the node still exists, not when its timer fires")


## Regression test: leaving the tree started a close handshake that a detached
## node never polls, so the socket hung in CLOSING and the client never came
## back after being added again.
func test_a_reattached_client_reconnects() -> void:
	var client: WebsocketClient = await _connected_client()

	remove_child(client)
	assert_true(client.is_closed, "a detached client can't poll, its socket has to be dropped")
	add_child(client)

	assert_true(await _await_connections(2), "the client has to reconnect after reattaching")
	assert_true(await _await_open(client))


func test_a_client_closed_while_detached_stays_closed() -> void:
	var client: WebsocketClient = await _connected_client()

	remove_child(client)
	client.close()
	add_child(client)
	await wait_process_frames(5)
	_server.poll()

	assert_eq(_server.peers.size(), 1, "an explicit close wins over resuming")
	assert_false(client.auto_reconnect)


func test_a_client_that_never_connected_stays_closed_after_reattaching() -> void:
	var client: WebsocketClient = _make_client()

	remove_child(client)
	add_child(client)
	await wait_process_frames(5)
	_server.poll()

	assert_eq(_server.peers.size(), 0)
	assert_false(client.auto_reconnect)

#endregion
