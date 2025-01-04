@tool
extends EditorInspectorPlugin


const USER_CONVERTER = preload("res://addons/twitcher/inspector/user_converter.tscn")
const UserConverter = preload("res://addons/twitcher/inspector/user_converter.gd")


func _can_handle(object: Object) -> bool:
	return object is TwitchChat


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == &"target_user_channel":
		var property = UserProperty.new(&"broadcaster_user")
		add_property_editor(&"target_user_channel", property, false, "Target Broadcaster")
		return true

	return false


class UserProperty extends EditorProperty:
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
