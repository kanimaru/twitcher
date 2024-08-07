@tool
extends EditorPlugin

const TWITCH_SERVICE_AUTOLOAD_NAME: String = "TwitchService"
const HTTP_CLIENT_MANAGER_AUTOLOAD_NAME: String = "HttpClientManager"
const SETTING_WINDOW = preload("res://addons/twitcher/editor/setting_window.tscn")
const REGENERATE_API_LABEL: String = "Regenerate Twitch REST Api"

var settings: TwitchSetting;
var gif_importer_imagemagick: GifImporterImagemagick = GifImporterImagemagick.new();
var gif_importer_native: GifImporterNative = GifImporterNative.new();
var generator: TwitchAPIGenerator = TwitchAPIGenerator.new();
var setting_window: Control;

func _enter_tree():
	print("Twitch Plugin loading...")
	TwitchSetting.setup();
	add_tool_menu_item(REGENERATE_API_LABEL, generator.generate_rest_api);
	setting_window = SETTING_WINDOW.instantiate();
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, setting_window);

	add_import_plugin(gif_importer_native)
	if is_magick_available():
		add_import_plugin(gif_importer_imagemagick)

	#add_autoload_singleton(TWITCH_SERVICE_AUTOLOAD_NAME, "res://addons/twitcher/twitch_service.gd");
	add_autoload_singleton(HTTP_CLIENT_MANAGER_AUTOLOAD_NAME, "res://addons/twitcher/communication/http_client_manager.gd");
	print("Twitch Plugin loading ended")

func _exit_tree():
	remove_import_plugin(gif_importer_native)
	if is_magick_available():
		remove_import_plugin(gif_importer_imagemagick)
	#remove_autoload_singleton(TWITCH_SERVICE_AUTOLOAD_NAME);
	remove_autoload_singleton(HTTP_CLIENT_MANAGER_AUTOLOAD_NAME);
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, setting_window);
	setting_window.queue_free();
	remove_tool_menu_item(REGENERATE_API_LABEL)

func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new();
	return transformer.is_supported();
