@tool
extends EditorPlugin

const SERVICE_AUTOLOAD_NAME: String = "TwitchService"
const HTTP_CLIENT_AUTOLOAD_NAME: String = "HttpClientManager"

var settings: TwitchSetting;

func _enter_tree():
	print("Twitch Service Plugin loading...")
	TwitchSetting.setup();
	add_ui()

	var importer = preload("./image_transformer/imagemagic/importer.gd")
	add_import_plugin(importer)
	add_autoload_singleton(SERVICE_AUTOLOAD_NAME, "res://addons/twitcher/twitch_service.gd");
	add_autoload_singleton(HTTP_CLIENT_AUTOLOAD_NAME, "res://addons/twitcher/communication/http_client_manager.gd");
	print("Twitch Service Plugin loading ended")

func _exit_tree():
	var importer = preload("./image_transformer/imagemagic/importer.gd")
	remove_import_plugin(importer)
	remove_autoload_singleton(SERVICE_AUTOLOAD_NAME);
	remove_autoload_singleton(HTTP_CLIENT_AUTOLOAD_NAME);

func add_ui():
	var scene = preload("res://addons/twitcher/editor/twitch_utilities.tscn").instantiate() as Control;
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, scene);
