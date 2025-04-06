@tool
extends RefCounted

## Utilitiy Node for Inspector to calling API functionallity at any point

const DEFAULT_OAUTH_TOKEN: String = "res://addons/twitcher/default_oauth_token.tres"
const TWITCH_OAUTH_SETTING: String = "res://addons/twitcher/twitch_oauth_setting.tres"

static var _editor_token_property: ProjectSettingProperty
static var editor_token: OAuthToken

static var _editor_oauth_setting_property: ProjectSettingProperty
static var oauth_setting: OAuthSetting

static var _scope_property: ProjectSettingProperty
static var scopes: TwitchOAuthScopes

static var _initialized: bool


static func setup() -> void:
	if not _initialized:
		_initialized = true
		_setup_project_settings()
		ProjectSettings.settings_changed.connect(_reload_setting)
		_reload_setting()
	

static func _setup_project_settings() -> void:
	_editor_token_property = ProjectSettingProperty.new("twitcher/editor/editor_token", DEFAULT_OAUTH_TOKEN)
	_editor_token_property.as_file("*.res,*.tres")
	
	_editor_oauth_setting_property = ProjectSettingProperty.new("twitcher/editor/oauth_setting", TWITCH_OAUTH_SETTING)
	_editor_oauth_setting_property.as_file("*.res,*.tres")
	
	_scope_property = ProjectSettingProperty.new("twitcher/editor/default_scopes", "res://addons/twitcher/auth/preset_overlay_scopes.tres")
	_scope_property.as_file("*.res,*.tres")
	

static func _reload_setting() -> void:
	var editor_token_path: String = get_editor_token_path()
	if editor_token_path:
		editor_token = load(editor_token_path)
		
	var oauth_setting_path: String = get_oauth_setting_path()
	if oauth_setting_path:
		oauth_setting = load(oauth_setting_path)
		
	var scope_path: String = get_scope_path()
	if scope_path:
		scopes = load(scope_path)


static func set_oauth_setting_path(path: String) -> void:
	_editor_oauth_setting_property.set_val(path)


static func get_oauth_setting_path() -> String:
	return _editor_oauth_setting_property.get_val()
	

static func set_editor_token(path: String) -> void:
	_editor_token_property.set_val(path)


static func get_editor_token_path() -> String:
	return _editor_token_property.get_val()
	
	
static func get_scope_path() -> String:
	return _scope_property.get_val()
	
	
static func set_scope_path(path: String) -> void:
	_scope_property.set_val(path)
	
	
static func is_valid() -> bool:
	var token_valid = is_instance_valid(editor_token) && editor_token.is_token_valid()
	var auth_setting_valid = is_instance_valid(oauth_setting) && oauth_setting.is_valid()
	return token_valid && auth_setting_valid
	
