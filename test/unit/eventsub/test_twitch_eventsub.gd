## Tests for [TwitchEventsub].
##
## Subscribing only appends to the subscription list and queues an action that
## waits for a session, so the list itself is observable without a connection.
##
## Everything about the connection runs against [WebsocketTestServer] instances
## on the loopback interface, which play Twitch by sending [EventsubMessages].
## No subscription is made in those tests, so no HTTP request is sent.
extends TwitcherTest

## Upper bound for anything that needs the network, generous for slow CI runners.
const TIMEOUT: float = 3.0

const FOLLOW_CONDITION: Dictionary = {
	&"broadcaster_user_id": "123",
	&"moderator_user_id": "456",
}

## [keepalive timeout announced by Twitch, silence in ms, timed out]
const KEEPALIVE_PARAMS: Array = [
	[10, 15000, false],
	[10, 15001, true],
	[30, 45000, false],
	[30, 45001, true],
	# Below the lower bound of 10 s.
	[1, 14000, false],
	[1, 15001, true],
]


func _make_eventsub() -> TwitchEventsub:
	return add_child_autofree(TwitchEventsub.new())


func _make_server() -> WebsocketTestServer:
	var server: WebsocketTestServer = add_child_autofree(WebsocketTestServer.new())
	server.start()
	return server


## An eventsub connected to [param server] with the session [code]first[/code].
func _make_connected_eventsub(server: WebsocketTestServer) -> TwitchEventsub:
	var eventsub: TwitchEventsub = _make_eventsub()
	eventsub.eventsub_live_server_url = server.url()
	eventsub.get_client().reconnect_base_delay = 0.0
	eventsub.open_connection()
	assert_true(await _await_peers(server, 1), "test setup: the eventsub has to connect")
	server.broadcast(EventsubMessages.welcome("first"))
	assert_true(await _await_session(eventsub, "first"), "test setup: no session")
	return eventsub


func _await_peers(server: WebsocketTestServer, count: int) -> bool:
	return await wait_until(func() -> bool: return server.open_peers().size() == count, TIMEOUT)


func _await_session(eventsub: TwitchEventsub, session_id: String) -> bool:
	return await wait_until(func() -> bool:
		return eventsub.session != null and eventsub.session.id == session_id, TIMEOUT)


## A URL nobody listens on, so connecting to it fails right away.
func _dead_url() -> String:
	var server: WebsocketTestServer = _make_server()
	var url: String = server.url()
	server.stop()
	return url


func _subscribe_follows(eventsub: TwitchEventsub, count: int) -> void:
	for index: int in count:
		var condition: Dictionary = FOLLOW_CONDITION.duplicate()
		condition[&"broadcaster_user_id"] = str(index)
		eventsub.subscribe(TwitchEventsubConfig.create(
				TwitchEventsubDefinition.CHANNEL_FOLLOW, condition))


#region Unsetup

## Regression test: [method TwitchEventsub.do_unsetup] iterated the subscription
## list while [method TwitchEventsub.unsubscribe] erased from it, so every second
## subscription was skipped and stayed active at Twitch after logging out.
func test_unsetup_unsubscribes_every_subscription() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()
	_subscribe_follows(eventsub, 4)

	eventsub.do_unsetup()

	assert_eq(eventsub.get_subscriptions().size(), 0,
		"every subscription has to be removed, not every second one")

#endregion


#region Server URLs

## Regression test: the URLs were copied to the clients in [code]_init[/code]
## only. Exported values are assigned afterwards, so a proxy configured in the
## inspector was never used.
func test_the_live_server_url_is_applied_to_the_client() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()

	eventsub.eventsub_live_server_url = "ws://127.0.0.1:1/proxy"

	assert_eq(eventsub.get_client().connection_url, "ws://127.0.0.1:1/proxy")


func test_the_test_server_url_is_applied_to_the_test_client() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()

	eventsub.eventsub_test_server_url = "ws://127.0.0.1:2/cli"

	assert_eq(eventsub.get_test_client().connection_url, "ws://127.0.0.1:2/cli")


func test_a_url_from_a_scene_file_is_applied_to_the_client() -> void:
	var scene: PackedScene = PackedScene.new()
	var original: TwitchEventsub = autofree(TwitchEventsub.new())
	original.eventsub_live_server_url = "ws://127.0.0.1:3/scene"
	scene.pack(original)

	var loaded: TwitchEventsub = add_child_autofree(scene.instantiate())

	assert_eq(loaded.get_client().connection_url, "ws://127.0.0.1:3/scene")

#endregion


#region Reconnect handover

