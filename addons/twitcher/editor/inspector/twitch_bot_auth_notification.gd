@tool
extends Window

const TWITCH_BOT_SCOPES = preload("uid://b8735fmqjt8up")
const TestCredentials = preload("uid://13afcys4swos")

@onready var cancel: Button = %Cancel
@onready var test_credentials: TestCredentials = %TestCredentials


func _ready() -> void:
	test_credentials.scopes = TWITCH_BOT_SCOPES
	cancel.pressed.connect(_close)
	close_requested.connect(_close)
	
	
func _close() -> void:
	hide()
