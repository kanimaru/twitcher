extends Node

## Test:
## 2 differnt token for 2 different accounts.
## It will open 2 times the browser
## make sure that you login with different accounts.

@onready var twitch_auth_user1: TwitchAuth = %TwitchAuthUser1
@onready var twitch_auth_user2: TwitchAuth = %TwitchAuthUser2
@onready var api: TwitchAPI = %API

func _ready() -> void:
	await twitch_auth_user1.authorize()
	await twitch_auth_user2.authorize()
	api.token = twitch_auth_user1.token
	var user1 = await api.get_users([], [])

	api.token = twitch_auth_user2.token
	var user2 = await api.get_users([], [])

	print("User 1 token belongs to: %s" % user1.data[0].display_name)
	print("User 2 token belongs to: %s" % user2.data[0].display_name)
