@tool
extends GridContainer

const Token = preload("res://addons/twitcher/lib/oOuch/token.gd")

@export var token: Token

@onready var title: Label = %Title
@onready var token_valid_value: Label = %TokenValidValue
@onready var refresh_token_value: CheckBox = %RefreshTokenValue
@onready var token_scope_value: TextEdit = %TokenScopeValue

func _ready() -> void:
	if token == null: return
	title.text = token._identifier
	token_valid_value.text = token.get_expiration()
	if token.is_token_valid():
		token_valid_value.add_theme_color_override(&"text", Color.GREEN)
	else:
		token_valid_value.add_theme_color_override(&"text", Color.RED)

	if token.has_refresh_token():
		refresh_token_value.text = "Available"
		refresh_token_value.button_pressed = true
	else:
		refresh_token_value.text = "Not Available"
		refresh_token_value.button_pressed = false

	token_scope_value.text = ",\n".join(token.get_scopes())
