@icon("res://addons/twitcher/assets/auth-icon.svg")
@tool
extends Twitcher

## Delegate class for the oOuch Library.
class_name TwitchAuth

const HttpUtil = preload("res://addons/twitcher/lib/http/http_util.gd")
const META_ONGOING_AUTHORIZATION: StringName = &"_Addons_Twitcher_Auth_TwitchAuth_ongoing"

static var _log: TwitchLogger = TwitchLogger.new("TwitchAuth")

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: OAuth.OAuthDeviceCodeResponse)

## Where and how to authorize.
@export var oauth_setting: OAuthSetting:
	set(val):
		oauth_setting = val
		if auth != null: auth.oauth_setting = oauth_setting
		if token_handler != null: token_handler.oauth_setting = oauth_setting
		update_configuration_warnings()
## Shows the what to authorize page of twitch again. (for example you need to relogin with a different account aka bot account)
@export var force_verify: bool
## Where should the tokens be saved into
@export var token: OAuthToken:
	set(val):
		token = val
		if token_handler != null: token_handler.token = token
		update_configuration_warnings()
## Scopes for the token that should be requested
@export var scopes: OAuthScopes:
	set(val):
		scopes = val
		if auth != null: auth.scopes = scopes
		update_configuration_warnings()

## Takes care to authorize the user
var auth: OAuth
## Takes care to fetch and refresh oauth tokens
var token_handler: TwitchTokenHandler


var is_authenticated: bool:
	get(): return auth.is_authenticated()


func _init() -> void:
	child_entered_tree.connect(_on_enter_child)
	# There could be better locations but this ensures that its there when an
	# auth is needed.
	var http_logger: TwitchLogger = TwitchLogger.new("Http")
	HttpUtil.set_logger(http_logger.e, http_logger.i, http_logger.d)


func _on_enter_child(node: Node) -> void:
	if node is OAuth: auth = node
	if node is TwitchTokenHandler: token_handler = node


func _ready() -> void:
	OAuth.set_logger(_log.e, _log.i, _log.d);
	if oauth_setting == null: oauth_setting = create_default_oauth_setting()
	_ensure_children()
	auth.device_code_requested.connect(device_code_requested.emit)


func _ensure_children() -> void:
	if token_handler == null:
		token_handler = TwitchTokenHandler.new()
		token_handler.name = &"TokenHandler"

	if auth == null:
		auth = OAuth.new()
		auth.name = &"OAuth"

	_sync_childs()

	if not auth.is_inside_tree():
		add_child(auth)
		_set_owner_safely(auth)

	if not token_handler.is_inside_tree():
		add_child(token_handler)
		_set_owner_safely(token_handler)


func _set_owner_safely(node: Node) -> void:
	if owner != null:
		node.owner = owner
	elif Engine.is_editor_hint():
		var edited_scene: Node = get_tree().edited_scene_root
		if edited_scene and (edited_scene == self or edited_scene.is_ancestor_of(self)):
			node.owner = edited_scene



func _sync_childs() -> void:
	token_handler.oauth_setting = oauth_setting
	token_handler.token = token
	auth.token_handler = token_handler
	auth.oauth_setting = oauth_setting
	auth.scopes = scopes
	auth.force_verify = "true" if force_verify else "false"


## Authorize twitch if it is logged in it will shortcut and return true
## force: do the login even when already logged in
func authorize(force: bool = false) -> bool:
	_sync_childs()
	if await auth.login(force):
		token_handler.process_mode = Node.PROCESS_MODE_INHERIT
		return true
	return false


func wait_unsetup() -> void:
	await token_handler.revoke_token()
	_log.d("revoked tokens on twitch side during unsetup")


func refresh_token() -> void:
	auth.refresh_token()


static func create_default_oauth_setting() -> OAuthSetting:
	var oauth_setting = OAuthSetting.new()
	oauth_setting.authorization_flow = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW
	oauth_setting.device_authorization_url = "https://id.twitch.tv/oauth2/device"
	oauth_setting.token_url = "https://id.twitch.tv/oauth2/token"
	oauth_setting.authorization_url = "https://id.twitch.tv/oauth2/authorize"
	oauth_setting.redirect_url = "http://localhost:7170"
	return oauth_setting


static func manual_authorize(
		setting: OAuthSetting,
		token_to_authorize: OAuthToken,
		force: bool = false,
		oauth_scopes: OAuthScopes = null) -> void:
	# Default Editor Scopes
	if not oauth_scopes: oauth_scopes = preload("uid://cgqldyna2cv5h") # res://addons/twitcher/assets/twitcher_editor_scopes.tres

	if not setting.is_valid():
		_log.d("Can't validate token cause OAuthSettings are invalid.")
		return
	var root_node: Node = EditorInterface.get_base_control() if Engine.is_editor_hint() else Engine.get_main_loop().root

	if root_node.has_meta(META_ONGOING_AUTHORIZATION):
		var twitch_auth: TwitchAuth = root_node.get_meta(META_ONGOING_AUTHORIZATION)
		if twitch_auth.token == token_to_authorize:
			_log.i("An authorization for the same token %s is ongoing. Waiting..." % token_to_authorize)
			await twitch_auth.token.authorized
			return
		else:
			_log.i("An authorization for a different token %s is ongoing. Waiting..." % twitch_auth.token)
			await twitch_auth.token.authorized

	var auth: TwitchAuth = TwitchAuth.new()
	auth.oauth_setting = setting
	auth.token = token_to_authorize
	auth.scopes = oauth_scopes
	root_node.set_meta(META_ONGOING_AUTHORIZATION, auth)
	root_node.add_child(auth)

	_log.d("Do manual authorization %s" % token_to_authorize)
	if not auth.is_node_ready(): await auth.ready
	var success: bool = await auth.authorize(force)
	auth.queue_free()
	root_node.remove_meta(META_ONGOING_AUTHORIZATION)
	if not success:
		_log.e("Token authorization failed.")
		return
	_log.i("Token got authorized")


## Checks if the correctly setup
func is_configured() -> bool:
	return _get_configuration_warnings().is_empty()


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if oauth_setting == null:
		result.append("OAuthSetting missing")
	else:
		var oauth_setting_problems : PackedStringArray = oauth_setting.get_valididation_problems()
		if not oauth_setting_problems.is_empty():
			result.append("OAuthSetting is invalid")
			result.append_array(oauth_setting_problems)
	if scopes == null:
		result.append("OAuthScopes is missing")
	if token == null:
		result.append("OAuthToken is missing")
	return result
