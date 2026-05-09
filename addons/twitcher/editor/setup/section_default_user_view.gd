@tool
extends VBoxContainer

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

@onready var config: GridContainer = %Config

@onready var default_user: UserConverter = %DefaultUser
@onready var load_current_twitch_user: CheckButton = %LoadCurrentTwitchUser
@onready var file_select: FileSelect = %FileSelect

var _default_user: TwitchUser
var _default_user_path: String

signal changed

func _ready() -> void:
	_default_user = TwitchEditorSettings.default_user.duplicate()
	_default_user_path = TwitchEditorSettings.get_default_user_path()
	file_select.path = _default_user_path

	load_current_twitch_user.toggled.connect(_on_toggle_load_current_twitch_user)
	load_current_twitch_user.button_pressed = TwitchEditorSettings.load_current_twitch_user
	default_user.changed.connect(_on_default_user_changed)
	file_select.file_selected.connect(_on_default_user_path_changed)


func _on_toggle_load_current_twitch_user(toggled_on: bool) -> void:
	TwitchEditorSettings.load_current_twitch_user = toggled_on
	config.visible = toggled_on


func _on_default_user_changed(user: TwitchUser) -> void:
	_default_user = user
	if is_node_ready(): changed.emit()


func _on_default_user_path_changed(path: String) -> void:
	_default_user_path = path
	if is_node_ready(): changed.emit()


func save() -> void:
	_default_user.take_over_path(_default_user_path)
	TwitchEditorSettings.default_user = _default_user
