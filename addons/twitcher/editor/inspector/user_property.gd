@tool
extends EditorProperty

const USER_CONVERTER = preload("res://addons/twitcher/editor/inspector/user_converter.tscn")
const UserConverter = preload("res://addons/twitcher/editor/inspector/user_converter.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

var _converter: UserConverter


func _init():
	_converter = USER_CONVERTER.instantiate()
	_converter.changed.connect(_on_changed)
	add_child(_converter)


func _update_property() -> void:
	var user: TwitchUser = get_edited_object()[get_edited_property()]
	if user == null:
		_converter.user_id = ""
		_converter.user_login = ""
	else:
		_converter.user_id = user.id
		_converter.user_login = user.login


func _on_changed(user: TwitchUser) -> void:
	emit_changed(get_edited_property(), user, &"", true)
	_update_property()
