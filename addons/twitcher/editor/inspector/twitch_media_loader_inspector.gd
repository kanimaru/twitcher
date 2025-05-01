@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is TwitchMediaLoader


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
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


	func _clear(path: String) -> void:
		var dir: DirAccess = DirAccess.open(path)
		for file: String in dir.get_files():
			if file.ends_with(".res"):
				var err: Error = dir.remove(file)
				if err != OK:
					push_error("Can't delete %s/%s cause of %s" % [dir, file, error_string(err)])
		var tween = create_tween()
		var _button_color = _button.modulate
		tween.tween_property(_button, "modulate", Color.GREEN, .25)
		tween.tween_property(_button, "modulate", _button_color, .25)
		tween.play()
