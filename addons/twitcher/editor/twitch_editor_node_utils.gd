@tool
extends Object

# It prevent manual tempering with editor settings while the inspector is shown 
# and ensure that always the latest auth token and oauth settings will be loaded

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")


static func create_api(token: OAuthToken, setting: OAuthSetting) -> TwitchAPI:
	var api: TwitchAPI = TwitchAPI.new()
	api.token = token if token else TwitchEditorSettings.editor_oauth_token
	api.oauth_setting = setting if setting else TwitchEditorSettings.editor_oauth_setting
	return api
	
	
static func create_media_loader(api: TwitchAPI) -> TwitchMediaLoader:
	var media_loader: TwitchMediaLoader = TwitchMediaLoader.new()
	media_loader.api = api
	return media_loader
