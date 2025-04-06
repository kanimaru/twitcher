@tool
extends Window

const AuthorizationEditorProperty = preload("res://addons/twitcher/editor/inspector/authorization_editor_property.gd")
const PageUseCase = preload("res://addons/twitcher/editor/setup/page_use_case.gd")

#Setup
#- Check for Authorization Stuff
#-- Client Credentials
#-- Editor Token
#-- Scopes
#- Auth Button
#- Create Base Node Structure

@onready var use_case: PageUseCase = %UseCase as PageUseCase



func _ready(): 
	close_requested.connect(_on_close)
	#use_case.connect(&"use_case_changed", _on_change_use_case)
	pass


func _on_change_use_case(use_case: PageUseCase.UseCase) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_on_close()


func _on_close() -> void:
	queue_free()
