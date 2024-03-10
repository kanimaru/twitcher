extends Node

@onready var start_button: Button = %Start
@onready var connect_button: Button = %Connect
@onready var stop_button: Button = %Stop
@onready var connection_status: Label = %ConnectionStatus
@onready var send: Button = %Send

var server: HTTPServer;
var client: BufferedHTTPClient;

func _ready() -> void:
	server = HTTPServer.new(12233);
	server.add_request_handler(_process_request);
	connect_button.pressed.connect(_connect_to_server);
	start_button.pressed.connect(_start_server);
	stop_button.pressed.connect(_stop_server);
	send.pressed.connect(_send)

func _process_request(server: HTTPServer, client: HTTPServer.Client) -> void:
	server.send_response(client.peer, "200", "OK".to_ascii_buffer());

func _send() -> void:
	var req = client.request("/test", HTTPClient.METHOD_GET, {}, "");
	var resp = await client.wait_for_request(req);
	var response: PackedByteArray = resp.response_data;
	print(response.get_string_from_ascii());

func _status_changed(connected: bool):
	if connection_status: connection_status.text = "Conntected"
	else: connection_status.text = "Disconntected"

func _connect_to_server():
	client = BufferedHTTPClient.new("127.0.0.1", 12233);
	client.connection_status_changed.connect(_status_changed);

func _start_server() -> void:
	server.start();
	pass

func _stop_server() -> void:
	server.stop();
	pass

