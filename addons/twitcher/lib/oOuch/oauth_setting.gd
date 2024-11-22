@tool
extends Resource
class_name OAuthSetting

const OAuthHTTPClient = preload("res://addons/twitcher/lib/http/buffered_http_client.gd")

## That will be called when the authcode was received to send the code to the backend
@export var redirect_url: String:
	set = _update_redirect_url
## Wellknown endpoint to receive the common paths for the IAM provider (optional)
@export var well_known_url: String
## Path where tokens can be get
@export var token_url: String:
	set = _update_token_url
## Path to the authorization endpoint
@export var authorization_url: String:
	set = _update_authorization_url
## Path to the device code flow URL.
@export var device_authorization_url: String:
	set = _update_device_authorization_url
## Where should the tokens be cached
@export var cache_file: String = "res://auth.key"
## Client ID to authorize
@export var client_id: String
## Defines the authorization flow.
@export var authorization_flow: OAuth.AuthorizationFlow = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW:
	set(val):
		authorization_flow = val
		notify_property_list_changed()

@export var _encryption_key_provider: CryptoKeyProvider = preload("res://addons/twitcher/lib/oOuch/default_key_provider.tres")

# Calculated Values
var token_host: String:
	get():
		if token_host == "" and token_url != "": _update_token_url(token_url)
		return token_host
var token_path: String:
	get():
		if token_path == "" and token_url != "": _update_token_url(token_url)
		return token_path
var authorization_host: String:
	get():
		if authorization_host == "" and authorization_url != "": _update_authorization_url(authorization_url)
		return authorization_host
var authorization_path: String:
	get():
		if authorization_path == "" and authorization_url != "": _update_authorization_url(authorization_url)
		return authorization_path
var device_authorization_host: String:
	get():
		if device_authorization_host == "" and device_authorization_url != "": _update_device_authorization_url(device_authorization_url)
		return device_authorization_host
var device_authorization_path: String:
	get():
		if device_authorization_path == "" and device_authorization_url != "": _update_device_authorization_url(device_authorization_url)
		return device_authorization_path
var redirect_path: String:
	get():
		if redirect_path == "" and redirect_url != "": _update_redirect_url(redirect_url)
		return redirect_path
var redirect_port: int:
	get():
		if redirect_port == 0 and redirect_url != "": _update_redirect_url(redirect_url)
		return redirect_port

## Client Secret to authorize (optional depending on flow)
@export_storage var client_secret: String

var _crypto: Crypto = Crypto.new()

var _well_known_setting: Dictionary

var _url_regex = RegEx.create_from_string("((https?://)?([^:/]+))(:([0-9]+))?(/.*)?")


func _update_authorization_url(value: String) -> void:
	authorization_url = value
	var matches = _url_regex.search(value)
	if matches == null: return
	authorization_host = matches.get_string(1)
	authorization_path = matches.get_string(6)
	emit_changed()


func _update_token_url(value: String) -> void:
	token_url = value
	var matches = _url_regex.search(value)
	if matches == null: return
	token_host = matches.get_string(1)
	token_path = matches.get_string(6)
	emit_changed()


func _update_device_authorization_url(value: String) -> void:
	device_authorization_url = value
	var matches = _url_regex.search(value)
	if matches == null: return
	device_authorization_host = matches.get_string(1)
	device_authorization_path = matches.get_string(6)
	emit_changed()


func _update_redirect_url(value: String) -> void:
	redirect_url = value;
	var matches = _url_regex.search(value)
	if matches == null:
		redirect_path = "/"
		redirect_port = 7170
		emit_changed()
		return

	var path = matches.get_string(6)
	var port = matches.get_string(5)
	redirect_path = path if path != "" else "/"
	redirect_port = int(port) if port != "" else 7170
	emit_changed()


func load_from_wellknown(wellknow_url: String) -> void:
	var matches = _url_regex.search(wellknow_url)
	var url = matches.get_string(1)
	var port = matches.get_string(5)
	if port == "": port = -1
	var path = matches.get_string(6)
	var http_client = OAuthHTTPClient.new(url, port)
	var request = http_client.request(path, HTTPClient.METHOD_GET, {}, "")
	var response = await http_client.wait_for_request(request) as OAuthHTTPClient.ResponseData
	var json = JSON.parse_string(response.response_data.get_string_from_utf8())
	token_url = json["token_endpoint"]
	authorization_url = json["authorization_endpoint"]
	device_authorization_url = json.get("device_authorization_endpoint", "")
	_well_known_setting = json
	emit_changed()


func get_client_secret() -> String:
	var value_raw = Marshalls.base64_to_raw(client_secret)
	var value_bytes := _crypto.decrypt(_encryption_key_provider.key, value_raw)
	return value_bytes.get_string_from_utf8()


func _validate_property(property: Dictionary) -> void:
	match authorization_flow:
		OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW:
			if property.name == "client_id":
				property.usage &= ~PROPERTY_USAGE_READ_ONLY
			if property.name == "client_secret":
				property.usage &= ~PROPERTY_USAGE_READ_ONLY

		OAuth.AuthorizationFlow.IMPLICIT_FLOW:
			if property.name == "client_id":
				property.usage &= ~PROPERTY_USAGE_READ_ONLY
			if property.name == "client_secret":
				property.usage |= PROPERTY_USAGE_READ_ONLY

		OAuth.AuthorizationFlow.DEVICE_CODE_FLOW:
			if property.name == "client_id":
				property.usage &= ~PROPERTY_USAGE_READ_ONLY
			if property.name == "client_secret":
				property.usage |= PROPERTY_USAGE_READ_ONLY

		OAuth.AuthorizationFlow.CLIENT_CREDENTIALS:
			if property.name == "client_id":
				property.usage &= ~PROPERTY_USAGE_READ_ONLY
			if property.name == "client_secret":
				property.usage &= ~PROPERTY_USAGE_READ_ONLY
