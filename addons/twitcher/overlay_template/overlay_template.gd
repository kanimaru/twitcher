extends Control

@onready var twitch_service: TwitchService = %TwitchService

func _ready() -> void:
	twitch_service.setup()
