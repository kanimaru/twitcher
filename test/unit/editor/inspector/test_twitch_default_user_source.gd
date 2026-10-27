extends TwitcherTest
## Unit tests for [TwitchDefaultUserSource].

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

const _AUTO_FILL_KEY: String = "twitcher/editor/load_current_twitch_user"

var _source: TwitchDefaultUserSource
var _previous_user: TwitchUser
var _had_auto_fill_setting: bool


func before_each() -> void:
	super()
	_source = TwitchDefaultUserSource.new()
	_previous_user = TwitchEditorSettings.default_user
	_had_auto_fill_setting = ProjectSettings.has_setting(_AUTO_FILL_KEY)
	# Normally created by the editor plugin's TwitchEditorSettings.setup().
	TwitchEditorSettings._load_current_twitch_user = ProjectSettingProperty.new(
			_AUTO_FILL_KEY, true)


func after_each() -> void:
	_set_default_user(_previous_user)
	if not _had_auto_fill_setting:
		ProjectSettings.set_setting(_AUTO_FILL_KEY, null)
	super()


func test_get_user_returns_the_configured_default_user() -> void:
	var user: TwitchUser = TwitchUser.new()
	user.id = "100"
	_set_default_user(user)

	assert_same(_source.get_user(), user)


func test_get_user_is_null_without_a_default_user() -> void:
	_set_default_user(null)

	assert_null(_source.get_user())


func test_auto_fill_follows_the_load_current_twitch_user_setting() -> void:
	ProjectSettings.set_setting(_AUTO_FILL_KEY, true)
	assert_true(_source.is_auto_fill_enabled())

	ProjectSettings.set_setting(_AUTO_FILL_KEY, false)
	assert_false(_source.is_auto_fill_enabled())


## The setter also writes the resource path into the project settings, which needs the editor
## plugin's setup. Setting it the way a settings reload does skips that.
func _set_default_user(user: TwitchUser) -> void:
	var was_reloading: bool = TwitchEditorSettings._reloading
	TwitchEditorSettings._reloading = true
	TwitchEditorSettings.default_user = user
	TwitchEditorSettings._reloading = was_reloading