func test_a_reconnect_moves_the_session_to_the_new_server() -> void:
	var old_server: WebsocketTestServer = _make_server()
	var new_server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(old_server)
	var old_client: WebsocketClient = eventsub.get_client()
	# Lambdas must not capture the client itself, they complain once it got freed.
	var old_id: int = old_client.get_instance_id()

	old_server.broadcast(EventsubMessages.reconnect("first", new_server.url()))
	assert_true(await _await_peers(new_server, 1), "the reconnect URL has to be opened")
	new_server.broadcast(EventsubMessages.welcome("second"))

	assert_true(await _await_session(eventsub, "second"), "the new session has to take over")
	assert_ne(eventsub.get_client().get_instance_id(), old_id,
			"the new connection is the current one now")
	var is_freed: Callable = func() -> bool: return not is_instance_id_valid(old_id)
	assert_true(await wait_until(is_freed, TIMEOUT), "the replaced client has to be freed")


## The reconnect URL is only valid for this one handover, a later reconnect has
## to start over at the live server.
func test_the_new_connection_reconnects_to_the_live_server() -> void:
	var old_server: WebsocketTestServer = _make_server()
	var new_server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(old_server)

	old_server.broadcast(EventsubMessages.reconnect("first", new_server.url()))
	assert_true(await _await_peers(new_server, 1))
	new_server.broadcast(EventsubMessages.welcome("second"))
	assert_true(await _await_session(eventsub, "second"))

	assert_eq(eventsub.get_client().connection_url, old_server.url())


## Regression test: the handover waited for [signal TwitchEventsub.session_id_received],
## which any welcome emits. A welcome on the old connection completed it and
## swapped to a connection that had no session yet.
func test_a_welcome_on_the_old_connection_does_not_complete_the_handover() -> void:
	var old_server: WebsocketTestServer = _make_server()
	var new_server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(old_server)
	var old_client: WebsocketClient = eventsub.get_client()
	old_server.broadcast(EventsubMessages.reconnect("first", new_server.url()))
	assert_true(await _await_peers(new_server, 1))

	old_server.broadcast(EventsubMessages.welcome("stale"))
	await wait_process_frames(10)

	assert_eq(eventsub.session.id, "first", "the old connection can't start a new session")
	assert_eq(eventsub.get_client(), old_client, "the handover is still waiting")


func test_a_failed_handover_keeps_the_current_connection() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)
	var client: WebsocketClient = eventsub.get_client()

	server.broadcast(EventsubMessages.reconnect("first", _dead_url()))

	var is_dropped: Callable = func() -> bool: return eventsub._swap_over_client == null
	assert_true(await wait_until(is_dropped, TIMEOUT),
			"the handover has to be dropped when its connection fails")
	assert_eq(eventsub.get_client(), client)
	assert_true(client.is_open, "the current connection is still fine")
	assert_eq(eventsub.session.id, "first")


func test_closing_drops_a_pending_handover() -> void:
	var old_server: WebsocketTestServer = _make_server()
	var new_server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(old_server)
	old_server.broadcast(EventsubMessages.reconnect("first", new_server.url()))
	assert_true(await _await_peers(new_server, 1))

	eventsub.close_connection()

	assert_null(eventsub._swap_over_client)
	assert_true(await _await_peers(new_server, 0), "the handover connection has to be closed")


func test_frames_of_a_replaced_client_are_ignored() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()
	var replaced: WebsocketClient = autofree(WebsocketClient.new())
	watch_signals(eventsub)

	eventsub._data_received(EventsubMessages.keepalive().to_utf8_buffer(), replaced)

	assert_signal_not_emitted(eventsub, "message_received")

#endregion


#region Keepalive watchdog

func _session(keepalive_timeout_seconds: int) -> TwitchEventsub.Session:
	return TwitchEventsub.Session.new({
		"id": "session",
		"status": "connected",
		"keepalive_timeout_seconds": keepalive_timeout_seconds,
		"reconnect_url": null,
		"connected_at": "",
	})


func test_keepalive_times_out_after_the_announced_timeout_and_grace(
		params: Array = use_parameters(KEEPALIVE_PARAMS)) -> void:
	var eventsub: TwitchEventsub = _make_eventsub()
	eventsub.session = _session(params[0])
	eventsub.last_keepalive = 1000

	assert_eq(eventsub._keepalive_timed_out(1000 + params[1]), params[2],
			"%s s keepalive after %s ms silence" % [params[0], params[1]])


## Regression test: [member TwitchEventsub.last_keepalive] was recorded but never
## checked. A connection that died without a close (sleep, network switch) left
## the socket open on our side and the eventsub silently stopped receiving.
func test_a_silent_connection_gets_replaced() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)

	eventsub._check_keepalive(eventsub.last_keepalive + 15001)

	assert_true(eventsub.get_client().is_closed, "a dead peer can't answer a close handshake")
	assert_null(eventsub.session, "the session of the dead connection is gone")
	var reconnected: Callable = func() -> bool:
		return server.peers.size() == 2 and server.open_peers().size() == 1
	assert_true(await wait_until(reconnected, TIMEOUT), "the eventsub has to reconnect")


func test_a_quiet_connection_within_the_grace_stays() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)

	eventsub._check_keepalive(eventsub.last_keepalive + 15000)

	assert_true(eventsub.get_client().is_open)
	assert_eq(eventsub.session.id, "first")


