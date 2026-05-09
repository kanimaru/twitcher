@tool
extends Node

const TestCredentials = preload("res://addons/twitcher/editor/setup/test_credentials.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")
const TWITCH_SERVICE: PackedScene = preload("res://addons/twitcher/twitch_service.tscn")
const SectionDefaultUserView = preload("uid://bkvsg1os5pj6a")

@onready var authorization_explaination: RichTextLabel = %AuthExplain

@onready var client_id: LineEdit = %ClientId
@onready var client_secret: LineEdit = %ClientSecret

@onready var to_documentation: Button = %ToDocumentation

@onready var o_auth_save: Button = %OAuthSave
@onready var test_response: Label = %TestResponse
@onready var test_credentials: TestCredentials = %TestCredentials
@onready var default_user: PanelContainer = %DefaultUser
@onready var default_user_view: SectionDefaultUserView = %DefaultUserView

var has_changes: bool:
	set(val):
		has_changes = val
		changed.emit.call_deferred()
		o_auth_save.text = o_auth_save.text.trim_suffix(" (unsaved changes)")
		if has_changes: o_auth_save.text += " (unsaved changes)"

var _client_id: String
var _client_secret: String

signal changed


func _ready() -> void:
	authorization_explaination.meta_clicked.connect(_on_link_clicked)

	client_id.text_changed.connect(_on_text_changed)
	client_secret.text_changed.connect(_on_text_changed)
	to_documentation.pressed.connect(_on_to_documentation_pressed)
	o_auth_save.pressed.connect(_on_save)
	test_credentials.authorized.connect(_on_authorized)
	default_user_view.changed.connect(_on_default_user_changed)
	_load_oauth_setting()


func _load_oauth_setting() -> void:
	var setting: OAuthSetting = TwitchEditorSettings.editor_oauth_setting
	_client_id = setting.client_id
	_client_secret = setting.get_client_secret()

	client_id.text = _client_id
	client_secret.text = _client_secret

	if TwitchEditorSettings.is_valid():
		test_credentials.set_test_response("Editor Token is still valid", Color.GREEN)
		_set_authorized()
	else: _set_unauthorized()


func _set_authorized() -> void:
	default_user.show()


func _set_unauthorized() -> void:
	default_user.hide()


func _on_authorized() -> void:
	_set_authorized()


func _on_link_clicked(link: Variant) -> void:
	OS.shell_open(link)


func _on_default_user_changed() -> void:
	has_changes = true


func _on_text_changed(val: String) -> void:
	reset_response_message()
	has_changes = true

	if TwitchEditorSettings.editor_oauth_setting.is_valid():
		test_credentials.disabled = false


func show_response_message(msg: String) -> void:
	test_response.text = msg


func reset_response_message() -> void:
	test_response.text = ""


func _on_save() -> void:
	var setting = TwitchEditorSettings.editor_oauth_setting
	setting.client_id = client_id.text
	setting.set_client_secret(client_secret.text)
	setting.authorization_flow = OAuth.AuthorizationFlow.CLIENT_CREDENTIALS
	setting.take_over_path(TwitchEditorSettings.get_editor_auth_setting_path())
	ResourceSaver.save(setting)

	TwitchTweens.flash(o_auth_save, Color.GREEN)
	propagate_call(&"save")
	ProjectSettings.save()
	has_changes = false


func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/")
