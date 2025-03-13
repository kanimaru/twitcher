@tool
extends Node

const Token = preload("res://addons/twitcher/lib/oOuch/oauth_token.gd")

signal revoked

@export var token: Token

@onready var title: Label = %Title
@onready var token_valid_value: Label = %TokenValidValue
@onready var refresh_token_value: CheckBox = %RefreshTokenValue
@onready var token_scope_value: Node = %TokenScopeValue
@onready var reload_button: Button = %ReloadButton
@onready var revoke_button: Button = %RevokeButton


func _ready() -> void:
	if token == null:
		_reset_token()
		return
	token.changed.connect(_on_token_changed)
	update_token_view()
	revoke_button.pressed.connect(_on_revoke_pressed)
	reload_button.pressed.connect(_on_reload_pressed)
	
	
func update_token_view() -> void:
	title.text = token._identifier
	token_valid_value.text = token.get_expiration_readable()
	if token.is_token_valid():
		token_valid_value.add_theme_color_override(&"font_color", Color.GREEN)
	else:
		token_valid_value.add_theme_color_override(&"font_color", Color.RED)

	if token.has_refresh_token():
		refresh_token_value.text = "Available"
		refresh_token_value.add_theme_color_override(&"font_color", Color.GREEN)
		refresh_token_value.button_pressed = true
	else:
		refresh_token_value.text = "Not Available"
		refresh_token_value.add_theme_color_override(&"font_color", Color.YELLOW)
		refresh_token_value.button_pressed = false

	for scope in token.get_scopes():
		var scope_name = Label.new()
		scope_name.text = scope
		token_scope_value.add_child(scope_name)
	revoke_button.disabled = false
	

func _on_revoke_pressed() -> void:
	token.remove_tokens()
	_reset_token()


func _on_reload_pressed() -> void:
	_reset_token()
	token._load_tokens()


func _reset_token() -> void:
	title.text = ""
	token_valid_value.text = ""
	refresh_token_value.button_pressed = false
	revoke_button.disabled = true
	for child in token_scope_value.get_children():
		child.queue_free()
	

func _on_token_changed() -> void:
	update_token_view()
