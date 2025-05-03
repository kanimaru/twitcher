@tool
extends Window

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

@export var token: OAuthToken

@onready var inspector: HBoxContainer = %Inspector
@onready var cancel: Button = %Cancel
@onready var revoke_locally: Button = %RevokeLocally
@onready var revoke_twitch: Button = %RevokeTwitch
@onready var twitch_token_handler: TwitchTokenHandler = %TwitchTokenHandler

signal revoked(success: bool)

var picker: EditorResourcePicker

func _ready() -> void:
	picker = EditorResourcePicker.new()
	picker.base_type = "OAuthSetting"
	picker.edited_resource = TwitchEditorSettings.game_oauth_setting
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	inspector.add_child(picker)
	
	cancel.pressed.connect(_on_cancel)
	revoke_locally.pressed.connect(_on_revoke_locally)
	revoke_twitch.pressed.connect(_on_revoke_twitch)
	
	twitch_token_handler.token = token
	close_requested.connect(_on_cancel)
	
	
func _on_cancel() -> void:
	revoked.emit(false)
	queue_free()
	
	
func _on_revoke_locally() -> void:
	revoked.emit(true)
	token.remove_tokens()
	queue_free()
	
	
func _on_revoke_twitch() -> void:
	revoked.emit(true)
	if is_instance_valid(picker.edited_resource):
		twitch_token_handler.oauth_setting = picker.edited_resource
		await twitch_token_handler.revoke_token()
	queue_free()
