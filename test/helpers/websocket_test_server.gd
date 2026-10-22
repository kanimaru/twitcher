## A WebSocket server on the loopback interface for tests of [WebsocketClient] and
## everything built on it.
##
## Listens on a port the OS picks, so parallel or lingering sockets can never make
## a test flaky. It's polled from [method Node._process], add it to the tree:
##
## [codeblock]
## var server: WebsocketTestServer = add_child_autofree(WebsocketTestServer.new())
## client.connection_url = server.start()
## await wait_until(func() -> bool: return server.open_peers().size() == 1, 2.0)
## server.broadcast("hello")
## [/codeblock]
##
## Every accepted connection stays in [member peers] after it closed, so tests can
## count how often a client connected.
class_name WebsocketTestServer
extends Node

## A client finished the WebSocket handshake.
signal peer_connected(peer: WebSocketPeer)
## A client sent a text frame.
signal text_received(peer: WebSocketPeer, text: String)

## Every accepted connection, oldest first, open or not.
var peers: Array[WebSocketPeer] = []
## Every text frame received, oldest first.
var received: PackedStringArray = []

var _tcp: TCPServer = TCPServer.new()
## Last seen state per peer, to report each handshake once.
var _states: Dictionary[WebSocketPeer, WebSocketPeer.State] = {}


func _process(_delta: float) -> void:
	poll()


func _exit_tree() -> void:
	stop()


## Starts listening and returns the URL a client has to connect to.
func start() -> String:
	var err: Error = _tcp.listen(0, "127.0.0.1")
	assert(err == OK, "test server couldn't listen: %s" % error_string(err))
	return url()


func url() -> String:
	return "ws://127.0.0.1:%d" % _tcp.get_local_port()


## Accepts pending connections and processes every peer once. Called every
## frame; call it by hand to process without waiting for one.
func poll() -> void:
	while _tcp.is_listening() and _tcp.is_connection_available():
		var peer: WebSocketPeer = WebSocketPeer.new()
		peer.accept_stream(_tcp.take_connection())
		peers.append(peer)
		_states[peer] = WebSocketPeer.STATE_CONNECTING
	for peer: WebSocketPeer in peers:
		_poll_peer(peer)


## Peers that are currently open.
func open_peers() -> Array[WebSocketPeer]:
	var result: Array[WebSocketPeer] = []
	for peer: WebSocketPeer in peers:
		if peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			result.append(peer)
	return result


## Sends [param text] to every open peer.
func broadcast(text: String) -> void:
	for peer: WebSocketPeer in open_peers():
		peer.send_text(text)


## Closes every peer without a handshake and stops listening.
func stop() -> void:
	for peer: WebSocketPeer in peers:
		peer.close(-1)
	_tcp.stop()


func _poll_peer(peer: WebSocketPeer) -> void:
	peer.poll()
	var state: WebSocketPeer.State = peer.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN and _states[peer] != WebSocketPeer.STATE_OPEN:
		peer_connected.emit(peer)
	_states[peer] = state
	while state == WebSocketPeer.STATE_OPEN and peer.get_available_packet_count() > 0:
		var text: String = peer.get_packet().get_string_from_utf8()
		received.append(text)
		text_received.emit(peer, text)
