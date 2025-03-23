@icon("./scope-icon.svg")
@tool
extends Resource
class_name OAuthSetting


## That will be called when the authcode was received to send the code to the backend
@export var redirect_url: String = "http://localhost:7170":
	set = _update_redirect_url
## Wellknown endpoint to receive the common paths for the IAM provider (optional)
@export var well_known_url: String
## Path where tokens can be get
@export var token_url: String
## Path to the authorization endpoint
@export var authorization_url: String
## Path to the device code flow URL.
@export var device_authorization_url: String
## Where should the tokens be cached
@export var cache_file: String = "res://auth.key"
## Client ID to authorize
@export var client_id: String:
	set(val): 
		client_id = val
		emit_changed()
## Defines the authorization flow.
@export var authorization_flow: OAuth.AuthorizationFlow = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW:
	set(val):
		authorization_flow = val
		notify_property_list_changed()
		emit_changed()

@export var _encryption_key_provider: CryptoKeyProvider = preload("res://addons/twitcher/lib/oOuch/default_key_provider.tres")

# Calculated Values
var redirect_path: String:
	get():
		if redirect_path == "" and redirect_url != "": _update_redirect_url(redirect_url)
		return redirect_path
var redirect_port: int:
	get():
		if redirect_port == 0 and redirect_url != "": _update_redirect_url(redirect_url)
		return redirect_port

## Client Secret to authorize (optional depending on flow)
@export_storage var client_secret: String:
	set(val): 
		client_secret = val if val != null || val != "" else ""
		emit_changed()
		

var _crypto: Crypto = Crypto.new()

var _well_known_setting: Dictionary

var _url_regex = RegEx.create_from_string("((https?://)?([^:/]+))(:([0-9]+))?(/.*)?")


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


func get_client_secret() -> String:
	if client_secret == "" || client_secret == null: return ""
	var value_raw = Marshalls.base64_to_raw(client_secret)
	var value_bytes := _encryption_key_provider.decrypt(value_raw)
	return value_bytes.get_string_from_utf8()
	
	
func set_client_secret(plain_secret: String) -> void:
	var encrypted_value := _encryption_key_provider.encrypt(plain_secret.to_utf8_buffer())
	client_secret = Marshalls.raw_to_base64(encrypted_value)


func _validate_property(property: Dictionary) -> void:
	if property.name == "client_secret":
		if _is_client_secret_need():
			property.usage |= PROPERTY_USAGE_READ_ONLY
		else:
			property.usage &= ~PROPERTY_USAGE_READ_ONLY


func _is_client_secret_need() -> bool:
	return authorization_flow == OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW || \
		authorization_flow == OAuth.AuthorizationFlow.CLIENT_CREDENTIALS


func is_valid() -> bool:
	var problems = get_valididation_problems()
	return problems.is_empty()


func get_valididation_problems() -> PackedStringArray:
	var result: PackedStringArray = []
	if client_id == "" || client_id == null:
		result.append("Client ID is missing")
	if _is_client_secret_need() && (client_secret == "" || client_secret == null):
		result.append("Client Secret is missing")
	return result

	
