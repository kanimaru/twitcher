@tool
extends VBoxContainer

## Helper class to get an UI for authorize the Editor

const TEST_CREDENTIALS: PackedScene = preload("res://addons/twitcher/editor/setup/test_credentials.tscn")
const TestCredentials = preload("res://addons/twitcher/editor/setup/test_credentials.gd")

signal authorized

func _init(name_of_object_to_edit: String) -> void:
	var info_label: Label = Label.new()
	info_label.text = "Authorize editor to have a custom inspector for the '%s'." % name_of_object_to_edit.capitalize()
	info_label.label_settings = LabelSettings.new()
	info_label.label_settings.font_size = 13
	info_label.label_settings.font_color = Color.AQUA
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var authorize_editor: TestCredentials = TEST_CREDENTIALS.instantiate()
	authorize_editor.text = "Authorize Editor"
	authorize_editor.authorized.connect(func(): authorized.emit())
	
	add_child(info_label)
	add_child(authorize_editor)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
