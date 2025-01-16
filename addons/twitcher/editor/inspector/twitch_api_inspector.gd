@tool
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is TwitchAPI


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == &"default_broadcaster_login":
		var property = UserProperty.new(&"broadcaster_user")
		add_property_editor(&"default_broadcaster_login", property, false, "Default Broadcaster")
		return true
	return false
