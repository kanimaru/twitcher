extends EditorInspectorPlugin

var _encryption_key_provider: CryptoKeyProvider

func _init(encryption_key_provider: CryptoKeyProvider) -> void:
	_encryption_key_provider = encryption_key_provider


func _can_handle(object: Object) -> bool:
	return object is OAuthSetting


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == "client_id":
		add_property_editor("client_secret", SecretProperty.new(_encryption_key_provider.key), true, "Client Secret")
	return false


class SecretProperty extends EditorProperty:
	var _crypto: Crypto = Crypto.new()
	var _crypto_key: CryptoKey
	var _line_edit: LineEdit = LineEdit.new()


	func _init(crypto_key: CryptoKey) -> void:
		_crypto_key = crypto_key
		_line_edit.secret = true
		_line_edit.text_submitted.connect(_on_text_changed)
		_line_edit.focus_exited.connect(_on_focus_exited)
		add_child(_line_edit)
		add_focusable(_line_edit)


	func _update_property() -> void:
		var secret = get_edited_object()[get_edited_property()]
		var value_raw = Marshalls.base64_to_raw(secret)
		var value_bytes := _crypto.decrypt(_crypto_key, value_raw)
		var value = value_bytes.get_string_from_utf8()
		_line_edit.text = value


	func _on_focus_exited() -> void:
		_save()


	func _on_text_changed(_new_text: String) -> void:
		_save()


	func _save() -> void:
		var plain_value = _line_edit.text
		var encrypted_value := _crypto.encrypt(_crypto_key, plain_value.to_utf8_buffer())
		var secret = Marshalls.raw_to_base64(encrypted_value)
		emit_changed(get_edited_property(), secret)
