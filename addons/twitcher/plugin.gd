@tool
extends EditorPlugin

static var _log : TwitchLogger = TwitchLogger.new("Twitcher Plugin")

const REGENERATE_API_LABEL: String = "Regenerate Twitch Api"

# oOuch imports
const OauthSettingInspector = preload("res://addons/twitcher/lib/oOuch/oauth_setting_inspector.gd")
const TokenInspector = preload("res://addons/twitcher/lib/oOuch/oauth_token_inspector.gd")

# Twitcher imports
const ScopeInspectorPlugin = preload("res://addons/twitcher/editor/inspector/scope_inspector.gd")
const TwitchEventsubInspectorPlugin = preload("res://addons/twitcher/editor/inspector/twitch_eventsub_inspector.gd")
const TwitchEventsubConfigInspectorPlugin = preload("res://addons/twitcher/editor/inspector/twitch_eventsub_config_inspector.gd")
const TwitchMediaLoaderInspector = preload("res://addons/twitcher/editor/inspector/twitch_media_loader_inspector.gd")
const TwitchAuthInspector = preload("res://addons/twitcher/editor/inspector/twitch_auth_inspector.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchUserInspector = preload("res://addons/twitcher/editor/inspector/twitch_user_inspector.gd")

var generator: TwitchAPIGenerator 
var parser: TwitchAPIParser 

var gif_importer_imagemagick: GifImporterImagemagick = GifImporterImagemagick.new()
var gif_importer_native: GifImporterNative = GifImporterNative.new()
var eventsub_config_inspector: TwitchEventsubConfigInspectorPlugin = TwitchEventsubConfigInspectorPlugin.new()
var eventsub_inspector: TwitchEventsubInspectorPlugin = TwitchEventsubInspectorPlugin.new()
var scope_inspector: ScopeInspectorPlugin = ScopeInspectorPlugin.new()
var oauth_setting_inspector: OauthSettingInspector = OauthSettingInspector.new()
var token_inspector: TokenInspector = TokenInspector.new()
var media_loader_inspector: TwitchMediaLoaderInspector = TwitchMediaLoaderInspector.new()
var auth_inspector: TwitchAuthInspector = TwitchAuthInspector.new()
var user_inspector: TwitchUserInspector = TwitchUserInspector.new()
var settings: TwitchEditorSettings = TwitchEditorSettings.new()

func _enter_tree():
	_log.i("Start Twitcher loading...")

	TwitchEditorSettings.setup()
	add_tool_menu_item(REGENERATE_API_LABEL, func():
		generator = TwitchAPIGenerator.new()
		parser = TwitchAPIParser.new()
		generator.parser = parser
		add_child(generator)
		add_child(parser)
		await parser.parse_api()
		generator.generate_api()
		remove_child(generator)
		remove_child(parser)
		)
			
	add_inspector_plugin(eventsub_config_inspector)
	add_inspector_plugin(eventsub_inspector)
	add_inspector_plugin(scope_inspector)
	add_inspector_plugin(oauth_setting_inspector)
	add_inspector_plugin(token_inspector)
	add_inspector_plugin(media_loader_inspector)
	add_inspector_plugin(auth_inspector)
	add_inspector_plugin(user_inspector)
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
	remove_inspector_plugin(oauth_setting_inspector)
	remove_inspector_plugin(token_inspector)
	remove_inspector_plugin(media_loader_inspector)
	remove_inspector_plugin(auth_inspector)
	remove_inspector_plugin(user_inspector)
	if Engine.is_editor_hint():
		remove_tool_menu_item(REGENERATE_API_LABEL)
		
	_log.i("Twitcher Unloaded")


func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new()
	return transformer.is_supported()
