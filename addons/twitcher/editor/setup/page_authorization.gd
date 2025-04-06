@tool
extends Node

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")
const TestCredentials = preload("res://addons/twitcher/editor/setup/test_credentials.gd")

@onready var authorization_options: GridContainer = %AuthorizationOptions

@onready var authorization_explaination: RichTextLabel = %AuthorizationExplaination

@onready var client_id: LineEdit = %ClientId
@onready var client_secret: LineEdit = %ClientSecret
@onready var redirect_url: LineEdit = %RedirectURL
@onready var oauth_setting_file_select: FileSelect = %OauthSettingFileSelect
@onready var token_file_select: FileSelect = %TokenFileSelect
@onready var to_documentation: Button = %ToDocumentation

@onready var o_auth_save: Button = %OAuthSave
@onready var test_credentials: TestCredentials = %TestCredentials
@onready var test_response: Label = %TestResponse


var oauth_setting: OAuthSetting: set = update_oauth_setting
var oauth_token: OAuthToken: set = update_oauth_token


func _ready() -> void:
	authorization_explaination.meta_clicked.connect(_on_link_clicked)
	
	#if is_auth_existing():
		# TODO make better
	#	authorization_options.hide()
	
	redirect_url.text_changed.connect(_on_text_changed)
	client_id.text_changed.connect(_on_text_changed)
	client_secret.text_changed.connect(_on_text_changed)
	to_documentation.pressed.connect(_on_to_documentation_pressed)
	
	o_auth_save.pressed.connect(_on_save)

	oauth_setting_file_select.path = TwitchEditorSettings.get_oauth_setting_path()
	token_file_select.path = TwitchEditorSettings.get_editor_token_path()
	oauth_setting_file_select.file_selected.connect(_on_oauth_setting_file_selected)
	_load_credentials()
	

func _on_oauth_setting_file_selected(path: String) -> void:
	if not FileAccess.file_exists(path): return
	_load_oauth_setting(path)


func _load_oauth_setting(path: String) -> void:
	oauth_setting = load(oauth_setting_file_select.path)
	client_id.text = oauth_setting.client_id
	client_secret.text = oauth_setting.get_client_secret()
	redirect_url.text = oauth_setting.redirect_url

func _load_credentials() -> void:
	if FileAccess.file_exists(oauth_setting_file_select.path):
		_load_oauth_setting(oauth_setting_file_select.path)
	else:
		oauth_setting = TwitchAuth.create_default_oauth_setting()
		
	if FileAccess.file_exists(token_file_select.path):
		oauth_token = load(token_file_select.path)
	else:
		oauth_token = OAuthToken.new()
		

func _on_link_clicked(link: Variant) -> void:
	OS.shell_open(link)
	

func _on_text_changed(val: String) -> void:
	reset_response_message()
	oauth_setting.client_id = client_id.text
	oauth_setting.set_client_secret(client_secret.text)
	oauth_setting.redirect_url = redirect_url.text


func reset_response_message() -> void:
	test_response.text = ""


func is_auth_existing() -> bool:
	return TwitchEditorSettings.oauth_setting != null


func _on_save() -> void:
	var s_path = oauth_setting_file_select.path
	oauth_setting.take_over_path(s_path)
	ResourceSaver.save(oauth_setting, s_path)
	TwitchEditorSettings.set_oauth_setting_path(s_path)
	
	var t_path = token_file_select.path
	oauth_token.take_over_path(t_path)
	ResourceSaver.save(oauth_token, t_path)
	TwitchEditorSettings.set_editor_token(t_path)
	
	TwitchTweens.flash(o_auth_save, Color.GREEN)
	ProjectSettings.save()


func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/")


func update_oauth_setting(new_oauth_setting: OAuthSetting) -> void:
	oauth_setting = new_oauth_setting
	test_credentials.oauth_setting = new_oauth_setting
	

func update_oauth_token(new_oauth_token: OAuthToken) -> void:
	oauth_token = new_oauth_token
	test_credentials.oauth_token = oauth_token
