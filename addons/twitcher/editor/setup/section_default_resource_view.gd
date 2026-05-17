@tool
extends Node

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const ButtonChanges = preload("uid://bwm1n2q3swjmt")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")

@onready var file_select: FileSelect = %FileSelect
@onready var save: ButtonChanges = %Save
@onready var response: Label = %Response

signal changed(changes: bool)

var has_changes: bool:
	get(): return save.has_changes

func _ready() -> void:
	file_select.path = TwitchEditorSettings.resource_folder
	file_select.file_selected.connect(_on_file_selected)
	save.pressed.connect(_save)
	save.changed.connect(func(changes): changed.emit(changes))


func _on_file_selected(path: String) -> void:
	if is_node_ready():
		save.has_changes = true


func _save() -> void:
	var resource_folder: String = file_select.path

	var project_settings: OAuthSetting = TwitchEditorSettings.editor_oauth_setting.duplicate()
	var setting_path: String = resource_folder.path_join("twitch_oauth_setting.tres")
	project_settings.take_over_path(setting_path)
	ResourceSaver.save(project_settings)

	var project_token: OAuthToken = OAuthToken.new()
	var token_path: String = resource_folder.path_join("twitch_oauth_token.tres")
	project_token.take_over_path(token_path)
	ResourceSaver.save(project_token)

	save.has_changes = false
	TwitchTweens.flash(save, Color.GREEN)
	response.text = "Saved files to:\n - %s\n - %s" % [ setting_path, token_path ]
