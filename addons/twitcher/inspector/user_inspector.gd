extends EditorInspectorPlugin


const USER_CONVERTER = preload("res://addons/twitcher/inspector/user_converter.tscn")
const UserConverter = preload("res://addons/twitcher/inspector/user_converter.gd")

func _can_handle(object: Object) -> bool:
	if object is TwitchChat:
		return true
	return false


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:

	if name == &"target_user_channel":
		var property = UserProperty.new(&"broadcaster_user", object.rest)
		object.rest_updated.connect(property.on_rest_updated)
		add_property_editor(&"target_user_channel", property, false, "Target Broadcaster")
		return true

	return false


class UserProperty extends EditorProperty:
	var _converter: UserConverter
	var _user_property_name: StringName
	var _rest: TwitchRestAPI


	func _init(user_property_name: StringName, rest: TwitchRestAPI):
		_user_property_name = user_property_name
		_rest = rest

		_converter = USER_CONVERTER.instantiate()
		_converter.user_loaded.connect(_on_user_loaded)
		add_child(_converter)


	func _update_property() -> void:
		_converter.rest = _rest
		var object = get_edited_object()
		var user: TwitchUser = object[_user_property_name]
		if user == null:
			var user_login = object[get_edited_property()]
			if user_login == null or user_login == "": return
			print("Load user ", user_login, _rest)
			user = await _converter.load_user(user_login, "")

		_converter.user_id = user.id
		_converter.user_login = user.login


	func on_rest_updated(rest: TwitchRestAPI) -> void:
		_converter.rest = rest

	func _on_user_loaded(user: TwitchUser) -> void:
		var obj = get_edited_object()
		obj[_user_property_name] = user

		var user_login = obj[get_edited_property()]
		if user_login != user.login:
			emit_changed(get_edited_property(), user.login, &"", true)
