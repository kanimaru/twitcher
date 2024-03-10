extends RefCounted

## Wrapper for the tokens. Hint never store the token value as string in
## your code to reduce the chance to dox the tokens always use the getter.
class_name TwitchTokens

var config_file: ConfigFile = ConfigFile.new();
var access_token: String = "";
var refresh_token: String = "";
var expire_date: int;

func _init() -> void:
	_load_tokens();

func _update_values(access_tok: String, refresh_tok: String, expire_in: int):
	expire_date = roundi(Time.get_unix_time_from_system() + expire_in);
	access_token = access_tok
	refresh_token = refresh_tok

## Persists the tokesn with the expire date
func _persist_tokens():
	config_file.set_value("auth", "expire_date", expire_date);
	config_file.set_value("auth", "access_token", access_token);
	config_file.set_value("auth", "refresh_token", refresh_token);
	config_file.save_encrypted_pass(TwitchSetting.auth_cache, TwitchSetting.client_secret);

## Loads the tokens and returns the information if the file got created
func _load_tokens():
	var status = config_file.load_encrypted_pass(TwitchSetting.auth_cache, TwitchSetting.client_secret)
	if status == OK:
		expire_date = config_file.get_value("auth", "expire_date", 0);
		access_token = config_file.get_value("auth", "access_token");
		refresh_token = config_file.get_value("auth", "refresh_token");
		return true;
	return false;

func get_token() -> String:
	return access_token;

func has_refresh_token() -> bool:
	return refresh_token != "";

func is_token_valid() -> bool:
	return Time.get_unix_time_from_system() < expire_date;
