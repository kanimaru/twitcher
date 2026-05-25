@tool
extends Node

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const ButtonChanges = preload("uid://bwm1n2q3swjmt")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")

@onready var file_select: FileSelect = %FileSelect
@onready var response: Label = %Response

var token: OAuthToken
var setting: OAuthSetting

signal changed

var has_changes: bool

func _ready() -> void:
	file_select.path = TwitchEditorSettings.resource_folder
	file_select.file_selected.connect(_on_file_selected)


func _on_file_selected(path: String) -> void:
	if is_node_ready():
		has_changes = true
		changed.emit()


func save() -> bool:
	var resource_folder: String = file_select.path
	TwitchEditorSettings.resource_folder = resource_folder

	var error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(resource_folder))
	if error:
		push_error("Error creating the twitch resources cause: ", error_string(error))
		return false

	var setting_path: String = resource_folder.path_join("twitch_oauth_setting.tres")
	if setting.resource_path and FileAccess.file_exists(setting.resource_path):
		error = DirAccess.rename_absolute(ProjectSettings.globalize_path(setting.resource_path), setting_path)
	else:
		error = ResourceSaver.save(setting, setting_path)
	if error:
		push_error("Error creating the twitch resources cause: ", error_string(error))
		return false
	setting.take_over_path(setting_path)
	TwitchEditorSettings.game_oauth_setting = setting

	var token_path: String = resource_folder.path_join("twitch_oauth_token.tres")
	if token.resource_path and FileAccess.file_exists(token.resource_path):
		error = DirAccess.rename_absolute(ProjectSettings.globalize_path(token.resource_path), token_path)
	else:
		error = ResourceSaver.save(token, token_path)
	if error:
		push_error("Error creating the twitch resources cause: ", error_string(error))
		return false
	token.take_over_path(token_path)
	TwitchEditorSettings.game_oauth_token = token

	has_changes = false
	response.text = "Saved files to:\n - %s\n - %s" % [ setting_path, token_path ]
	return true
