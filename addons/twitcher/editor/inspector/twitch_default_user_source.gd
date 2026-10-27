@tool
class_name TwitchDefaultUserSource
extends RefCounted

## Where the inspector's user fields ([UserConverter]) get the default user from.
##
## The default implementation reads [code]TwitchEditorSettings[/code], which the editor plugin
## sets up. Hand a converter a subclass to feed it from somewhere else, e.g. in tests.

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")


## The configured default user, or null when there is none.
func get_user() -> TwitchUser:
	return TwitchEditorSettings.default_user


## Whether empty user fields may be filled with the default user without being asked to.
## Follows the "load current twitch user" setting from the Twitcher setup.
func is_auto_fill_enabled() -> bool:
	return TwitchEditorSettings.load_current_twitch_user
