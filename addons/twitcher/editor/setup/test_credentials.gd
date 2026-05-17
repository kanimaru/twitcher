@tool
extends Button

const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

@export var oauth_setting: OAuthSetting: set = update_oauth_setting
@export var oauth_token: OAuthToken: set = update_oauth_token
@export var test_response: Label

var scopes: OAuthScopes

signal authorized


func _ready() -> void:
	if not oauth_setting:
		oauth_setting = TwitchEditorSettings.editor_oauth_setting
	if not oauth_token:
		oauth_token = TwitchEditorSettings.editor_oauth_token


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		oauth_token.authorized.disconnect(_on_authorized)


func _pressed() -> void:
	if test_response:
		set_test_response("Authorizing...")

	TwitchTweens.loading(self)
	await TwitchAuth.manual_authorize(
		oauth_setting,
		oauth_token,
		true)

	if oauth_token.is_token_valid():
		set_test_response("Credentials are valid!", Color.GREEN)
		TwitchTweens.flash(self, Color.GREEN)
		authorized.emit()
	else:
		set_test_response("Credentials are invalid!", Color.RED)
		TwitchTweens.flash(self, Color.RED)


func set_test_response(info: String, color: Color = Color.TRANSPARENT) -> void:
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


func update_oauth_setting(new_oauth_setting: OAuthSetting) -> void:
	oauth_setting = new_oauth_setting
	disabled = not oauth_setting.is_valid()


func _on_authorized() -> void:
	if is_inside_tree(): authorized.emit()
