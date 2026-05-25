@tool
extends Node

const TwitchEditorNodeUtils = preload("uid://cwvdheqhq5yrl")
const TwitchEditorSettings = preload("uid://kqcukq2xqnuf")
const TwitchTweens = preload("uid://duhsr84u352ef")
const SectionGameAuthorizationView = preload("uid://c5wx1gn2acuvp")
const SectionDefaultResourceView = preload("uid://b28mmhk5a83yy")

const GAME_TEMPLATE = preload("uid://blddelc3lr6r4")

@onready var to_documentation: Button = %ToDocumentation

@onready var game_authorization_view: SectionGameAuthorizationView = %GameAuthorizationView
@onready var default_ressource_view: SectionDefaultResourceView = %DefaultRessourceView

var has_changes: bool:
	get(): return game_authorization_view.has_changes or default_ressource_view.has_changes

signal changed


func _ready() -> void:
	game_authorization_view.changed.connect(changed.emit)
	default_ressource_view.changed.connect(changed.emit)
	to_documentation.pressed.connect(_on_to_documentation_pressed)
	var setting: OAuthSetting = TwitchEditorSettings.game_oauth_setting if TwitchEditorSettings.game_oauth_setting else TwitchAuth.create_default_oauth_setting()
	game_authorization_view.setting = setting
	default_ressource_view.setting = setting
	default_ressource_view.token = TwitchEditorSettings.game_oauth_token if TwitchEditorSettings.game_oauth_token else OAuthToken.new()


func save() -> bool:
	if not game_authorization_view.save():
		TwitchEditorSettings.game_oauth_setting = game_authorization_view.setting
		return false
	if not default_ressource_view.save():
		return false
	has_changes = false
	return true


func bootstrap() -> void:
	if not save(): return # Save before to ensure that token and settings are there
	TwitchEditorNodeUtils.new_scene()
	var root_node = GAME_TEMPLATE.instantiate()
	root_node.scene_file_path = ""
	root_node.name = "Game"
	var twitch_service: TwitchService = root_node.get_node(^"TwitchService")
	twitch_service.token = TwitchEditorSettings.game_oauth_token
	twitch_service.oauth_setting = TwitchEditorSettings.game_oauth_setting
	EditorInterface.add_root_node(root_node)


func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/")
