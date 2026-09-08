extends HBoxContainer

## Class will handle the devicecode process

const DEVICE_CODE_REQUEST = preload("uid://d0sdt48uvm1xq")
const DeviceCodeRequest = preload("uid://pcxtxepgjdgg")

@onready var connect_twitch: Button = %ConnectTwitch
@onready var twitch_status: Label = %TwitchStatus
@onready var twitch_service: TwitchService = %TwitchService

@export var token: OAuthToken

var _request_window: DeviceCodeRequest

var twitch_connected: bool:
	set = _set_twitch_connected


func _ready() -> void:
	token.load_tokens()
	twitch_connected = token.is_token_valid()
	connect_twitch.pressed.connect(_on_connect_pressed)
	twitch_service.device_code_requested.connect(_on_device_code_requested)
	token.authorized.connect(_on_authorized)


func _set_twitch_connected(val: bool) -> void:
	twitch_connected = val
	if not is_node_ready(): await ready
	twitch_status.text = "Status: Connected" if val else "Status: Disconnected"
	connect_twitch.text = "Disconnect Twitch Account" if val else "Connect Twitch Account"


func _on_connect_pressed() -> void:
	if not twitch_connected:
		await twitch_service.setup()
		twitch_connected = token.is_token_valid()
	else:
		await twitch_service.unsetup()
		twitch_connected = token.is_token_valid()


func _on_device_code_requested(device_code_request: OAuth.OAuthDeviceCodeResponse) -> void:
	_request_window = DEVICE_CODE_REQUEST.instantiate()
	# Use owner to not modify the size of the window with the VBoxContainer
	owner.add_child(_request_window)
	_request_window.open_request(device_code_request)


func _on_authorized() -> void:
	if _request_window:
		_request_window.close()
