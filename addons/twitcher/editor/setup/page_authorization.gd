@tool
extends Node

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")
const TWITCH_SERVICE = preload("res://addons/twitcher/twitch_service.tscn")

@onready var authorization_explaination: RichTextLabel = %AuthExplain

@onready var client_id: LineEdit = %ClientId
@onready var client_secret: LineEdit = %ClientSecret
@onready var redirect_url: LineEdit = %RedirectURL

@onready var oauth_setting_file_select: FileSelect = %OauthSettingFileSelect
@onready var token_file_select: FileSelect = %TokenFileSelect

@onready var to_documentation: Button = %ToDocumentation

@onready var o_auth_save: Button = %OAuthSave
@onready var test_response: Label = %TestResponse

var has_changes: bool:
	set(val): 
		has_changes = val
		changed.emit.call_deferred()
		o_auth_save.text = o_auth_save.text.trim_suffix(" (unsaved changes)")
		if has_changes: o_auth_save.text += " (unsaved changes)"

signal changed


func _ready() -> void:
	authorization_explaination.meta_clicked.connect(_on_link_clicked)
	
	redirect_url.text_changed.connect(_on_text_changed)
	client_id.text_changed.connect(_on_text_changed)
	client_secret.text_changed.connect(_on_text_changed)
	to_documentation.pressed.connect(_on_to_documentation_pressed)
	oauth_setting_file_select.file_selected.connect(_on_file_changed)
	token_file_select.file_selected.connect(_on_file_changed)
	
	o_auth_save.pressed.connect(_on_save)
	
	_load_oauth_setting()
	

func _load_oauth_setting() -> void:
	var setting: OAuthSetting = TwitchEditorSettings.editor_oauth_setting
	client_id.text = setting.client_id
	client_secret.text = setting.get_client_secret()
	redirect_url.text = setting.redirect_url


func _on_link_clicked(link: Variant) -> void:
	OS.shell_open(link)
	

func _on_text_changed(val: String) -> void:
	reset_response_message()
	var setting: OAuthSetting = TwitchEditorSettings.editor_oauth_setting
	setting.client_id = client_id.text
	setting.set_client_secret(client_secret.text)
	setting.redirect_url = redirect_url.text
	has_changes = true
	

func reset_response_message() -> void:
	test_response.text = ""

	
func _on_file_changed() -> void:
	has_changes = true


func is_auth_existing() -> bool:
	return is_instance_valid(TwitchEditorSettings.editor_oauth_setting)


func _on_save() -> void:
	TwitchEditorSettings.save_editor_oauth_setting()
	TwitchEditorSettings.save_editor_oauth_token()
	
	var setting_path = oauth_setting_file_select.path
	var setting = TwitchEditorSettings.editor_oauth_setting.duplicate(true)
	setting.take_over_path(setting_path)
	ResourceSaver.save(setting, setting_path)
	TwitchEditorSettings.game_oauth_setting = setting
	
	var token_path = token_file_select.path
	var token = TwitchEditorSettings.editor_oauth_token.duplicate()
	token.take_over_path(token_path)
	ResourceSaver.save(token, token_path)
	TwitchEditorSettings.game_oauth_token = token
		
	TwitchTweens.flash(o_auth_save, Color.GREEN)
	ProjectSettings.save()
	has_changes = false


func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/")
