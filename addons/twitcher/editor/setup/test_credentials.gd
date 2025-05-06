@tool
extends Button

const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

@export var oauth_setting: OAuthSetting: set = update_oauth_setting
@export var oauth_token: OAuthToken: set = update_oauth_token
@export var test_response: Label

@onready var twitch_auth: TwitchAuth = %TwitchAuth

signal authorized

func _ready() -> void:
	pressed.connect(_pressed)
	oauth_setting = TwitchEditorSettings.editor_oauth_setting
	oauth_token = TwitchEditorSettings.editor_oauth_token
	

func _pressed() -> void:
	TwitchTweens.loading(self)
	await twitch_auth.authorize()
	
	if twitch_auth.token.is_token_valid():
		if test_response:
			test_response.text = "Credentials are valid!"
			test_response.add_theme_color_override(&"font_color", Color.GREEN)
		TwitchTweens.flash(self, Color.GREEN)
		authorized.emit()
	else:
		if test_response:
			test_response.text = "Credentials are invalid!"
			test_response.add_theme_color_override(&"font_color", Color.RED)
		TwitchTweens.flash(self, Color.RED)


func update_oauth_token(new_oauth_token: OAuthToken) -> void:
	oauth_token = new_oauth_token
	if is_inside_tree():
		twitch_auth.token = new_oauth_token


func update_oauth_setting(new_oauth_setting: OAuthSetting) -> void:
	oauth_setting = new_oauth_setting
	if is_inside_tree():
		twitch_auth.oauth_setting = oauth_setting
