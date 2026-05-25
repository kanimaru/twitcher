@tool
extends Window

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const PageGameAuthorization = preload("uid://cppbrsn4ohgvf")
const PageOverlayAuthorization = preload("uid://dxql15j5ornlc")
const TwitchTweens = preload("uid://duhsr84u352ef")

const PAGE_GAME_AUTHORIZATION = preload("uid://1luoys8urcb4")
const PAGE_OVERLAY_AUTHORIZATION = preload("uid://dm6jvnuikxtei")


@onready var overlay: Button = %Overlay
@onready var game: Button = %Game
@onready var bootstrap: Button = %Bootstrap
@onready var save: Button = %Save
@onready var close: Button = %Close
@onready var startup_check: CheckButton = %StartupCheck

@onready var type_selection: VBoxContainer = %TypeSelection
@onready var content: VBoxContainer = %Content

var _page: Node


func _ready():
	close_requested.connect(_on_close)
	close.pressed.connect(_on_close)
	startup_check.toggled.connect(_on_toggle_startup_check)
	startup_check.button_pressed = TwitchEditorSettings.show_setup_on_startup
	game.pressed.connect(_on_game_pressed)
	overlay.pressed.connect(_on_overlay_pressed)
	save.pressed.connect(_on_save)
	bootstrap.pressed.connect(_on_bootstrap_pressed)
	save.hide()
	bootstrap.hide()
	_update_bootstrap()


func _on_game_pressed() -> void:
	_select_type(PAGE_GAME_AUTHORIZATION.instantiate())


func _on_overlay_pressed() -> void:
	_select_type(PAGE_OVERLAY_AUTHORIZATION.instantiate())


func _select_type(node: Node) -> void:
	type_selection.queue_free()
	_page = node
	_page.changed.connect(_on_changed)
	content.add_child(_page)
	save.show()
	bootstrap.show()


func _on_changed() -> void:
	close.text = close.text.trim_suffix(" (unsaved changes)")
	if _page.has_changes:
		close.text = close.text + " (unsaved changes)"


func _on_toggle_startup_check(toggle_on: bool) -> void:
	TwitchEditorSettings.show_setup_on_startup = toggle_on
	ProjectSettings.save()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_on_close()


func _on_save() -> void:
	if _page.save():
		TwitchTweens.flash(save, Color.GREEN)
		_update_bootstrap()
	else:
		TwitchTweens.flash(save, Color.RED)
	EditorInterface.get_resource_filesystem().scan()


func _on_close() -> void:
	if _page and _page.has_changes:
		var popup = ConfirmationDialog.new()
		popup.dialog_text = "You have unsaved changes! Are you sure to close the setup?"
		popup.confirmed.connect(queue_free)
		add_child(popup)
		popup.popup_centered.call_deferred()
	else:
		queue_free()


func _update_bootstrap() -> void:
	bootstrap.disabled = not (TwitchEditorSettings.game_oauth_setting and TwitchEditorSettings.game_oauth_setting.is_valid())


func _on_bootstrap_pressed() -> void:
	_page.bootstrap()
	close_requested.emit()
