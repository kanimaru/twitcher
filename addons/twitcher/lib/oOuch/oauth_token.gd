@tool
extends Resource

## Used to store and load token's and to exchange them through the code.
## Try to avoid debugging this object cause it leaks your access and refresh tokens
## Hint never store the token value as string in your code to reduce the chance
## to leak the tokens always use the getter.

class_name OAuthToken

static var CRYPTO: Crypto = Crypto.new()

## Key for encryption purpose to save the tokens
@export var _crypto_key_provider: CryptoKeyProvider = preload("res://addons/twitcher/lib/oOuch/default_key_provider.tres")
## Unique identifier to store multiple tokens within one config file
@export var _identifier: String = "Auth-%s" % randi_range(0, 10000)
## Storage where the tokens should be saved encrypted (multiple secrets can be put in the same file see _identifier)
@export var _cache_path: String = "user://auth.conf":
	set(val):
		_cache_path = val
		_load_tokens()

var _scopes: PackedStringArray = [];
var _expire_date: int;
var _config_file: ConfigFile = ConfigFile.new()

var _access_token: String = "":
	set(val):
		_access_token = val
		if val != "": authorized.emit()
var _refresh_token: String = "";


## Called when the token was resolved / accesstoken got refreshed
signal authorized


func update_values(access_token: String, refresh_token: String, expire_in: int, scopes: Array[String]):
	_expire_date = roundi(Time.get_unix_time_from_system() + expire_in);
	_access_token = access_token;
	_refresh_token = refresh_token;
	_scopes = scopes;
	_persist_tokens();


## Persists the tokesn with the expire date
func _persist_tokens():
	var encrypted_access_token = CRYPTO.encrypt(_crypto_key_provider.key, _access_token.to_utf8_buffer())
	var encrypted_refresh_token = CRYPTO.encrypt(_crypto_key_provider.key, _refresh_token.to_utf8_buffer())
	_config_file.load(_cache_path)
	_config_file.set_value(_identifier, "expire_date", _expire_date);
	_config_file.set_value(_identifier, "access_token", Marshalls.raw_to_base64(encrypted_access_token));
	_config_file.set_value(_identifier, "refresh_token", Marshalls.raw_to_base64(encrypted_refresh_token));
	_config_file.set_value(_identifier, "scopes", ",".join(_scopes));
	_config_file.save(_cache_path);


## Loads the tokens and returns the information if the file got created
func _load_tokens() -> bool:
	var status = _config_file.load(_cache_path)
	if status == OK && _config_file.has_section(_identifier):
		_expire_date = _config_file.get_value(_identifier, "expire_date", 0);
		var encrypted_access_token = Marshalls.base64_to_raw(_config_file.get_value(_identifier, "access_token"));
		var encrypted_refresh_token = Marshalls.base64_to_raw(_config_file.get_value(_identifier, "refresh_token"));
		_access_token = CRYPTO.decrypt(_crypto_key_provider.key, encrypted_access_token).get_string_from_utf8()
		_refresh_token = CRYPTO.decrypt(_crypto_key_provider.key, encrypted_refresh_token).get_string_from_utf8()
		_scopes = _config_file.get_value(_identifier, "scopes", "").split(",");
		return true;
	return false;


func remove_tokens() -> void:
	var status = _config_file.load(_cache_path)
	print(status, _config_file.get_sections())
	if status == OK && _config_file.has_section(_identifier):
		_access_token = ""
		_refresh_token = ""
		_expire_date = 0
		_scopes.clear()

		_config_file.erase_section(_identifier)
		_config_file.save(_cache_path)
		print("%s got revoked" % _identifier)
	else:
		print("%s not found" % _identifier)


func get_refresh_token() -> String:
	return _refresh_token;


func get_access_token() -> String:
	return _access_token;


func get_scopes() -> PackedStringArray:
	return _scopes;


## The unix timestamp when the token is expiring
func get_expiration() -> int:
	return _expire_date


func get_expiration_readable() -> String:
	return Time.get_datetime_string_from_unix_time(_expire_date, true)


func invalidate() -> void:
	_expire_date = 0;
	_refresh_token = "";
	_access_token = ""
	_scopes = [];


## Does this accesstoken has a refresh token
func has_refresh_token() -> bool:
	return _refresh_token != "";


## Checks if the access token is still valid
func is_token_valid() -> bool:
	var current_time = Time.get_unix_time_from_system();
	return current_time < _expire_date;


## Get all token names within a config file
static func get_identifiers(cache_file: String) -> PackedStringArray:
	var _config_file: ConfigFile = ConfigFile.new();
	var status = _config_file.load(cache_file)
	if status != OK: return []
	return _config_file.get_sections()
