@tool
extends EditorProperty

class_name EncryptionProperty

const EncryptionKeyProvider: CryptoKeyProvider = preload("res://addons/twitcher/lib/oOuch/default_key_provider.tres")	

var _line_edit: LineEdit = LineEdit.new()


func _init() -> void:
	_line_edit.secret = true
	_line_edit.text_submitted.connect(_on_text_changed)
	_line_edit.focus_exited.connect(_on_focus_exited)
	add_child(_line_edit)
	add_focusable(_line_edit)


func _update_property() -> void:
	var secret = get_edited_object()[get_edited_property()]
	
	if secret == "": _line_edit.text = ""
	var value_raw := Marshalls.base64_to_raw(secret)
	var value_bytes := EncryptionKeyProvider.decrypt(value_raw)
	_line_edit.text = value_bytes.get_string_from_utf8()


func _on_focus_exited() -> void:
	_save()


func _on_text_changed(_new_text: String) -> void:
	_save()


func _save() -> void:
	var plain_value = _line_edit.text
	if plain_value == "":
		emit_changed(get_edited_property(), "")
		return
	var encrypted_value := EncryptionKeyProvider.encrypt(plain_value.to_utf8_buffer())
	emit_changed(get_edited_property(), Marshalls.raw_to_base64(encrypted_value))
