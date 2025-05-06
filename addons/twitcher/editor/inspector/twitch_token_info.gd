@tool
extends "res://addons/twitcher/lib/oOuch/oauth_token_info.gd"

const TWITCH_TOKEN_REVOKE_POPUP = preload("res://addons/twitcher/editor/inspector/twitch_token_revoke_popup.tscn")
const TwitchTokenRevokePopup = preload("res://addons/twitcher/editor/inspector/twitch_token_revoke_popup.gd")


func _on_revoke_pressed() -> void:
	var popup: TwitchTokenRevokePopup = TWITCH_TOKEN_REVOKE_POPUP.instantiate()
	popup.token = token
	add_child(popup)
	popup.popup_centered()
	var success = await popup.revoked
	if success: _reset_token()
