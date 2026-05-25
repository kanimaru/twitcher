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


## Ugly but no better way in godot right now
static func new_scene() -> bool:
	var base_control: Control = EditorInterface.get_base_control()
	var title_bar: Node = base_control.find_child("*EditorTitleBar*", true, false)
	if not title_bar:
		return false
	var scene_popups: Array[Node] = title_bar.find_children("*", "PopupMenu", true, false)
	if scene_popups.is_empty():
		return false
	var scene_menu : PopupMenu = scene_popups[0]
	var new_scene_id: int = scene_menu.get_item_id(0)
	scene_menu.id_pressed.emit(new_scene_id)
	return true
