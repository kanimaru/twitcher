@tool
extends CheckButton

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

func _ready() -> void:
	button_pressed = TwitchEditorSettings.load_current_twitch_user
	toggled.connect(_on_toggle_load_current_twitch_user)
	
	
func _on_toggle_load_current_twitch_user(toggled_on: bool) -> void:
	TwitchEditorSettings.load_current_twitch_user = toggled_on
