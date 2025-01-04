@tool
extends EditorInspectorPlugin

const Constants = preload("res://addons/twitcher/constants.gd")

func _can_handle(object: Object) -> bool:
	return object is TwitchService


func _parse_category(object: Object, category: String) -> void:
	if category == "twitch_service.gd" && object.get_class() != &"EditorDebuggerRemoteObject":
		add_custom_control(AuthProperty.new())
		var twitch_service: TwitchService = object



class AuthProperty extends EditorProperty:

	var _container: Node
	var _authorize: Button
	var _copy_broadcaster_id: Button


	func _init() -> void:
		_container = VBoxContainer.new()

		_authorize = Button.new()
		_authorize.text = "Authorize Editor"
		_authorize.pressed.connect(_on_authorize)
		_container.add_child(_authorize)
		add_focusable(_authorize)

		_copy_broadcaster_id = Button.new()
		_copy_broadcaster_id.text = "Copy Broadcaster ID"
		_copy_broadcaster_id.pressed.connect(_on_copy_broadcaster_id)
		_copy_broadcaster_id.disabled = true
		_container.add_child(_copy_broadcaster_id)
		add_focusable(_copy_broadcaster_id)

		add_child(_container)
		set_bottom_editor(_container)


	func _update_property() -> void:
		var twitch_service: TwitchService = get_edited_object()
		if twitch_service.token.authorized.is_connected(_on_authorized):
			twitch_service.token.authorized.disconnect(_on_authorized)
		twitch_service.token.authorized.connect(_on_authorized)
		if twitch_service.token.is_token_valid():
			_on_authorized()


	func _on_authorized() -> void:
		_copy_broadcaster_id.disabled = false


	func _on_copy_broadcaster_id() -> void:
		var twitch_service: TwitchService = get_edited_object()
		var user = await twitch_service.get_current_user()
		DisplayServer.clipboard_set(user.id)


	func _on_authorize() -> void:
		var twitch_service: TwitchService = get_edited_object()
		print("Do authorize the editor...")
		await twitch_service.auth.authorize()
		print("Authorize the editor.")
		_on_authorized()
