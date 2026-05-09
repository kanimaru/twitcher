@tool
extends Node

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")

@onready var authorization_explaination: RichTextLabel = %AuthExplain

@onready var client_id: LineEdit = %ClientId
@onready var redirect_url: LineEdit = %RedirectURL
@onready var redirect_url_label: Label = %RedirectURLLabel

@onready var to_documentation: Button = %ToDocumentation

@onready var o_auth_save: Button = %OAuthSave

@onready var device_code_flow: CheckBox = %DeviceCodeFlow
@onready var device_code_flow_explian: RichTextLabel = %DeviceCodeFlowExplain
@onready var implicit_flow: CheckBox = %ImplicitFlow
@onready var implicit_flow_explain: RichTextLabel = %ImplicitFlowExplain
@onready var file_select: FileSelect = %FileSelect

var has_changes: bool:
	set(val):
		has_changes = val
		changed.emit.call_deferred()
		o_auth_save.text = o_auth_save.text.trim_suffix(" (unsaved changes)")
		if has_changes: o_auth_save.text += " (unsaved changes)"

signal changed

var _path: String
var _redirect_url: String
var _client_id: String
var _authorization_flow: OAuth.AuthorizationFlow = OAuth.AuthorizationFlow.DEVICE_CODE_FLOW


func _ready() -> void:
	implicit_flow_explain.meta_clicked.connect(_on_link_clicked)
	device_code_flow_explian.meta_clicked.connect(_on_link_clicked)
	authorization_explaination.meta_clicked.connect(_on_link_clicked)

	client_id.text_changed.connect(_on_text_changed)
	redirect_url.text_changed.connect(_on_text_changed)

	to_documentation.pressed.connect(_on_to_documentation_pressed)
	o_auth_save.pressed.connect(_on_save)
	file_select.file_selected.connect(_on_file_selected)
	device_code_flow.pressed.connect(_select_device_code_flow)
	implicit_flow.pressed.connect(_select_implicit_flow)
	_load_oauth_setting()


func _select_device_code_flow() -> void:
	redirect_url.hide()
	redirect_url_label.hide()
	_authorization_flow = OAuth.AuthorizationFlow.DEVICE_CODE_FLOW
	has_changes = true


func _select_implicit_flow() -> void:
	redirect_url.show()
	redirect_url_label.show()
	_authorization_flow = OAuth.AuthorizationFlow.IMPLICIT_FLOW
	has_changes = true


func _load_oauth_setting() -> void:
	var setting: OAuthSetting = TwitchEditorSettings.game_oauth_setting
	if setting:
		_authorization_flow = setting.authorization_flow
		_client_id = setting.client_id
		_redirect_url = setting.redirect_url if setting.redirect_url else "http://localhost:7170"
	_path = TwitchEditorSettings.get_game_auth_setting_path()

	client_id.text = _client_id
	redirect_url.text = _redirect_url
	file_select.path = _path
	match _authorization_flow:
		OAuth.AuthorizationFlow.DEVICE_CODE_FLOW:
			device_code_flow.button_pressed = true
			_select_device_code_flow()
		OAuth.AuthorizationFlow.IMPLICIT_FLOW:
			implicit_flow.button_pressed = true
			_select_implicit_flow()
	has_changes = false


func _on_link_clicked(link: Variant) -> void:
	OS.shell_open(link)


func _on_text_changed(val: String) -> void:
	_client_id = client_id.text
	_redirect_url = redirect_url.text
	has_changes = true


func _on_file_selected(path: String) -> void:
	_path = path
	has_changes = true


func _on_save() -> void:
	var oauth_settings: OAuthSetting = TwitchEditorSettings.game_oauth_setting
	if not oauth_settings:
		oauth_settings = TwitchAuth.create_default_oauth_setting()

	oauth_settings.authorization_flow = _authorization_flow
	oauth_settings.client_id = _client_id
	oauth_settings.redirect_url = _redirect_url
	oauth_settings.take_over_path(_path)
	var err = ResourceSaver.save(oauth_settings)
	if not err:
		TwitchEditorSettings.game_oauth_setting = oauth_settings
	ProjectSettings.save()
	TwitchTweens.flash(o_auth_save, Color.GREEN)
	has_changes = false


func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/")
