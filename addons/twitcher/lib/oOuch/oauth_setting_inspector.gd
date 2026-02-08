@tool
extends EditorInspectorPlugin

const BufferedHttpClient: BufferedHTTPClient = preload("res://addons/twitcher/lib/http/buffered_http_client.gd")
const EncryptionKeyProvider: CryptoKeyProvider = preload("res://addons/twitcher/lib/oOuch/default_key_provider.tres")


func _can_handle(object: Object) -> bool:
	return object is OAuthSetting


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == "well_known_url":
		add_property_editor("well_known_url", WellKnownUriProperty.new())
		return true
	return false


class WellKnownUriProperty extends EditorProperty:
	var _url_regex: RegEx = RegEx.create_from_string("((https?://)?([^:/]+))(:([0-9]+))?(/.*)?")

	var _container: VBoxContainer
	var _well_known_url: LineEdit
	var _submit: Button
	var _client: BufferedHttpClient
	
	func _init() -> void:
		_container = VBoxContainer.new()
		_client = BufferedHttpClient.new()
		_client.name = "OauthSettingInspectorClient"
		add_child(_client)

		_well_known_url = LineEdit.new()
		_well_known_url.placeholder_text = "https://id.twitch.tv/oauth2/.well-known/openid-configuration"
		_well_known_url.text_changed.connect(_on_text_changed)
		add_focusable(_well_known_url)
		_container.add_child(_well_known_url)

		_submit = Button.new()
		_submit.pressed.connect(_on_submit_clicked)
		_submit.text = "Update URIs"
		_container.add_child(_submit)
		add_focusable(_submit)
		add_child(_container)


	func _on_text_changed(new_text: String) -> void:
		emit_changed(get_edited_property(), new_text)


	func _update_property() -> void:
		_well_known_url.text = get_edited_object()[get_edited_property()]


	func load_from_wellknown(wellknow_url: String) -> void:
		var request = _client.request(wellknow_url, HTTPClient.METHOD_GET, {}, "")
		var response = await _client.wait_for_request(request) as BufferedHttpClient.ResponseData
		var json = JSON.parse_string(response.response_data.get_string_from_utf8())

		var device_code = json.get("device_authorization_endpoint", "")
		if device_code != "":
			emit_changed(&"device_authorization_url", device_code)
		var token_endpoint = json["token_endpoint"]
		if token_endpoint != "":
			emit_changed(&"token_url", token_endpoint)
		var authorization_endpoint = json["authorization_endpoint"]
		if authorization_endpoint != "":
			emit_changed(&"authorization_url", authorization_endpoint)


	func _on_submit_clicked() -> void:
		_submit.disabled = true
		var wellknownurl: String = _well_known_url.text if _well_known_url.text != "" else _well_known_url.placeholder_text
		await load_from_wellknown(wellknownurl)
		_submit.disabled = false