func test_a_closed_eventsub_is_not_reconnected_by_the_watchdog() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)
	var last_keepalive: int = eventsub.last_keepalive

	eventsub.close_connection()
	eventsub._check_keepalive(last_keepalive + 60000)

	assert_false(eventsub.get_client().auto_reconnect, "closing on purpose has to stick")


func test_a_keepalive_resets_the_clock() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)
	eventsub.last_keepalive = 1

	server.broadcast(EventsubMessages.keepalive())

	assert_true(await wait_until(func() -> bool: return eventsub.last_keepalive > 1, TIMEOUT))


## Regression test: duplicates returned before the clock was reset, although
## they prove just as well that the connection is alive.
func test_a_duplicate_frame_resets_the_clock_too() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)
	server.broadcast(EventsubMessages.keepalive("duplicate"))
	assert_true(await wait_until(func() -> bool:
		return eventsub._seen_messages.has("duplicate"), TIMEOUT))
	eventsub.last_keepalive = 1

	server.broadcast(EventsubMessages.keepalive("duplicate"))

	assert_true(await wait_until(func() -> bool: return eventsub.last_keepalive > 1, TIMEOUT))


func test_unpausing_restarts_the_clock() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()
	eventsub.last_keepalive = 1

	eventsub.notification(Node.NOTIFICATION_UNPAUSED)

	assert_gt(eventsub.last_keepalive, 1, "the silence while paused doesn't count")


func test_unpausing_without_a_session_keeps_the_clock_stopped() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()

	eventsub.notification(Node.NOTIFICATION_UNPAUSED)

	assert_eq(eventsub.last_keepalive, 0)


func test_the_clients_read_before_the_watchdog_runs() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()

	assert_lt(eventsub.get_client().process_priority, eventsub.process_priority,
			"lower priorities process first within a frame")

#endregion


#region Lifecycle

## Regression test: closing skipped clients that were already closed, but a
## closed client can still be waiting for its next reconnect attempt. It kept
## reconnecting after the eventsub got closed.
func test_closing_stops_a_pending_reconnect() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = _make_eventsub()
	eventsub.eventsub_live_server_url = server.url()
	eventsub.get_client().reconnect_base_delay = 30.0
	eventsub.open_connection()
	assert_true(eventsub.get_client().is_closed, "test setup: the attempt has to wait")

	eventsub.close_connection()

	assert_false(eventsub.get_client().auto_reconnect, "the client must not reconnect")
	assert_false(eventsub.get_client()._is_already_connecting, "the pending attempt has to end")


func test_leaving_the_tree_ends_the_session() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)

	remove_child(eventsub)

	assert_null(eventsub.session, "a detached eventsub has no connection to a session")
	add_child(eventsub)


func test_a_reattached_eventsub_reconnects() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)

	remove_child(eventsub)
	add_child(eventsub)

	var reconnected: Callable = func() -> bool:
		return server.peers.size() == 2 and server.open_peers().size() == 1
	assert_true(await wait_until(reconnected, TIMEOUT), "the eventsub has to reconnect")
	server.broadcast(EventsubMessages.welcome("again"))
	assert_true(await _await_session(eventsub, "again"), "a new session has to start")


## Regression test: the clients are created in [code]_init[/code] and only
## become children in [code]_ready[/code], so an eventsub that never entered the
## tree leaked both of them.
func test_freeing_an_eventsub_outside_the_tree_frees_its_clients() -> void:
	var eventsub: TwitchEventsub = TwitchEventsub.new()
	var client_id: int = eventsub.get_client().get_instance_id()
	var test_client_id: int = eventsub.get_test_client().get_instance_id()

	eventsub.free()

	assert_false(is_instance_id_valid(client_id), "the client leaked")
	assert_false(is_instance_id_valid(test_client_id), "the test client leaked")


func test_freeing_an_eventsub_whose_test_client_is_gone_is_fine() -> void:
	var eventsub: TwitchEventsub = TwitchEventsub.new()
	eventsub.get_test_client().free()

	eventsub.free()

	pass_test("freeing must not touch the freed test client")

#endregion


#region Duplicates

func test_a_duplicate_message_is_processed_once() -> void:
	var server: WebsocketTestServer = _make_server()
	var eventsub: TwitchEventsub = await _make_connected_eventsub(server)
	watch_signals(eventsub)

	server.broadcast(EventsubMessages.keepalive("twice"))
	server.broadcast(EventsubMessages.keepalive("twice"))
	server.broadcast(EventsubMessages.keepalive("other"))
	assert_true(await wait_until(func() -> bool:
		return eventsub._seen_messages.has("other"), TIMEOUT))

	assert_signal_emit_count(eventsub, "message_received", 2, "the duplicate has to be dropped")


func test_the_duplicate_window_follows_the_setting() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()

	eventsub.ignore_message_eventsub_in_seconds = 5

	assert_eq(eventsub._seen_messages.window_msec, 5000)

#endregion
