@tool
extends EditorPlugin

static var _log : TwitchLogger = TwitchLogger.new("Twitcher Plugin")

# Tooltip Menu
const TOOLMENU_CATEGORY: String = "Twitcher"
const REGENERATE_API_LABEL: String = "Regenerate Twitch Api & Eventsub"
const OPEN_SETUP_LABEL: String = "Setup"
const REWARD_MANAGER_LABEL: String = "Reward Manager"

enum TwitcherTooltipIds {
	SETUP, REWARD_MANAGER, REGENERATE_API
}

# oOuch imports
const OauthSettingInspector = preload("res://addons/twitcher/lib/oOuch/oauth_setting_inspector.gd")
const TokenInspector = preload("res://addons/twitcher/lib/oOuch/oauth_token_inspector.gd")

# Twitcher imports
const TwitchScopeInspectorPlugin = preload("res://addons/twitcher/editor/inspector/twitch_scope_inspector.gd")
const TwitchEventsubInspectorPlugin = preload("res://addons/twitcher/editor/inspector/twitch_eventsub_inspector.gd")
const TwitchEventsubConfigInspectorPlugin = preload("res://addons/twitcher/editor/inspector/twitch_eventsub_config_inspector.gd")
const TwitchMediaLoaderInspector = preload("res://addons/twitcher/editor/inspector/twitch_media_loader_inspector.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchUserInspector = preload("res://addons/twitcher/editor/inspector/twitch_user_inspector.gd")
const TwitchRewardInspector = preload("res://addons/twitcher/editor/inspector/twitch_reward_inspector.gd")
const EncryptionInspector = preload("uid://dlcq0bqmlypko")
const TwitchBotInspector = preload("uid://d2m042af2shx8")

const TWITCHER_EDITOR_SCOPES = preload("uid://cgqldyna2cv5h")

var generator_eventsub: TwitchEventsubGenerator
var generator_api: TwitchAPIGenerator
var parser_eventsub: TwitchAPIParser
var parser_api: TwitchAPIParser

var gif_importer_imagemagick: GifImporterImagemagick = GifImporterImagemagick.new()
var gif_importer_native: GifImporterNative = GifImporterNative.new()
var eventsub_config_inspector: TwitchEventsubConfigInspectorPlugin = TwitchEventsubConfigInspectorPlugin.new()
var eventsub_inspector: TwitchEventsubInspectorPlugin = TwitchEventsubInspectorPlugin.new()
var scope_inspector: TwitchScopeInspectorPlugin = TwitchScopeInspectorPlugin.new()
var oauth_setting_inspector: OauthSettingInspector = OauthSettingInspector.new()
var token_inspector: TokenInspector = TokenInspector.new()
var media_loader_inspector: TwitchMediaLoaderInspector = TwitchMediaLoaderInspector.new()
var user_inspector: TwitchUserInspector = TwitchUserInspector.new()
var reward_inspector: TwitchRewardInspector = TwitchRewardInspector.new()
var encryption_inspector: EncryptionInspector = EncryptionInspector.new()
var settings: TwitchEditorSettings = TwitchEditorSettings.new()
var bot_inspector: TwitchBotInspector = TwitchBotInspector.new()

var current_setup_window: Node
var current_reward_manager_window: Node
var popup_menu: PopupMenu

func _enter_tree():
	_log.i("Start Twitcher loading...")
	TwitchEditorSettings.setup()

	token_inspector.token_info_scene = preload("res://addons/twitcher/editor/inspector/twitch_token_info.tscn")

	add_twitcher_menu()

	add_inspector_plugin(eventsub_config_inspector)
	add_inspector_plugin(eventsub_inspector)
	add_inspector_plugin(scope_inspector)
	add_inspector_plugin(oauth_setting_inspector)
	add_inspector_plugin(token_inspector)
	add_inspector_plugin(media_loader_inspector)
	add_inspector_plugin(user_inspector)
	add_inspector_plugin(reward_inspector)
	add_inspector_plugin(encryption_inspector)
	add_inspector_plugin(bot_inspector)
	add_import_plugin(gif_importer_native)
	if is_magick_available():
		add_import_plugin(gif_importer_imagemagick)

	if TwitchEditorSettings.show_setup_on_startup: open_setup()
	await try_authorize_editor()

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
	remove_inspector_plugin(user_inspector)
	remove_inspector_plugin(reward_inspector)
	remove_inspector_plugin(encryption_inspector)
	remove_inspector_plugin(bot_inspector)
	if Engine.is_editor_hint():
		remove_tool_menu_item(TOOLMENU_CATEGORY)

	_log.i("Twitcher Unloaded")



func add_twitcher_menu() -> void:
	var popup_menu = PopupMenu.new()
	popup_menu.add_item(OPEN_SETUP_LABEL, TwitcherTooltipIds.SETUP)
	popup_menu.add_item(REWARD_MANAGER_LABEL, TwitcherTooltipIds.REWARD_MANAGER)
	popup_menu.add_item(REGENERATE_API_LABEL, TwitcherTooltipIds.REGENERATE_API)
	popup_menu.id_pressed.connect(func(id):
		match id:
			TwitcherTooltipIds.SETUP: open_setup()
			TwitcherTooltipIds.REWARD_MANAGER: open_reward_manager()
			TwitcherTooltipIds.REGENERATE_API: generate_api()
	)
	add_tool_submenu_item(TOOLMENU_CATEGORY, popup_menu)


func open_setup() -> void:
	if is_instance_valid(current_setup_window): return
	current_setup_window = load("uid://wu1fprbhr62").instantiate() # setup.tscn
	add_child(current_setup_window)


func open_reward_manager() -> void:
	if is_instance_valid(current_reward_manager_window): return
	current_reward_manager_window = load("uid://deqnbbm1uxpbb").instantiate() # twitch_reward_manager.tscn
	add_child(current_reward_manager_window)


func generate_api() -> void:
	generator_eventsub = TwitchEventsubGenerator.new()
	generator_api = TwitchAPIGenerator.new()
	parser_eventsub = TwitchAPIParser.new()
	parser_eventsub.api = "https://raw.githubusercontent.com/kanimaru/twitch-eventsub-swagger/refs/heads/master/twitch_eventsub_swagger.json"
	parser_api = TwitchAPIParser.new()
	parser_api.api = "https://raw.githubusercontent.com/DmitryScaletta/twitch-api-swagger/refs/heads/main/openapi.json"

	generator_eventsub.parser = parser_eventsub
	generator_api.parser = parser_api
	add_child(generator_eventsub)
	add_child(generator_api)
	add_child(parser_eventsub)
	add_child(parser_api)
	await parser_eventsub.parse_api()
	await parser_api.parse_api()
	generator_api.generate_api()
	generator_eventsub.generate_api()
	remove_child(generator_api)
	remove_child(parser_api)
	remove_child(parser_eventsub)
	EditorInterface.get_resource_filesystem().scan()


func is_magick_available() -> bool:
	var transformer: MagicImageTransformer = MagicImageTransformer.new()
	return transformer.is_supported()


func try_authorize_editor() -> void:
	var oauth_setting: OAuthSetting = TwitchEditorSettings.editor_oauth_setting
	var oauth_token: OAuthToken = TwitchEditorSettings.editor_oauth_token
	if not oauth_setting.is_valid():
		_log.d("Can't validate editor token cause OAuthSettings are invalid.")
		return
	if oauth_token.is_token_valid():
		_log.d("%s still valid, no reauthorization." % oauth_token)
		return

	await TwitchAuth.manual_authorize(
		oauth_setting,
		oauth_token,
		false,
		TWITCHER_EDITOR_SCOPES
	)
	if oauth_token.is_token_valid():
		_log.i("Editor token got authorized")
	else:
		_log.e("Editor token didn't get authorized. Editor functionallity maybe malfunctioning.")
