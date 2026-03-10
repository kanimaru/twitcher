@tool
extends EditorInspectorPlugin

const TWITCH_BOT_AUTH_NOTIFICATION = preload("uid://c2ixi5g2j175x")


func _can_handle(object: Object) -> bool:
	return object is TwitchBot


func _parse_property(_object: Object, _type: Variant.Type, name: String, _hint_type: PropertyHint, \
	_hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	if name == &"sender":
		add_custom_control(AuthorizeBotProperty.new())
	return false


class AuthorizeBotProperty extends EditorProperty:
		
	var window: Window

	func _init() -> void:
		window = TWITCH_BOT_AUTH_NOTIFICATION.instantiate()
		window.hide()
		
		var button: Button = Button.new()
		button.text = "Authorize Sender"
		button.pressed.connect(_open_window)
		add_child(button)
		add_child(window)


	func _open_window() -> void:
		window.show()
