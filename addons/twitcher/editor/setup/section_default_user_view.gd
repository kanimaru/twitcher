@tool
extends VBoxContainer

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const ButtonChanges = preload("uid://bwm1n2q3swjmt")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")

@onready var config: GridContainer = %Config

@onready var default_user: UserConverter = %DefaultUser
@onready var load_current_twitch_user: CheckButton = %LoadCurrentTwitchUser
@onready var file_select: FileSelect = %FileSelect
@onready var response: Label = %Response

var has_changes: bool

var _default_user: TwitchUser
var _load_current_twitch_user: bool

signal changed

func _ready() -> void:
	if TwitchEditorSettings.default_user:
		_default_user = TwitchEditorSettings.default_user.duplicate()
	file_select.path = TwitchEditorSettings.get_default_user_path()
	load_current_twitch_user.button_pressed = TwitchEditorSettings.load_current_twitch_user
	_on_toggle_load_current_twitch_user(TwitchEditorSettings.load_current_twitch_user)

	load_current_twitch_user.toggled.connect(_on_toggle_load_current_twitch_user)
	default_user.changed.connect(_on_default_user_changed)
	file_select.file_selected.connect(_on_default_user_path_changed)
	_setup_current_user()


func _setup_current_user() -> void:
	var token: OAuthToken = TwitchEditorSettings.editor_oauth_token
	if token.is_token_valid(): _update_current_user()
	token.authorized.connect(_update_current_user)


func _enter_tree() -> void:
	if is_node_ready():
		var token: OAuthToken = TwitchEditorSettings.editor_oauth_token
		if token.is_token_valid(): _update_current_user()


func _update_current_user() -> void:
	if _default_user: return
	if not is_inside_tree(): return
	default_user.load_current_user()


func _on_toggle_load_current_twitch_user(toggled_on: bool) -> void:
	_load_current_twitch_user = toggled_on
	config.visible = toggled_on
	changed.emit()


func _on_default_user_changed(user: TwitchUser) -> void:
	var previous_user: TwitchUser = _default_user
	_default_user = user
	if is_node_ready():
		has_changes = (previous_user == null and user != null) or (previous_user.id != user.id)
		changed.emit()


func _on_default_user_path_changed(path: String) -> void:
	if is_node_ready():
		has_changes = true
		changed.emit()


func save() -> bool:
	TwitchEditorSettings.load_current_twitch_user = _load_current_twitch_user
	var path: String = file_select.path
	if _load_current_twitch_user:
		var error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
		if error:
			push_error("Error creating the twitch resources cause: ", error_string(error))
			return false

		var current_default_user: TwitchUser = TwitchEditorSettings.default_user
		if current_default_user == null:
			current_default_user = TwitchUser.new()
			TwitchEditorSettings.default_user = current_default_user


		var data: Dictionary = _default_user.to_dict()

		for key in data:
			current_default_user.set(key, data[key])
		current_default_user.take_over_path(file_select.path)
		error = ResourceSaver.save(current_default_user)
		if error:
			push_error("Can't save default user cause ", error_string(error))
			return false

	has_changes = false
	if _load_current_twitch_user:
		response.text = "Default user was saved at %s" % path
	return true
