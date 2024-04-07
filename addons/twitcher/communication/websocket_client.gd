extends RefCounted

## Advanced websocket client that automatically reconnects to the server
class_name WebsocketClient

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_WEBSOCKET);

signal message_received(message: PackedByteArray);

signal connection_state_changed(state : WebSocketPeer.State);

var peer: WebSocketPeer = WebSocketPeer.new();
var connection_state : WebSocketPeer.State = WebSocketPeer.STATE_CLOSED:
	set(new_state):
		if new_state != connection_state:
			connection_state_changed.emit(new_state);
		connection_state = new_state;

var connection_url: String;
var tries: int;
var connecting: bool;

func _init():
	Engine.get_main_loop().process_frame.connect(_poll);

func connect_to(url: String) -> void:
	log.i("Set connection to %s" % url);
	connection_url = url;

func establish_connection() -> void:
	if connecting: return;
	connecting = true;
	var wait_time = pow(2, tries);
	log.d("Wait %s before connecting" % [wait_time]);
	await Engine.get_main_loop().create_timer(wait_time).timeout;
	log.i("Connecting to %s" % connection_url);
	var err = peer.connect_to_url(connection_url);
	if err != OK:
		log.e("Coulnd't connect to %s cause of %s" % [connection_url, error_string(err)])
	tries+=1;
	connecting = false;

func send_text(message: String) -> void:
	peer.send_text(message);

func _poll() -> void:
	if(connection_url == ""): return;

	var state := peer.get_ready_state()
	if state == WebSocketPeer.STATE_CLOSED: establish_connection();
	peer.poll()
	_handle_state_changes(state);
	connection_state = state;
	if state == WebSocketPeer.STATE_OPEN:
		_read_data();

func _handle_state_changes(state: WebSocketPeer.State) -> void:
	if connection_state != WebSocketPeer.STATE_OPEN && state == WebSocketPeer.STATE_OPEN:
		_on_open_connection();

	if connection_state != WebSocketPeer.STATE_CLOSED && state == WebSocketPeer.STATE_CLOSED:
		_on_close_connection();

func _on_open_connection():
	log.i("connected to %s" % connection_url);
	tries = 0;

func _on_close_connection():
	log.i("connection to %s was closed [%s]: %s" % [connection_url, peer.get_close_code(), peer.get_close_reason()]);

func _read_data() -> void:
	while (peer.get_available_packet_count()):
		message_received.emit(peer.get_packet())

func close(status: int, message: String) -> void:
	peer.close(status, message);
