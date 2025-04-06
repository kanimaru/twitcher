@tool
extends Window

const PageUseCase = preload("res://addons/twitcher/editor/setup/page_use_case.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

#Setup
#- Check for Authorization Stuff
#-- Client Credentials
#-- Editor Token
#-- Scopes
#- Auth Button
#- Create Base Node Structure

@onready var use_case: PageUseCase = %UseCase as PageUseCase
@onready var close: Button = %Close
@onready var startup_check: CheckButton = %StartupCheck



func _ready(): 
	close_requested.connect(_on_close)
	close.pressed.connect(_on_close)
	startup_check.toggled.connect(_on_toggle_startup_check)
	startup_check.button_pressed = TwitchEditorSettings.show_setup_on_startup
	#use_case.connect(&"use_case_changed", _on_change_use_case)
	pass


func _on_change_use_case(use_case: PageUseCase.UseCase) -> void:
	pass


func _on_toggle_startup_check(toggle_on: bool) -> void:
	TwitchEditorSettings.show_setup_on_startup = toggle_on
	ProjectSettings.save()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_on_close()


func _on_close() -> void:
	queue_free()
