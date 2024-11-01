extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is TwitchAuth


func _parse_category(object: Object, category: String) -> void:
	if category == "twitch_auth.gd":
		add_custom_control(AuthProperty.new())


class AuthProperty extends EditorProperty:

	var _authorize: Button


	func _init() -> void:
		_authorize = Button.new()
		_authorize.text = "Authorize"
		_authorize.pressed.connect(_on_authorize)
		add_child(_authorize)
		add_focusable(_authorize)


	func _on_authorize() -> void:
		var auth: TwitchAuth = get_edited_object()
		print("The secret to success is listenting to:", auth.setting.get_client_secret())
		auth.authorize()
