@tool
extends EditorPlugin

const SERVICE_AUTOLOAD_NAME: String = "TwitchService"
const HTTP_CLIENT_AUTOLOAD_NAME: String = "HttpClientManager"

var settings: TwitchSetting;
var gif_importer: GifImporter = GifImporter.new();

func _enter_tree():
	print("Twitch Plugin loading...")
	TwitchSetting.setup();
	add_ui()

	if is_magick_available():
		add_import_plugin(gif_importer)
	add_autoload_singleton(SERVICE_AUTOLOAD_NAME, "res://addons/twitcher/twitch_service.gd");
	add_autoload_singleton(HTTP_CLIENT_AUTOLOAD_NAME, "res://addons/twitcher/communication/http_client_manager.gd");
	print("Twitch Plugin loading ended")

func _exit_tree():
	if is_magick_available():
		remove_import_plugin(gif_importer)
	remove_autoload_singleton(SERVICE_AUTOLOAD_NAME);
	remove_autoload_singleton(HTTP_CLIENT_AUTOLOAD_NAME);

func add_ui():
	var scene = preload("res://addons/twitcher/editor/twitch_utilities.tscn").instantiate() as Control;
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, scene);

func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new();
	return transformer.is_supported();
