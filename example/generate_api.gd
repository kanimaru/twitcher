extends Control

@onready var twitch_api_generator: TwitchAPIGenerator = %TwitchAPIGenerator

@onready var generate: Button = %Generate


func _ready() -> void:
	generate.pressed.connect(_on_generate)
	
	
func _on_generate() -> void:
	twitch_api_generator.generate_api()
