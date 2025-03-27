extends RefCounted

## Utilitiy Node for Inspector to calling API functionallity at any point

const DEFAULT_OAUTH_TOKEN: String = "res://addons/twitcher/default_oauth_token.tres"
const TWITCH_OAUTH_SETTING: String = "res://addons/twitcher/twitch_oauth_setting.tres"

static var _editor_token_property: ProjectSettingProperty
static var editor_token: OAuthToken:
	get(): return load(_editor_token_property.get_val())


static var _editor_oauth_setting_property: ProjectSettingProperty
static var oauth_setting: OAuthSetting:
	get(): return load(_editor_oauth_setting_property.get_val())
	

func _init() -> void:
	_setup_project_settings()
	

static func _setup_project_settings() -> void:
	_editor_token_property = ProjectSettingProperty.new("twitcher/editor/editor_token", DEFAULT_OAUTH_TOKEN)
	_editor_token_property.as_file("*.res,*.tres")
	
	_editor_oauth_setting_property = ProjectSettingProperty.new("twitcher/editor/oauth_setting", TWITCH_OAUTH_SETTING)
	_editor_oauth_setting_property.as_file("*.res,*.tres")
	
