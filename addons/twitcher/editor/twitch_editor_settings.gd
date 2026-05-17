@tool
extends RefCounted

## Utilitiy Node for Inspector to calling API functionallity at any point

const EDITOR_OAUTH_TOKEN: String = "res://addons/twitcher/editor_oauth_token.tres"
const EDITOR_OAUTH_SETTING: String = "res://addons/twitcher/editor_oauth_setting.tres"
const GAME_OAUTH_TOKEN: String = "res://twitch_oauth_token.tres"
const GAME_OAUTH_SETTING: String = "res://twitch_oauth_setting.tres"
const TWITCH_DEFAULT_SCOPE: String = "res://addons/twitcher/auth/preset_overlay_scopes.tres"
const TWITCH_DEFAULT_USER: String = "res://twitch_default_user.tres"

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

static var _default_user_property: ProjectSettingProperty
static var default_user: TwitchUser:
	set(val):
		default_user = val
		if not _reloading:
			var err = ResourceSaver.save(default_user)
			if not err: _default_user_property.set_val(val.resource_path)

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

static var _resource_folder: ProjectSettingProperty
static var resource_folder: String:
	set(val): _resource_folder.set_val(val)
	get: return _resource_folder.get_val()


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

	_default_user_property = ProjectSettingProperty.new("twitcher/editor/default_twitch_user", TWITCH_DEFAULT_USER)
	_default_user_property.as_file("*.res,*.tres")

	_show_setup_on_startup = ProjectSettingProperty.new("twitcher/editor/show_setup_on_startup", true)

	_project_preset = ProjectSettingProperty.new("twitcher/editor/project_preset")
	_project_preset.as_select([PRESET_GAME, PRESET_OVERLAY, PRESET_OTHER], false)

	_load_current_twitch_user = ProjectSettingProperty.new("twitcher/editor/load_current_twitch_user", true)
	_load_current_twitch_user.as_bool("Should always load the current user when converting to TwitchUser")

	_reward_folder = ProjectSettingProperty.new("twitcher/editor/reward_folder", "res://")
	_reward_folder.as_dir()

	_resource_folder = ProjectSettingProperty.new("twitcher/editor/resource_folder", "res://")
	_resource_folder.as_dir()


static func _reload_setting() -> void:
	_reloading = true
	var editor_oauth_token_path: String = _editor_oauth_token_property.get_val()
	if editor_oauth_token_path:
		if not FileAccess.file_exists(editor_oauth_token_path):
			_create_editor_oauth_token()
		else:
			editor_oauth_token = load(editor_oauth_token_path)

	var editor_oauth_setting_path: String = _editor_oauth_setting_property.get_val()
	if editor_oauth_setting_path:
		if not FileAccess.file_exists(editor_oauth_setting_path):
			_create_editor_oauth_setting()
		else:
			editor_oauth_setting = load(editor_oauth_setting_path)

	var default_user_path: String = _default_user_property.get_val()
	if default_user_path:
		if FileAccess.file_exists(default_user_path):
			default_user = load(default_user_path)

	_reloading = false


static func save_editor_oauth_setting() -> void:
	_log.d("Saves editor oauth setting")
	ResourceSaver.save(editor_oauth_setting)


static func save_editor_oauth_token() -> void:
	_log.d("Saves editor oauth token")
	ResourceSaver.save(editor_oauth_token)


static func save_default_user() -> void:
	_log.d("Saves default user")
	ResourceSaver.save(default_user)


static func get_scope_path() -> String:
	return _scope_property.get_val()


static func set_scope_path(path: String) -> void:
	_scope_property.set_val(path)


static func get_default_user_path() -> String:
	return _default_user_property.get_val()


static func set_default_user_path(path: String) -> void:
	_default_user_property.set_val(path)


static func get_game_auth_setting_path() -> String:
	return _game_oauth_setting_property.get_val()


static func set_game_auth_setting_path(path: String) -> void:
	_game_oauth_setting_property.set_val(path)


static func get_editor_auth_setting_path() -> String:
	return _editor_oauth_setting_property.get_val()


static func set_editor_auth_setting_path(path: String) -> void:
	_editor_oauth_setting_property.set_val(path)


static func is_valid() -> bool:
	var token_valid: bool = is_instance_valid(editor_oauth_token) and editor_oauth_token.is_token_valid()
	var setting_valid : bool = is_instance_valid(editor_oauth_setting) and editor_oauth_setting.is_valid()
	return token_valid and setting_valid


static func _create_editor_oauth_token() -> void:
	_log.i("Create new Editor Token resource")
	var path: String = _editor_oauth_token_property.get_val()
	var token = OAuthToken.new()
	token.resource_name = "EditorToken"
	token.take_over_path(path)
	editor_oauth_token = token
	save_editor_oauth_token()


static func _create_editor_oauth_setting() -> void:
	_log.i("Create new Editor Oauth settings")
	var path: String = _editor_oauth_setting_property.get_val()
	var setting: OAuthSetting = TwitchAuth.create_default_oauth_setting()
	setting.authorization_flow = OAuth.AuthorizationFlow.CLIENT_CREDENTIALS
	setting.take_over_path(path)
	editor_oauth_setting = setting
	save_editor_oauth_setting()
