@tool
extends EditorInspectorPlugin

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

func _can_handle(object: Object) -> bool:
	return true
	
	
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	var token_valid = TwitchEditorSettings.editor_token != null && TwitchEditorSettings.editor_token.is_token_valid()
	if hint_string == "TwitchUser" && token_valid:
		add_property_editor(name, UserProperty.new(name)) 
		return true
	return false
