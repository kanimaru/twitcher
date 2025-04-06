@tool
extends EditorInspectorPlugin

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

func _can_handle(object: Object) -> bool:
	return true
	
	
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if hint_string == "TwitchUser":
		
		if TwitchEditorSettings.is_valid():
			add_property_editor(name, UserProperty.new()) 
			return true
		else:
			var info_label: Label = Label.new()
			info_label.text = "Authorize editor to have a custom inspector for the '%s'." % name.capitalize()
			info_label.label_settings = LabelSettings.new()
			info_label.label_settings.font_size = 13
			info_label.label_settings.font_color = Color.AQUA
			info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			add_custom_control(info_label)
		
	return false
