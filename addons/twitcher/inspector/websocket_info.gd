@tool
extends GridContainer

@export var websocket: WebsocketClient:
	set = _update_websocket

@onready var title: Label = %Title
@onready var connection_state: CheckBox = %ConnectionState
@onready var connect: Button = %Connect
@onready var disconnect: Button = %Disconnect


func _ready() -> void:
	connect.pressed.connect(_on_connect)
	disconnect.pressed.connect(_on_disconnect)


func _update_websocket(val: WebsocketClient) -> void:
	if websocket != null:
		websocket.connection_state_changed.disconnect(_on_connection_state_changed)

	websocket = val

	title.text = websocket.connection_url
	websocket.connection_state_changed.connect(_on_connection_state_changed)
	_update_connection_state(websocket.connection_state)


func _on_connection_state_changed(state : WebSocketPeer.State) -> void:
	_update_connection_state(state)


func _update_connection_state(state : WebSocketPeer.State) -> void:
	match state:
		WebSocketPeer.State.STATE_CONNECTING:
			connection_state.text = "Connecting"
			connection_state.button_pressed = false
			connect.disabled = true
			disconnect.disabled = true
		WebSocketPeer.State.STATE_OPEN:
			connection_state.text = "Open"
			connection_state.button_pressed = true
			connect.disabled = true
			disconnect.disabled = false
		WebSocketPeer.State.STATE_CLOSING:
			connection_state.text = "Closing"
			connection_state.button_pressed = false
			connect.disabled = true
			disconnect.disabled = true
		WebSocketPeer.State.STATE_CLOSED:
			connection_state.text = "Closed"
			connection_state.button_pressed = false
			connect.disabled = false
			disconnect.disabled = true


func _on_connect() -> void:
	websocket.open_connection()


func _on_disconnect() -> void:
	websocket.close()
