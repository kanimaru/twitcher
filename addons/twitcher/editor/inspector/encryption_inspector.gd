@tool
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if hint_type == PropertyHint.PROPERTY_HINT_PASSWORD and hint_string == "encrypted":
		add_property_editor(name, EncryptionProperty.new())
		return true
	return false
