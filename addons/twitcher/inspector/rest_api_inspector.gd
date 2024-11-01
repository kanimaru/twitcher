extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is TwitchRestAPI


func _parse_category(object: Object, category: String) -> void:
	if category == "twitch_rest_api.gd":
		add_custom_control(CopyBroadcaster.new())


class CopyBroadcaster extends EditorProperty:
	var copy_broadcaster_id : Button = Button.new()

	func _init() -> void:
		copy_broadcaster_id.text = "Copy Broadcaster ID"
		copy_broadcaster_id.pressed.connect(_on_copy_pressed)
		add_child(copy_broadcaster_id)
		add_focusable(copy_broadcaster_id)

	func _on_copy_pressed() -> void:
		var rest: TwitchRestAPI = get_edited_object()
		var current_users: TwitchGetUsersResponse = await rest.get_users([], [])
		var current_user = current_users.data[0]
		DisplayServer.clipboard_set(current_user.id)
