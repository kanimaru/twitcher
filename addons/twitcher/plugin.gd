@tool
extends EditorPlugin

static var _log : TwitchLogger = TwitchLogger.new("Twitcher Plugin")

const HttpUtil = preload("res://addons/twitcher/lib/http/http_util.gd")
const REGENERATE_API_LABEL: String = "Regenerate Twitch Api"

const EventsubInspectorPlugin = preload("res://addons/twitcher/editor/inspector/eventsub_inspector.gd")
const EventsubConfigInspectorPlugin = preload("res://addons/twitcher/editor/inspector/eventsub_config_inspector.gd")
const ScopeInspectorPlugin = preload("res://addons/twitcher/editor/inspector/scope_inspector.gd")
const TwitchServiceInspectorPlugin = preload("res://addons/twitcher/editor/inspector/twitch_service_inspector.gd")
const OauthSettingInspector = preload("res://addons/twitcher/lib/oOuch/oauth_setting_inspector.gd")
const TokenInspector = preload("res://addons/twitcher/lib/oOuch/oauth_token_inspector.gd")
const TwitchApiInspector = preload("res://addons/twitcher/editor/inspector/twitch_api_inspector.gd")
const TwitchChatInspector = preload("res://addons/twitcher/editor/inspector/twitch_chat_inspector.gd")
const TwitchMediaLoaderInspector = preload("res://addons/twitcher/editor/inspector/twitch_media_loader_inspector.gd")

var gif_importer_imagemagick: GifImporterImagemagick = GifImporterImagemagick.new()
var gif_importer_native: GifImporterNative = GifImporterNative.new()
var generator: TwitchAPIGenerator 
var eventsub_config_inspector: EventsubConfigInspectorPlugin = EventsubConfigInspectorPlugin.new()
var eventsub_inspector: EventsubInspectorPlugin = EventsubInspectorPlugin.new()
var scope_inspector: ScopeInspectorPlugin = ScopeInspectorPlugin.new()
var twitch_service_inspector: TwitchServiceInspectorPlugin = TwitchServiceInspectorPlugin.new()
var oauth_setting_inspector: OauthSettingInspector = OauthSettingInspector.new()
var token_inspector: TokenInspector = TokenInspector.new()
var chat_inspector: TwitchChatInspector = TwitchChatInspector.new()
var api_inspector: TwitchApiInspector = TwitchApiInspector.new()
var media_loader_inspector: TwitchMediaLoaderInspector = TwitchMediaLoaderInspector.new()


static func _static_init() -> void:
	var http_logger = TwitchLogger.new("Http")
	HttpUtil.set_logger(http_logger.e, http_logger.i, http_logger.d)


func _enter_tree():
	_log.i("Start Twitcher loading...")

	if Engine.is_editor_hint():
		generator = TwitchAPIGenerator.new()
		add_child(generator)
		add_tool_menu_item(REGENERATE_API_LABEL, generator.generate_api)
		
	add_inspector_plugin(eventsub_config_inspector)
	add_inspector_plugin(eventsub_inspector)
	add_inspector_plugin(scope_inspector)
	add_inspector_plugin(twitch_service_inspector)
	add_inspector_plugin(oauth_setting_inspector)
	add_inspector_plugin(token_inspector)
	add_inspector_plugin(chat_inspector)
	add_inspector_plugin(api_inspector)
	add_inspector_plugin(media_loader_inspector)
	add_import_plugin(gif_importer_native)
	if is_magick_available():
		add_import_plugin(gif_importer_imagemagick)
	_log.i("Twitcher loading ended")


func _exit_tree():
	remove_import_plugin(gif_importer_native)
	if is_magick_available():
		remove_import_plugin(gif_importer_imagemagick)

	remove_inspector_plugin(eventsub_config_inspector)
	remove_inspector_plugin(eventsub_inspector)
	remove_inspector_plugin(scope_inspector)
	remove_inspector_plugin(twitch_service_inspector)
	remove_inspector_plugin(oauth_setting_inspector)
	remove_inspector_plugin(token_inspector)
	remove_inspector_plugin(chat_inspector)
	remove_inspector_plugin(api_inspector)
	remove_inspector_plugin(media_loader_inspector)
	if Engine.is_editor_hint():
		remove_tool_menu_item(REGENERATE_API_LABEL)
		
	_log.i("Twitcher Unloaded")


func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new()
	return transformer.is_supported()
