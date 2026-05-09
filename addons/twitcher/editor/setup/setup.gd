@tool
extends Window

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const PageGameAuthorization = preload("uid://cppbrsn4ohgvf")
const PageOverlayAuthorization = preload("uid://dxql15j5ornlc")


@onready var overlay: Button = %Overlay
@onready var game: Button = %Game

@onready var close: Button = %Close
@onready var startup_check: CheckButton = %StartupCheck

@onready var type_selection: VBoxContainer = %TypeSelection
@onready var overlay_setup: VBoxContainer = %OverlaySetup
@onready var game_setup: VBoxContainer = %GameSetup

@onready var overlay_authorization: PageOverlayAuthorization = %OverlayAuthorization
@onready var game_authorization: PageGameAuthorization = %GameAuthorization


func _ready():
	close_requested.connect(_on_close)
	close.pressed.connect(_on_close)
	startup_check.toggled.connect(_on_toggle_startup_check)
	startup_check.button_pressed = TwitchEditorSettings.show_setup_on_startup
	overlay_authorization.changed.connect(_on_changed)
	game_authorization.changed.connect(_on_changed)
	game.pressed.connect(_on_game_pressed)
	overlay.pressed.connect(_on_overlay_pressed)



func _on_game_pressed() -> void:
	type_selection.hide()
	game_setup.show()


func _on_overlay_pressed() -> void:
	type_selection.hide()
	overlay_setup.show()


func _on_changed() -> void:
	close.text = close.text.trim_suffix(" (unsaved changes)")
	if overlay_authorization.has_changes or game_authorization.has_changes:
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
	if overlay_authorization.has_changes or game_authorization.has_changes:
		var popup = ConfirmationDialog.new()
		popup.dialog_text = "You have unsaved changes! Are you sure to close the setup?"
		popup.confirmed.connect(queue_free)
		add_child(popup)
		popup.popup_centered()
	else:
		queue_free()
