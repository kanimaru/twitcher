@tool
extends VBoxContainer

const TwitchEditorSettings = preload("uid://kqcukq2xqnuf")

@onready var client_id: LineEdit = %ClientId
@onready var redirect_url: LineEdit = %RedirectURL
@onready var redirect_url_label: Label = %RedirectURLLabel
@onready var device_code_flow: CheckBox = %DeviceCodeFlow
@onready var implicit_flow: CheckBox = %ImplicitFlow

var has_changes: bool
signal changed

var token: OAuthToken
var setting: OAuthSetting

var _redirect_url: String
var _client_id: String
var _authorization_flow: OAuth.AuthorizationFlow = OAuth.AuthorizationFlow.DEVICE_CODE_FLOW

func _ready() -> void:
	client_id.text_changed.connect(_on_text_changed)
	redirect_url.text_changed.connect(_on_text_changed)
	device_code_flow.pressed.connect(_select_device_code_flow)
	implicit_flow.pressed.connect(_select_implicit_flow)
	_load_oauth_setting.call_deferred()


func _load_oauth_setting() -> void:
	if setting:
		_authorization_flow = setting.authorization_flow
		_client_id = setting.client_id
		_redirect_url = setting.redirect_url if setting.redirect_url else "http://localhost:7170"

	client_id.text = _client_id
	redirect_url.text = _redirect_url
	match _authorization_flow:
		OAuth.AuthorizationFlow.DEVICE_CODE_FLOW:
			device_code_flow.button_pressed = true
			_select_device_code_flow()
		OAuth.AuthorizationFlow.IMPLICIT_FLOW:
			implicit_flow.button_pressed = true
			_select_implicit_flow()
	has_changes = false


func _select_device_code_flow() -> void:
	redirect_url.hide()
	redirect_url_label.hide()
	_authorization_flow = OAuth.AuthorizationFlow.DEVICE_CODE_FLOW
	has_changes = true
	changed.emit()


func _select_implicit_flow() -> void:
	redirect_url.show()
	redirect_url_label.show()
	_authorization_flow = OAuth.AuthorizationFlow.IMPLICIT_FLOW
	has_changes = true
	changed.emit()


func _on_text_changed(val: String) -> void:
	_client_id = client_id.text
	_redirect_url = redirect_url.text
	has_changes = true
	changed.emit()


func save() -> bool:
	setting.authorization_flow = _authorization_flow
	setting.client_id = _client_id
	setting.redirect_url = _redirect_url
	has_changes = false
	return true
