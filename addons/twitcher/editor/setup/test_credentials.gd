@tool
extends Button

const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

@export var oauth_setting: OAuthSetting: set = update_oauth_setting
@export var oauth_token: OAuthToken: set = update_oauth_token
@export var test_response: Label

@onready var twitch_auth: TwitchAuth = %TwitchAuth
@onready var o_auth: OAuth = %OAuth
@onready var token_handler: TwitchTokenHandler = %TokenHandler

signal authorized

func _ready() -> void:
	pressed.connect(_pressed)
	oauth_setting = TwitchEditorSettings.editor_oauth_setting
	oauth_token = TwitchEditorSettings.editor_oauth_token
	
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		oauth_token.authorized.disconnect(_on_authorized)


func _pressed() -> void:
	if test_response:
		_set_test_response("Authorizing...")
		if o_auth.login_in_process:
			_set_test_response("Another login trial is in process. Wait for timeout!", Color.YELLOW)
			if await token_handler.token_resolved == null:
				_set_test_response("Login unsuccessful!", Color.RED)
	
	TwitchTweens.loading(self)
	await twitch_auth.authorize()
	
	if twitch_auth.token.is_token_valid():
		_set_test_response("Credentials are valid!", Color.GREEN)
		TwitchTweens.flash(self, Color.GREEN)
		authorized.emit()
	else:
		_set_test_response("Credentials are invalid!", Color.RED)
		TwitchTweens.flash(self, Color.RED)


func _set_test_response(info: String, color: Color = Color.TRANSPARENT) -> void:
	if test_response:
		test_response.text = info
		if color == Color.TRANSPARENT:
			test_response.remove_theme_color_override(&"font_color")
		else:
			test_response.add_theme_color_override(&"font_color", color)


func update_oauth_token(new_oauth_token: OAuthToken) -> void:
	if oauth_token && oauth_token.authorized.is_connected(_on_authorized):
		oauth_token.authorized.disconnect(_on_authorized)
		
	oauth_token = new_oauth_token
	if not oauth_token.authorized.is_connected(_on_authorized):
		oauth_token.authorized.connect(_on_authorized)
	if is_inside_tree():
		twitch_auth.token = new_oauth_token


func update_oauth_setting(new_oauth_setting: OAuthSetting) -> void:
	oauth_setting = new_oauth_setting
	disabled = not oauth_setting.is_valid()
	if is_inside_tree():
		twitch_auth.oauth_setting = oauth_setting


func _on_authorized() -> void:
	if is_inside_tree(): authorized.emit()
