@tool
extends EditorProperty
class_name UserProperty

const USER_CONVERTER = preload("res://addons/twitcher/editor/inspector/user_converter.tscn")
const UserConverter = preload("res://addons/twitcher/editor/inspector/user_converter.gd")


var _converter: UserConverter
var _user_property_name: StringName


func _init(user_property_name: StringName):
	_user_property_name = user_property_name

	_converter = USER_CONVERTER.instantiate()
	_converter.user_login_changed.connect(_on_user_login_changed)
	add_child(_converter)


func _update_property() -> void:
	var object = get_edited_object()
	var user: TwitchUser = object[_user_property_name]
	if user == null:
		_converter.user_id = ""
		_converter.user_login = ""
	else:
		_converter.user_id = user.id
		_converter.user_login = user.login


func _on_user_login_changed(new_user_login: String) -> void:
	var current_user_login = get_edited_object()[get_edited_property()]
	if new_user_login != current_user_login:
		emit_changed(get_edited_property(), new_user_login, &"", true)
