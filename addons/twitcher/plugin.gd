@tool
extends EditorPlugin

const TWITCH_SERVICE_AUTOLOAD_NAME: String = "TwitchService"
const HTTP_CLIENT_MANAGER_AUTOLOAD_NAME: String = "HttpClientManager"
const SETTING_WINDOW = preload("res://addons/twitcher/settings/setting_window.tscn")
const REGENERATE_API_LABEL: String = "Regenerate Twitch REST Api"

const EventsubInspectorPlugin = preload("res://addons/twitcher/inspector/eventsub_inspector.gd")
const EventsubConfigInspectorPlugin = preload("res://addons/twitcher/inspector/eventsub_config_inspector.gd")
const ScopeInspectorPlugin = preload("res://addons/twitcher/inspector/scope_inspector.gd")
const RestApiInspectorPlugin = preload("res://addons/twitcher/inspector/rest_api_inspector.gd")
const AuthInspectorPlugin = preload("res://addons/twitcher/inspector/auth_inspector.gd")
const OauthSettingInspector = preload("res://addons/twitcher/lib/oOuch/oauth_setting_inspector.gd")

var settings: TwitchSetting;
var gif_importer_imagemagick: GifImporterImagemagick = GifImporterImagemagick.new();
var gif_importer_native: GifImporterNative = GifImporterNative.new();
var generator: TwitchAPIGenerator = TwitchAPIGenerator.new();
var setting_window: Control;
var eventsub_config_inspector: EventsubConfigInspectorPlugin = EventsubConfigInspectorPlugin.new()
var eventsub_inspector: EventsubInspectorPlugin = EventsubInspectorPlugin.new()
var scope_inspector: ScopeInspectorPlugin = ScopeInspectorPlugin.new()
var rest_api_inspector: RestApiInspectorPlugin = RestApiInspectorPlugin.new()
var auth_inspector: AuthInspectorPlugin = AuthInspectorPlugin.new()
var oauth_setting_inspector: OauthSettingInspector = OauthSettingInspector.new(preload("res://addons/twitcher/lib/oOuch/default_key_provider.tres"))

func _enter_tree():
	print("Twitch Plugin loading...")
	add_tool_menu_item(REGENERATE_API_LABEL, generator.generate_rest_api);
	setting_window = SETTING_WINDOW.instantiate();
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, setting_window);
	add_inspector_plugin(eventsub_config_inspector)
	add_inspector_plugin(eventsub_inspector)
	add_inspector_plugin(scope_inspector)
	add_inspector_plugin(rest_api_inspector)
	add_inspector_plugin(auth_inspector)
	add_inspector_plugin(oauth_setting_inspector)
	add_import_plugin(gif_importer_native)
	if is_magick_available():
		add_import_plugin(gif_importer_imagemagick)

	print("Twitch Plugin loading ended")

func _exit_tree():
	remove_import_plugin(gif_importer_native)
	if is_magick_available():
		remove_import_plugin(gif_importer_imagemagick)

	remove_inspector_plugin(eventsub_config_inspector)
	remove_inspector_plugin(eventsub_inspector)
	remove_inspector_plugin(scope_inspector)
	remove_inspector_plugin(rest_api_inspector)
	remove_inspector_plugin(auth_inspector)
	remove_inspector_plugin(oauth_setting_inspector)
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, setting_window);
	setting_window.queue_free();
	remove_tool_menu_item(REGENERATE_API_LABEL)

func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new();
	return transformer.is_supported();
