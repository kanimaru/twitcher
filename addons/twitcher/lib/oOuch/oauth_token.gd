@icon("./security-icon.svg")
@tool
extends Resource

## Used to store and load token's and to exchange them through the code.
## Try to avoid debugging this object cause it leaks your access and refresh tokens
## Hint never store the token value as string in your code to reduce the chance
## to leak the tokens always use the getter.

class_name OAuthToken

static var CRYPTO: Crypto = Crypto.new()

const APP_ACCESS_TOKEN: StringName = &"App Access Token"
const USER_ACCESS_TOKEN: StringName = &"User Access Token"

## Key for encryption purpose to save the tokens
@export var _crypto_key_provider: CryptoKeyProvider = preload("res://addons/twitcher/lib/oOuch/default_key_provider.tres")
## Storage where the tokens should be saved encrypted (multiple secrets can be put in the same file)
@export var _cache_path: String = "user://auth.conf":
	set(val):
		_cache_path = val
		load_tokens()

## Returns if its an user access token or app accesstoken
var type: StringName
var _scopes: PackedStringArray = []
var _expire_date: int
var _config_file: ConfigFile = ConfigFile.new()
var _creation_stack: Array = []
## To get a sanatized unique name for the token id
var _sanatize_regex: RegEx = RegEx.create_from_string("[^\\w]")

func _init() -> void:
	_creation_stack = get_stack()


var _access_token: String = "":
	set(val):
		_access_token = val
		if val != "": authorized.emit()
var _refresh_token: String = ""


## Called when the token was resolved / accesstoken got refreshed
signal authorized


func _get_storage_key() -> String:
	if resource_path and ResourceLoader.exists(resource_path):
		var uid: int = ResourceLoader.get_resource_uid(resource_path)
		if uid != ResourceUID.INVALID_ID:
			return ResourceUID.id_to_text(uid)
		else:
			return _sanatize_regex.sub(resource_path, "")
	return "Auth-" + resource_name


## Update the visual representation of the scopes (don't use it for actually changing scopes it wont work!)
# Client credential flow doesn't return used scopes and I wanted to give the use feedback over the scopes
func _update_scopes(scopes: Array[StringName]) -> void:
	for scope in scopes: _scopes.append(scope)
	_persist_tokens()
	emit_changed()


## Updates the data in the scopes and persist it
func update_values(access_token: String, refresh_token: String, expire_in: int, scopes: Array[String], token_type: StringName) -> void:
	_expire_date = roundi(Time.get_unix_time_from_system() + expire_in)
	_access_token = access_token
	_refresh_token = refresh_token
	_scopes = scopes
	type = token_type
	_persist_tokens()
	emit_changed()


## Persists the tokesn with the expire date
func _persist_tokens():
	var key: String = _get_storage_key()
	var encrypted_access_token: PackedByteArray  = _crypto_key_provider.encrypt(_access_token.to_utf8_buffer())
	var encrypted_refresh_token: PackedByteArray = _crypto_key_provider.encrypt(_refresh_token.to_utf8_buffer())
	_config_file.load(_cache_path)

	var token_name: String = "Unnamed (Missing Path/Name)"
	if resource_path != "":
		token_name = resource_path.get_file()
	elif resource_name != "":
		token_name = resource_name

	_config_file.set_value(key, "name", token_name)
	_config_file.set_value(key, "expire_date", _expire_date)
	_config_file.set_value(key, "type", type)
	_config_file.set_value(key, "access_token", Marshalls.raw_to_base64(encrypted_access_token))
	_config_file.set_value(key, "refresh_token", Marshalls.raw_to_base64(encrypted_refresh_token))
	_config_file.set_value(key, "scopes", ",".join(_scopes))
	var err: Error = _config_file.save(_cache_path)
	if err != OK:
		logError("Token %s could not be saved cause of %s" % [self, error_string(err)])
	else:
		logDebug("Token %s got persited" % self)


## Loads the tokens and returns the information if the file got created
func load_tokens() -> bool:
	var key: String = _get_storage_key()
	var status: Error = _config_file.load(_cache_path)
	if status == OK && _config_file.has_section(key):
		_expire_date = _config_file.get_value(key, "expire_date", 0)
		var encrypted_access_token: PackedByteArray = Marshalls.base64_to_raw(_config_file.get_value(key, "access_token"))
		var encrypted_refresh_token: PackedByteArray = Marshalls.base64_to_raw(_config_file.get_value(key, "refresh_token"))
		_access_token = _crypto_key_provider.decrypt(encrypted_access_token).get_string_from_utf8()
		_refresh_token = _crypto_key_provider.decrypt(encrypted_refresh_token).get_string_from_utf8()
		type = _config_file.get_value(key, "type", &"")
		_scopes = _config_file.get_value(key, "scopes", "").split(",", false)
		emit_changed()
		logDebug("Token %s got loaded" % self)
		return true
	logInfo("Token %s got not loaded error -> (%s) or was not present in '%s' yet" % [self, error_string(status), _cache_path])
	return false



func remove_tokens() -> void:
	var key: String = _get_storage_key()
	var status: Error = _config_file.load(_cache_path)
	if status == OK && _config_file.has_section(key):
		_access_token = ""
		_refresh_token = ""
		type = &""
		_expire_date = 0
		_scopes.clear()

		_config_file.erase_section(key)
		var err: Error = _config_file.save(_cache_path)
		if err != OK:
			logError("Token %s could not be erased cause of %s" % [self, error_string(err)])
		emit_changed()
		logInfo("Token %s got revoked" % self)
	else:
		logInfo("Token %s not found" % self)


func get_refresh_token() -> String:
	return _refresh_token


func get_access_token() -> String:
	#if not is_token_valid(): await authorized
	return _access_token


func get_scopes() -> PackedStringArray:
	return _scopes


## The unix timestamp when the token is expiring
func get_expiration() -> int:
	return _expire_date


func get_expiration_readable() -> String:
	if _expire_date == 0:
		return "Not available"
	return Time.get_datetime_string_from_unix_time(_expire_date, true)


func invalidate() -> void:
	logInfo("Token %s got invalidated" % self)
	_expire_date = 0
	_refresh_token = ""
	_access_token = ""
	_scopes = []
	emit_changed()


## Does this accesstoken has a refresh token
func has_refresh_token() -> bool:
	return _refresh_token != "" && _refresh_token != null


## Checks if the access token is still valid
func is_token_valid() -> bool:
	var current_time: float = Time.get_unix_time_from_system()
	return current_time < _expire_date


func _to_string() -> String:
	var token_name: String = "Unnamed (Missing Path/Name)"
	if resource_path != "":
		token_name = resource_path.get_file()
	elif resource_name != "":
		token_name = resource_name

	if (resource_path == "" and resource_name == "") and _creation_stack.size() > 1:
		var frame = _creation_stack[1]
		token_name += " [created at %s:%s]" % [frame.source.get_file(), frame.line]

	return "<%s#%s>" % [token_name, get_instance_id()]


## Get all token names within a config file
static func get_identifiers(cache_file: String) -> PackedStringArray:
	var _config_file: ConfigFile = ConfigFile.new()
	var status: Error = _config_file.load(cache_file)
	if status != OK: return []
	return _config_file.get_sections()


# === LOGGER ===
static var logger: Dictionary = {}


static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	logger.debug = debug
	logger.info = info
	logger.error = error


static func logDebug(text: String) -> void:
	if logger.has("debug"): logger.debug.call(text)


static func logInfo(text: String) -> void:
	if logger.has("info"): logger.info.call(text)


static func logError(text: String) -> void:
	if logger.has("error"): logger.error.call(text)
