@tool
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is TwitchService


func _parse_category(object: Object, category: String) -> void:
	if category == "twitch_service.gd" && object.get_class() != &"EditorDebuggerRemoteObject":
		add_custom_control(AuthProperty.new())
		var twitch_service: TwitchService = object


class AuthProperty extends EditorProperty:

	var _container: Node
	var _authorize: Button


	func _init() -> void:
		_container = VBoxContainer.new()

		_authorize = Button.new()
		_authorize.text = "Authorize Editor"
		_authorize.pressed.connect(_on_authorize)
		
		_container.add_child(_authorize)
		add_focusable(_authorize)

		add_child(_container)
		set_bottom_editor(_container)

	func _on_authorize() -> void:
		var twitch_service: TwitchService = get_edited_object()
		if not twitch_service.is_configured():
			printerr("Twitch Service is not configured correctly please fix the warnings.")
		else:
			print("Do authorize the editor...")
			await twitch_service.auth.authorize()
