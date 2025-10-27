@tool
extends RefCounted

## Utilitiy Node for Inspector to calling API functionallity at any point

const EDITOR_OAUTH_TOKEN: String = "user://editor_oauth_token.tres"
const EDITOR_OAUTH_SETTING: String = "user://editor_oauth_setting.tres"
const GAME_OAUTH_TOKEN: String = "res://twitch_oauth_token.tres"
const GAME_OAUTH_SETTING: String = "res://twitch_oauth_setting.tres"
const TWITCH_DEFAULT_SCOPE: String = "res://addons/twitcher/auth/preset_overlay_scopes.tres"

const PRESET_GAME: StringName = &"Game"
const PRESET_OVERLAY: StringName = &"Overlay"
const PRESET_OTHER: StringName = &"Other"

static var _log : TwitchLogger = TwitchLogger.new("TwitchEditorSetting")

static var _editor_oauth_token_property: ProjectSettingProperty
static var editor_oauth_token: OAuthToken:
	set(val): 
		editor_oauth_token = val
		if not _reloading: _editor_oauth_token_property.set_val(val.resource_path)
		
static var _editor_oauth_setting_property: ProjectSettingProperty
static var editor_oauth_setting: OAuthSetting:
	set(val): 
		editor_oauth_setting = val
		if not _reloading: _editor_oauth_setting_property.set_val(val.resource_path)
	
static var _game_oauth_token_property: ProjectSettingProperty
static var game_oauth_token: OAuthToken:
	set(val): 
		game_oauth_token = val
		if not _reloading: _game_oauth_token_property.set_val(val.resource_path)
		
static var _game_oauth_setting_property: ProjectSettingProperty
static var game_oauth_setting: OAuthSetting:
	set(val): 
		game_oauth_setting = val
		if not _reloading: _game_oauth_setting_property.set_val(val.resource_path)

static var _scope_property: ProjectSettingProperty
static var scopes: TwitchOAuthScopes:
	set(val): 
		scopes = val
		if not _reloading: _scope_property.set_val(val.resource_path)

static var _show_setup_on_startup: ProjectSettingProperty
static var show_setup_on_startup: bool:
	set(val): _show_setup_on_startup.set_val(val)
	get: return _show_setup_on_startup.get_val()
	
static var _project_preset: ProjectSettingProperty
static var project_preset: StringName:
	set(val): _project_preset.set_val(val)
	get: return _project_preset.get_val()

static var _load_current_twitch_user: ProjectSettingProperty
static var load_current_twitch_user: bool:
	set(val): _load_current_twitch_user.set_val(val)
	get: return _load_current_twitch_user.get_val()

static var _reward_folder: ProjectSettingProperty
static var reward_folder: String:
	set(val): _reward_folder.set_val(val)
	get: return _reward_folder.get_val()
	
static var _initialized: bool
static var _reloading: bool


static func setup() -> void:
	if not _initialized:
		_initialized = true
		_setup_project_settings()
		_reload_setting()
		ProjectSettings.settings_changed.connect(_reload_setting)
	

static func _setup_project_settings() -> void:
	_editor_oauth_token_property = ProjectSettingProperty.new("twitcher/editor/editor_oauth_token", EDITOR_OAUTH_TOKEN)
	_editor_oauth_token_property.as_file("*.res,*.tres")
	
	_editor_oauth_setting_property = ProjectSettingProperty.new("twitcher/editor/editor_oauth_setting", EDITOR_OAUTH_SETTING)
	_editor_oauth_setting_property.as_file("*.res,*.tres")
	
	_game_oauth_token_property = ProjectSettingProperty.new("twitcher/editor/game_oauth_token", GAME_OAUTH_TOKEN)
	_game_oauth_token_property.as_file("*.res,*.tres")
	
	_game_oauth_setting_property = ProjectSettingProperty.new("twitcher/editor/game_oauth_setting", GAME_OAUTH_SETTING)
	_game_oauth_setting_property.as_file("*.res,*.tres")
	
	_scope_property = ProjectSettingProperty.new("twitcher/editor/default_scopes", TWITCH_DEFAULT_SCOPE)
	_scope_property.as_file("*.res,*.tres")
	
	_show_setup_on_startup = ProjectSettingProperty.new("twitcher/editor/show_setup_on_startup", true)
	
	_project_preset = ProjectSettingProperty.new("twitcher/editor/project_preset")
	_project_preset.as_select([PRESET_GAME, PRESET_OVERLAY, PRESET_OTHER], false)
	
	_load_current_twitch_user = ProjectSettingProperty.new("twitcher/editor/load_current_twitch_user", true)
	_load_current_twitch_user.as_bool("Should always load the current user when converting to TwitchUser")
	
	_reward_folder = ProjectSettingProperty.new("twitcher/editor/reward_folder", "res://")
	_reward_folder.as_dir()


static func _reload_setting() -> void:
	_reloading = true
	editor_oauth_setting = load(_editor_oauth_setting_property.get_val())
	editor_oauth_token = load(_editor_oauth_token_property.get_val())
	game_oauth_setting = load(_game_oauth_setting_property.get_val())
	game_oauth_token = load(_game_oauth_token_property.get_val())
	
	var editor_oauth_token_path: String = _editor_oauth_token_property.get_val()
	if editor_oauth_token_path:
		if not FileAccess.file_exists(editor_oauth_token_path):
			_create_editor_oauth_token()
		
	var editor_oauth_setting_path: String = _editor_oauth_setting_property.get_val()
	if editor_oauth_setting_path:
		if not FileAccess.file_exists(editor_oauth_setting_path):
			_create_editor_oauth_setting()
		
	var scope_path: String = get_scope_path()
	if scope_path and FileAccess.file_exists(scope_path):
		scopes = load(scope_path)
	_reloading = false
		
	
static func save_editor_oauth_setting() -> void:
	_log.d("Saves editor oauth setting")
	ResourceSaver.save(editor_oauth_setting)

	
static func save_editor_oauth_token() -> void:
	_log.d("Saves editor oauth token")
	ResourceSaver.save(editor_oauth_token)

	
static func get_scope_path() -> String:
	return _scope_property.get_val()
	
	
static func set_scope_path(path: String) -> void:
	_scope_property.set_val(path)
	
	
static func is_valid() -> bool:
	var token_valid: bool = is_instance_valid(editor_oauth_token) && editor_oauth_token.is_token_valid()
	var setting_valid : bool = is_instance_valid(editor_oauth_setting) && editor_oauth_setting.is_valid()
	return token_valid && setting_valid


static func _create_editor_oauth_token() -> void:
	_log.i("Create new Editor Token resource")
	var path: String = _editor_oauth_token_property.get_val()
	var token = OAuthToken.new()
	token._identifier = "EditorToken"
	token.take_over_path(path)
	editor_oauth_token = token
	save_editor_oauth_token()
	
	
static func _create_editor_oauth_setting() -> void:
	_log.i("Create new Editor Oauth settings")
	var path: String = _editor_oauth_setting_property.get_val()
	var setting: OAuthSetting = TwitchAuth.create_default_oauth_setting()
	setting.take_over_path(path)
	editor_oauth_setting = setting
	save_editor_oauth_setting()
