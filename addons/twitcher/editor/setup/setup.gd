@tool
extends Window

const PageUseCase = preload("res://addons/twitcher/editor/setup/page_use_case.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const PageAuthorization = preload("res://addons/twitcher/editor/setup/page_authorization.gd")

#Setup
#- Check for Authorization Stuff
#-- Client Credentials
#-- Editor Token
#-- Scopes
#- Auth Button
#- Create Base Node Structure

@onready var authorization: PageAuthorization = %Authorization
@onready var use_case: PageUseCase = %UseCase as PageUseCase
@onready var close: Button = %Close
@onready var startup_check: CheckButton = %StartupCheck


func _ready(): 
	close_requested.connect(_on_close)
	close.pressed.connect(_on_close)
	startup_check.toggled.connect(_on_toggle_startup_check)
	startup_check.button_pressed = TwitchEditorSettings.show_setup_on_startup
	use_case.changed.connect(_on_changed)
	authorization.changed.connect(_on_changed)
	pass


func _on_changed() -> void:
	close.text = close.text.trim_suffix(" (unsaved changes)")
	if use_case.has_changes || authorization.has_changes:
		close.text = close.text + " (unsaved changes)"


func _on_toggle_startup_check(toggle_on: bool) -> void:
	TwitchEditorSettings.show_setup_on_startup = toggle_on
	ProjectSettings.save()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_on_close()


func _on_close() -> void:
	if use_case.has_changes || authorization.has_changes:
		var popup = ConfirmationDialog.new()
		popup.dialog_text = "You have unsaved changes! Are you sure to close the setup?"
		popup.confirmed.connect(queue_free)
		add_child(popup)
		popup.popup_centered()
	else:
		queue_free()
