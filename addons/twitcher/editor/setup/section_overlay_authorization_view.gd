@tool
extends Node

const TestCredentials = preload("res://addons/twitcher/editor/setup/test_credentials.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")
const ButtonChanges = preload("uid://bwm1n2q3swjmt")
const SetupWindow = preload("uid://bbguje3a0cl8t")

@onready var client_id: LineEdit = %ClientId
@onready var client_secret: LineEdit = %ClientSecret
@onready var test_credentials: TestCredentials = %TestCredentials
@onready var test_response: Label = %TestResponse

var has_changes: bool

var _temp_oauth_setting: OAuthSetting = TwitchAuth.create_default_oauth_setting()

signal changed
signal authorized

func _ready() -> void:
	if get_window() is not SetupWindow:
		return

	client_id.text_changed.connect(_on_text_changed)
	client_secret.text_changed.connect(_on_text_changed)
	test_credentials.authorized.connect(_on_authorized)

	_load_editor_oauth_settings()
	test_credentials.oauth_setting = _temp_oauth_setting
	test_credentials.oauth_token = TwitchEditorSettings.editor_oauth_token

	_check_authorization.call_deferred()
	TwitchEditorSettings.editor_oauth_token.authorized.connect(_on_authorized)


func _load_editor_oauth_settings() -> void:
	var oauth_setting: OAuthSetting = TwitchEditorSettings.editor_oauth_setting
	client_id.text = oauth_setting.client_id
	client_secret.text = oauth_setting.get_client_secret()
	_temp_oauth_setting.client_id = oauth_setting.client_id
	_temp_oauth_setting.set_client_secret(oauth_setting.get_client_secret())
	_temp_oauth_setting.authorization_flow = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW


func _check_authorization() -> void:
	if TwitchEditorSettings.is_valid():
		_set_response_message("Editor Token is still valid", Color.GREEN)
		_on_view_updated()
		authorized.emit()


func _set_response_message(text: String, color: Color = Color.WHITE) -> void:
	test_credentials.set_test_response(text, color)


func _on_view_updated() -> void:
	if client_id.text and client_secret.text:
		_temp_oauth_setting.client_id = client_id.text
		_temp_oauth_setting.set_client_secret(client_secret.text)
		test_credentials.disabled = false
	else:
		test_credentials.disabled = true


func _on_authorized() -> void:
	# Save it so that the user has the client credentials for the given token
	save()
	authorized.emit()


func _on_text_changed(val: String) -> void:
	_set_response_message("")
	has_changes = true
	changed.emit()
	_on_view_updated()


func save() -> bool:
	var setting: OAuthSetting = TwitchEditorSettings.editor_oauth_setting
	setting.client_id = client_id.text
	setting.set_client_secret(client_secret.text)
	setting.authorization_flow = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW
	setting.take_over_path(TwitchEditorSettings.get_editor_auth_setting_path())
	var error: Error = ResourceSaver.save(setting)
	if error:
		push_error("Can't save editor oauth settings cause of ", error_string(error))
		return false

	has_changes = false
	return true
