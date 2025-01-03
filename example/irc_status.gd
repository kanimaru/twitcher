extends Node

@export var twitch_service: TwitchService

@onready var connected: CheckBox = %Connected


func _ready() -> void:
	twitch_service.irc.connection_closed.connect(_on_closed)
	twitch_service.irc.connection_opened.connect(_on_open)


func _on_open() -> void:
	connected.button_pressed = true


func _on_closed() -> void:
	connected.button_pressed = false
