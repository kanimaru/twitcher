@tool
extends EditorInspectorPlugin

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const UserProperty = preload("res://addons/twitcher/editor/inspector/user_property.gd")
const TEST_CREDENTIALS = preload("res://addons/twitcher/editor/setup/test_credentials.tscn")
const TestCredentials = preload("res://addons/twitcher/editor/setup/test_credentials.gd")

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
			info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var authorize_editor: TestCredentials = TEST_CREDENTIALS.instantiate()
			authorize_editor.text = "Authorize Editor"
			authorize_editor.oauth_setting = TwitchEditorSettings.editor_oauth_setting
			authorize_editor.oauth_token = TwitchEditorSettings.editor_oauth_token
			authorize_editor.disabled = not TwitchEditorSettings.editor_oauth_setting.is_valid()
			authorize_editor.authorized.connect(_on_authorized.bind(object))
			
			var hbox: HBoxContainer = HBoxContainer.new()
			hbox.add_child(info_label)
			hbox.add_child(authorize_editor)
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			add_custom_control(hbox)
		
	return false
	

func _on_authorized(object: Object) -> void:
	EditorInterface.get_inspector().edit(null)
	EditorInterface.get_inspector().edit(object)
