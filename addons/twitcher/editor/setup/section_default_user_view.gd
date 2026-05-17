@tool
extends VBoxContainer

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const ButtonChanges = preload("uid://bwm1n2q3swjmt")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")

@onready var config: GridContainer = %Config

@onready var default_user: UserConverter = %DefaultUser
@onready var load_current_twitch_user: CheckButton = %LoadCurrentTwitchUser
@onready var file_select: FileSelect = %FileSelect
@onready var save: ButtonChanges = %Save
@onready var response: Label = %Response

var has_changes: bool:
	get(): return save.has_changes

var _default_user: TwitchUser

signal changed(changes: bool)

func _ready() -> void:
	if TwitchEditorSettings.default_user:
		_default_user = TwitchEditorSettings.default_user.duplicate()
	file_select.path = TwitchEditorSettings.get_default_user_path()

	load_current_twitch_user.toggled.connect(_on_toggle_load_current_twitch_user)
	load_current_twitch_user.button_pressed = TwitchEditorSettings.load_current_twitch_user
	default_user.changed.connect(_on_default_user_changed)
	file_select.file_selected.connect(_on_default_user_path_changed)
	save.pressed.connect(_save)
	save.changed.connect(func(changes): changed.emit(changes))
	_setup_current_user()


func _setup_current_user() -> void:
	var token: OAuthToken = TwitchEditorSettings.editor_oauth_token
	if token.is_token_valid(): _update_current_user()
	token.authorized.connect(_update_current_user)


func _update_current_user() -> void:
	if _default_user: return
	default_user.load_current_user()


func _on_toggle_load_current_twitch_user(toggled_on: bool) -> void:
	TwitchEditorSettings.load_current_twitch_user = toggled_on
	config.visible = toggled_on


func _on_default_user_changed(user: TwitchUser) -> void:
	_default_user = user
	if is_node_ready():
		save.has_changes = true


func _on_default_user_path_changed(path: String) -> void:
	if is_node_ready():
		save.has_changes = true


func _save() -> void:
	_default_user.take_over_path(file_select.path)
	TwitchEditorSettings.default_user = _default_user
	save.has_changes = false
	response.text = "Default user was saved at %s" % file_select.path
	TwitchTweens.flash(save, Color.GREEN)
