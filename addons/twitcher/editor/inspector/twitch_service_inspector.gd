@tool
extends EditorInspectorPlugin

const AuthorizationEditorProperty = preload("res://addons/twitcher/editor/inspector/authorization_editor_property.gd")

func _can_handle(object: Object) -> bool:
	return object is TwitchService


func _parse_category(object: Object, category: String) -> void:
	if category == "twitch_service.gd" && object.get_class() != &"EditorDebuggerRemoteObject":
		add_custom_control(AuthorizationEditorProperty.new())
