@tool
extends EditorInspectorPlugin

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const UserProperty = preload("res://addons/twitcher/editor/inspector/user_property.gd")
const TwitchAuthorizeEditor = preload("res://addons/twitcher/editor/inspector/twitch_authorize_editor.gd")

func _can_handle(object: Object) -> bool:
	return true
	

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if hint_string == "TwitchUser":
		
		if TwitchEditorSettings.is_valid():
			add_property_editor(name, UserProperty.new()) 
			return true
		else:
			var authorize_editor = TwitchAuthorizeEditor.new(name)
			authorize_editor.authorized.connect(_on_authorized.bind(object), CONNECT_DEFERRED)
			add_custom_control(authorize_editor)
		
	return false
	

func _on_authorized(object: Object) -> void:
	EditorInterface.get_inspector().edit(null)
	EditorInterface.get_inspector().edit(object)
