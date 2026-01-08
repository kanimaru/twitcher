extends Control

@onready var get_token: Button = %GetToken
@onready var client_id: LineEdit = %ClientId
@onready var client_secret: LineEdit = %ClientSecret

@onready var twitch_auth: TwitchAuth = %TwitchAuth


signal authorized()


func _ready() -> void:
	get_token.pressed.connect(_on_get_token)
	

func _on_get_token() -> void:
	twitch_auth.oauth_setting.client_id = client_id.text
	twitch_auth.oauth_setting.set_client_secret(client_secret.text)
	await twitch_auth.authorize()
	authorized.emit(twitch_auth.token)
