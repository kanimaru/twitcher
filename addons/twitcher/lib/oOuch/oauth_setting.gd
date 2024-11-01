@tool
extends Resource
class_name OAuthSetting

const OAuthHTTPClient = preload("./http_client.gd")

## What is the redirect port
@export var redirect_url: String:
	set = set_redirect_url
## Wellknown endpoint
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
@export var authorization_flow: OAuth.AuthorizationFlow
@export var _encryption_key_provider: CryptoKeyProvider = preload("res://addons/twitcher/lib/oOuch/default_key_provider.tres")

# Calculated Values
@export_storage var token_host: String
@export_storage var token_path: String
@export_storage var authorization_host: String
@export_storage var authorization_path: String
@export_storage var device_authorization_host: String
@export_storage var device_authorization_path: String
@export_storage var redirect_path: String
@export_storage var redirect_port: int
## Client Secret to authorize (optional depending on flow)
@export_storage var client_secret: String

var _crypto: Crypto = Crypto.new()

var _well_known_setting: Dictionary

var _url_regex = RegEx.create_from_string("((https?://)?([^:/]+))(:([0-9]+))?(/.*)?")


func _update_authorization_url(value: String) -> void:
	authorization_url = value
	var matches = _url_regex.search(value)
	if matches == null:
		authorization_host = ""
		authorization_path = ""
		emit_changed()
		return
	authorization_host = matches.get_string(1)
	authorization_path = matches.get_string(6)
	emit_changed()

func _update_token_url(value: String) -> void:
	token_url = value
	var matches = _url_regex.search(value)
	if matches == null:
		token_host = ""
		token_path = ""
		emit_changed()
		return
	token_host = matches.get_string(1)
	token_path = matches.get_string(6)
	emit_changed()


func _update_device_authorization_url(value: String) -> void:
	device_authorization_url = value
	var matches = _url_regex.search(value)
	if matches == null:
		device_authorization_host = ""
		device_authorization_path = ""
		emit_changed()
		return
	device_authorization_host = matches.get_string(1)
	device_authorization_path = matches.get_string(6)
	emit_changed()


func set_redirect_url(value: String) -> void:
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
	var request = http_client.request(path, HTTPClient.METHOD_GET, OAuthHTTPClient.HEADERS, "")
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
