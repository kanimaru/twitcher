@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is TwitchMediaLoader


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == &"image_magic_path":
		add_property_editor(name, MagicPathEditor.new())
		return true

	if name == &"cache_emote":
		var clear_emote_button = ClearCacheEditor.new(object.cache_emote)
		add_property_editor("cache_cheermote", clear_emote_button, true, "Clear Emote Cache")

	if name == &"cache_badge":
		var clear_badge_button = ClearCacheEditor.new(object.cache_badge)
		add_property_editor("cache_cheermote", clear_badge_button, true, "Clear Badge Cache")

	if name == &"cache_cheermote":
		var clear_cheermote_button = ClearCacheEditor.new(object.cache_cheermote)
		add_property_editor("cache_cheermote", clear_cheermote_button, true, "Clear Cheermotes Cache")

	return false


class ClearCacheEditor extends EditorProperty:

	var _button: Button

	func _init(path: String) -> void:
		_button = Button.new()
		_button.text = "Clear"
		_button.pressed.connect(_clear.bind(path))
		add_child(_button)


	func _clear(path: String) -> Dictionary:
		var dir = DirAccess.open(path)
		for file in dir.get_files():
			if file.ends_with(".res"):
				var err = dir.remove(file)
				if err != OK:
					return { "result": err, "folder": dir, "file": file }
		return { "result": OK }


class MagicPathEditor extends EditorProperty:
	var path_line: LineEdit
	var dialog: EditorFileDialog
	var select_file: Button

	func _init() -> void:
		var container = HBoxContainer.new()
		path_line = LineEdit.new()
		path_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		path_line.placeholder_text = "Path to ImageMagic"
		path_line.text_changed.connect(_on_path_changed)

		var gui = EditorInterface.get_base_control()
		var browse_icon = gui.get_theme_icon(&"FileBrowse", &"EditorIcons")

		select_file = Button.new()
		select_file.icon = browse_icon
		select_file.pressed.connect(_on_open_file_select)

		container.add_child(path_line)
		container.add_child(select_file)
		add_child(container)


	func _update_property() -> void:
		var edited_object = get_edited_object()
		var edited_property = get_edited_property()
		path_line.text = edited_object[edited_property]

		var transformer_name = edited_object["image_transformer"]
		select_file.disabled = transformer_name != &"MagicImageTransformer"
		path_line.editable = transformer_name == &"MagicImageTransformer"

	func _on_open_file_select() -> void:
		dialog = EditorFileDialog.new()
		dialog.disable_overwrite_warning = true
		dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
		dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
		dialog.file_selected.connect(_on_file_selected)
		add_child(dialog)
		dialog.popup_file_dialog()


	func _on_file_selected(path: String) -> void:
		path_line.text = path
		_on_path_changed(path)


	func _on_path_changed(new_text: String) -> void:
		emit_changed(get_edited_property(), new_text, &"", true)
