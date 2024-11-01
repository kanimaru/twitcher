extends Node

@onready var twitch_auth_user: TwitchAuth = %TwitchAuthUser

func _ready() -> void:
	await twitch_auth_user.authorize()
