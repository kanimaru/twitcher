@tool
extends Object

class_name TwitchSetting


## Uses the implicit auth flow see also: https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#implicit-grant-flow
## @deprecated use AuthorizationCodeGrantFlow...
const FLOW_IMPLICIT = "ImplicitGrantFlow";
## Uses the client credentials auth flow see also: https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#client-credentials-grant-flow
const FLOW_CLIENT_CREDENTIALS = "ClientCredentialsGrantFlow";
## Uses the auth code flow see also: https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#authorization-code-grant-flow
const FLOW_AUTHORIZATION_CODE = "AuthorizationCodeGrantFlow";
## Uses an device code and no redirect url see: https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#device-code-grant-flow
const FLOW_DEVICE_CODE_GRANT = "DeviceCodeGrantFlow";

const LOGGER_NAME_AUTH = "TwitchAuthorization"
const LOGGER_NAME_EVENT_SUB = "TwitchEventSub"
const LOGGER_NAME_REST_API = "TwitchRestAPI"
const LOGGER_NAME_IRC = "TwitchIRC"
const LOGGER_NAME_IMAGE_LOADER = "TwitchImageLoader"
const LOGGER_NAME_COMMAND_HANDLING = "TwitchCommandHandling"
const LOGGER_NAME_SERVICE = "TwitchService"
const LOGGER_NAME_HTTP_CLIENT = "TwitchHttpClient"
const LOGGER_NAME_HTTP_SERVER = "TwitchHttpServer"
const LOGGER_NAME_WEBSOCKET = "TwitchWebsocket"
const LOGGER_NAME_CUSTOM_REWARDS = "TwitchCustomRewards"

const ALL_LOGGERS: Array[String] = [
	LOGGER_NAME_AUTH,
	LOGGER_NAME_EVENT_SUB,
	LOGGER_NAME_REST_API,
	LOGGER_NAME_IRC,
	LOGGER_NAME_IMAGE_LOADER,
	LOGGER_NAME_COMMAND_HANDLING,
	LOGGER_NAME_SERVICE,
	LOGGER_NAME_HTTP_CLIENT,
	LOGGER_NAME_HTTP_SERVER,
	LOGGER_NAME_WEBSOCKET,
	LOGGER_NAME_CUSTOM_REWARDS,
];

class Property:
	var key: String;
	var default_value: Variant;

	func _init(k: String, default_val: Variant = "") -> void:
		key = k;
		default_value = default_val;
		_add_property()

	func _add_property():
		if not ProjectSettings.has_setting(key):
			ProjectSettings.set_setting(key, default_value);
		ProjectSettings.set_initial_value(key, default_value);

	func get_val() -> Variant:
		return ProjectSettings.get_setting_with_override(key);

	func set_val(val) -> void:
		ProjectSettings.set(key, val);

	func basic() -> Property:
		ProjectSettings.set_as_basic(key, true);
		return self;

	func as_str(description: String = "") -> Property:
		return _add_type_def(TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, description);

	func as_select(values: Array[String], optional: bool = true) -> Property:
		var hint_string = ",".join(values);
		var enum_hint = PROPERTY_HINT_ENUM;
		if optional: enum_hint = PROPERTY_HINT_ENUM_SUGGESTION;
		return _add_type_def(TYPE_STRING, enum_hint, hint_string);

	func as_bit_field(values: Array[String]) -> Property:
		var hint_string = ",".join(values);
		return _add_type_def(TYPE_INT, PROPERTY_HINT_FLAGS, hint_string);

	func as_password(description: String = "") -> Property:
		return _add_type_def(TYPE_STRING, PROPERTY_HINT_PASSWORD, description);

	func as_bool(description: String = "") -> Property:
		return _add_type_def(TYPE_BOOL, PROPERTY_HINT_PLACEHOLDER_TEXT, description)

	func as_num() -> Property:
		return _add_type_def(TYPE_INT, PROPERTY_HINT_NONE, "")

	func as_global() -> Property:
		return _add_type_def(TYPE_STRING, PROPERTY_HINT_GLOBAL_FILE, "");

	func as_image() -> Property:
		return _add_type_def(TYPE_STRING, PROPERTY_HINT_FILE, "*.png,*.jpg,*.tres")

	func as_dir() -> Property:
		return _add_type_def(TYPE_STRING, PROPERTY_HINT_DIR, "");

	## Type should be the generic type of the array
	func as_list(type: Variant = "") -> Property:
		return _add_type_def(TYPE_ARRAY, PROPERTY_HINT_ARRAY_TYPE, type);

	## The hint string can be a set of filters with wildcards like "*.png,*.jpg"
	func as_global_save(file_types: String = "") -> Property:
		return _add_type_def(TYPE_STRING, PROPERTY_HINT_GLOBAL_SAVE_FILE, file_types)

	func _add_type_def(type: int, hint: int, hint_string: Variant) -> Property:
		ProjectSettings.add_property_info({
		   "name": key,
		   "type": type,
		   "hint": hint,
		   "hint_string": hint_string
		})
		return self

static var _broadcaster_id: Property
static var broadcaster_id: String:
	get: return _broadcaster_id.get_val();
	set(val): _broadcaster_id.set_val(val);

static var _authorization_flow: Property
static var authorization_flow: String:
	get: return _authorization_flow.get_val();
	set(val): _authorization_flow.set_val(val);

static var _client_id: Property
static var client_id: String:
	get: return _client_id.get_val();
	set(val): _client_id.set_val(val);

static var _client_secret: Property
static var client_secret: String:
	get: return _client_secret.get_val();
	set(val): _client_secret.set_val(val);

static var _redirect_url: Property
static var redirect_url: String:
	get: return _redirect_url.get_val();
	set(val): _redirect_url.set_val(val);

static var redirect_port: int:
	get: return _get_redirect_port();

static var _scopes: Dictionary = {}
static var scopes: String:
	get: return get_scopes()

static var _force_verify: Property
static var force_verify: String:
	get: return _force_verify.get_val();
	set(val): _force_verify.set_val(val);

static var _subscriptions: Dictionary = {}
## Return the subscribed subscriptions key = TwitchSubscriptions.Subscription, value = Dictionary with conditions (ready to use)
static var subscriptions: Dictionary:
	get: return get_subscriptions();

static var image_transformers: Dictionary = {};
static var image_transformer: TwitchImageTransformer:
	get: return get_image_transformer();

static var _image_tranformer_path: Property
static var image_tranformer_path: String:
	get: return _image_tranformer_path.get_val();
	set(val): _image_tranformer_path.set_val(val);

static var _imagemagic_path: Property
static var imagemagic_path: String:
	get: return _imagemagic_path.get_val();
	set(val): _imagemagic_path.set_val(val);

static var _twitch_image_cdn_host: Property
static var twitch_image_cdn_host: String:
	get: return _twitch_image_cdn_host.get_val();
	set(val): _twitch_image_cdn_host.set_val(val);

static var _auth_cache: Property
static var auth_cache: String:
	get: return _auth_cache.get_val();
	set(val): _auth_cache.set_val(val);

static var _token_host: Property
static var token_host: String:
	get: return _token_host.get_val();
	set(val): _token_host.set_val(val);

static var _token_endpoint: Property
static var token_endpoint: String:
	get: return _token_endpoint.get_val();
	set(val): _token_endpoint.set_val(val);

static var _fallback_texture: Property
static var fallback_texture2d: Texture2D:
	get:
		var path = _fallback_texture.get_val();
		return load(path)
	set(val): _fallback_texture.set_val(val.resource_path);

static var _fallback_profile: Property
static var fallback_profile: Texture2D:
	get:
		var path = _fallback_profile.get_val();
		return load(path)
	set(val): _fallback_profile.set_val(val.resource_path);

static var _cache_emote: Property
static var cache_emote: String:
	get: return _cache_emote.get_val();
	set(val): _cache_emote.set_val(val);

static var _cache_badge: Property
static var cache_badge: String:
	get: return _cache_badge.get_val();
	set(val): _cache_badge.set_val(val);

static var _cache_cheermote: Property
static var cache_cheermote: String:
	get: return _cache_cheermote.get_val();
	set(val): _cache_cheermote.set_val(val);

static var _use_test_server: Property
static var use_test_server: bool:
	get: return _use_test_server.get_val();
	set(val): _use_test_server.set_val(val);

static var _eventsub_test_server_url: Property
static var eventsub_test_server_url: String:
	get: return _eventsub_test_server_url.get_val();
	set(val): _eventsub_test_server_url.set_val(val);

static var _eventsub_live_server_url: Property
static var eventsub_live_server_url: String:
	get: return _eventsub_live_server_url.get_val();
	set(val): _eventsub_live_server_url.set_val(val);

static var _irc_server_url: Property
static var irc_server_url: String:
	get: return _irc_server_url.get_val();
	set(val): _irc_server_url.set_val(val);

static var _irc_username: Property
static var irc_username: String:
	get: return _irc_username.get_val();
	set(val): _irc_username.set_val(val);

static var _irc_connect_to_channel: Property;
static var irc_connect_to_channel: Array[StringName]:
	get:
		var channel_names : Array[StringName];
		for channel in _irc_connect_to_channel.get_val():
			channel_names.append(channel);
		return channel_names;

static var _irc_login_message: Property;
static var irc_login_message: String:
	get: return _irc_login_message.get_val();
	set(val): _irc_login_message.set_val(val);

static var _irc_send_message_delay: Property;
static var irc_send_message_delay: int:
	get: return _irc_send_message_delay.get_val();
	set(val): _irc_send_message_delay.set_val(val);

static var _irc_capabilities: Property;
static var irc_capabilities: Array[String]:
	get: return get_irc_capabilities();

static var _api_host: Property;
static var api_host: String:
	get: return _api_host.get_val();
	set(val): _api_host.set_val(val);

static var _ignore_message_eventsub_in_seconds: Property;
static var ignore_message_eventsub_in_seconds: int:
	get: return _ignore_message_eventsub_in_seconds.get_val();
	set(val): _ignore_message_eventsub_in_seconds.set_val(val);

static var _http_client_min: Property;
static var http_client_min: int:
	get: return _http_client_min.get_val();
	set(val): _http_client_min.set_val(val);

static var _http_client_max: Property;
static var http_client_max: int:
	get: return _http_client_max.get_val();
	set(val): _http_client_max.set_val(val);

static var _log_enabled: Property;
static var log_enabled: Array[String]:
	get: return get_log_enabled()

static func setup() -> void:
	# Auth
	_broadcaster_id = Property.new("twitch/auth/broadcaster_id").as_str("Broadcaster ID of youself").basic();
	_authorization_flow = Property.new("twitch/auth/authorization_flow", "AuthorizationCodeGrantFlow").as_select([FLOW_IMPLICIT, FLOW_CLIENT_CREDENTIALS, FLOW_AUTHORIZATION_CODE, FLOW_DEVICE_CODE_GRANT], false);
	_client_id = Property.new("twitch/auth/client_id").as_str("Client ID you can find it in https://api.twitch.tv/").basic();
	_client_secret = Property.new("twitch/auth/client_secret").as_password("Client Secret you can find it in https://api.twitch.tv/").basic();
	_redirect_url = Property.new("twitch/auth/redirect_url", "http://localhost:7170").as_str("Redirect URL that Twitch calls after a successful login").basic();
	_force_verify = Property.new("twitch/auth/force_verify", "false").as_bool("Set to true to force the user to re-authorize your app’s access to their resources. The default is false.");
	_setup_scopes();
	_setup_subscriptions();

	_auth_cache = Property.new("twitch/auth/api/auth_file_cache", "user://auth.conf").as_global_save();
	_token_host = Property.new("twitch/auth/api/token_host", "https://id.twitch.tv").as_str();
	_token_endpoint = Property.new("twitch/auth/api/token_endpoint", "/oauth2/token").as_str();

	# General
	_api_host = Property.new("twitch/general/api/api_host", "https://api.twitch.tv").as_str();
	_imagemagic_path = Property.new("twitch/general/images/image_magic", "").as_global();
	_image_tranformer_path = Property.new("twitch/general/images/image_transformer", "TwitchImageTransformer").as_select(get_image_transformers());
	_twitch_image_cdn_host = Property.new("twitch/general/cdn/twitch_host", "https://static-cdn.jtvnw.net").as_str("Default host for getting twitch emojis/cheermoji/badges.");

	const FALLBACK_TEXTURE = preload("./assets/fallback_texture.tres");
	_fallback_texture = Property.new("twitch/general/assets/fallback_texture", FALLBACK_TEXTURE.resource_path).as_image();
	const FALLBACK_PROFILE = preload("./assets/no_profile.png");
	_fallback_profile = Property.new("twitch/general/assets/fallback_profile", FALLBACK_PROFILE.resource_path).as_image().basic();
	_cache_emote = Property.new("twitch/general/assets/cache_emote", "user://emotes").as_dir();
	_cache_badge = Property.new("twitch/general/assets/cache_badge", "user://badges").as_dir();
	_cache_cheermote = Property.new("twitch/general/assets/cache_cheermote", "user://cheermotes").as_dir();

	_http_client_min = Property.new("twitch/general/http_client/min_amount", 2).as_num();
	_http_client_max = Property.new("twitch/general/http_client/max_amount", 4).as_num();

	_log_enabled = Property.new("twitch/general/logging/enabled").as_bit_field(ALL_LOGGERS);

	# Websocket
	_use_test_server = Property.new("twitch/websocket/eventsub/use_test_server", false).as_bool("Will try to connect to 'Twitch CLI' test server")
	_eventsub_test_server_url = Property.new("twitch/websocket/eventsub/test_server", "ws://127.0.0.1:8081/ws").as_str("In case the 'Twitch CLI' is used to test");
	_eventsub_live_server_url = Property.new("twitch/websocket/eventsub/live_server", "wss://eventsub.wss.twitch.tv/ws").as_str();
	_ignore_message_eventsub_in_seconds = Property.new("twitch/websocket/eventsub/ignore_messages_older_than_(in_seconds)", 600).as_num();
	_irc_server_url = Property.new("twitch/websocket/irc/server", "wss://irc-ws.chat.twitch.tv:443").as_str();
	_irc_username = Property.new("twitch/websocket/irc/username", "").as_str("The name of the bot within the chat").basic();
	var default_connect_to_channel: Array[StringName] = [];
	_irc_connect_to_channel = Property.new("twitch/websocket/irc/connect_to_channel", default_connect_to_channel).as_list().basic();
	_irc_login_message = Property.new("twitch/websocket/irc/login_message", "Bot has successfully connected.").as_str("Message that the bot sends after connection (can be removed)").basic();
	_irc_send_message_delay = Property.new("twitch/websocket/irc/send_message_delay_(in milliseconds)", 320).as_num();
	var default_caps: Array[TwitchIrcCapabilities.Capability] = [TwitchIrcCapabilities.COMMANDS, TwitchIrcCapabilities.TAGS];
	var default_cap_val = TwitchIrcCapabilities.get_bit_value(default_caps);
	_irc_capabilities = Property.new("twitch/websocket/irc/capabilities", default_cap_val).as_bit_field(_get_all_irc_capabilities()).basic();

static func get_log_enabled() -> Array[String]:
	var result: Array[String] = [];
	# Other classes can be initialized before the settings and use the log.
	if _log_enabled == null:
		return result;
	var bitset = _log_enabled.get_val();
	if typeof(bitset) == TYPE_STRING && bitset == "" || typeof(bitset) == TYPE_INT && bitset == 0:
		return result
	for logger_idx: int in range(ALL_LOGGERS.size()):
		var bit_value = 1 << logger_idx;
		if bitset & bit_value == bit_value:
			result.append(ALL_LOGGERS[logger_idx])
	return result

static func is_log_enabled(logger: String) -> bool:
	return log_enabled.find(logger) != -1;

static func get_image_transformers() -> Array[String]:
	var result: Array[String] = [];
	var magic = MagicImageTransformer.new()
	if magic.is_supported():
		image_transformers["MagicImageTransformer"] = magic;
		result.append("MagicImageTransformer");

	var twitch = TwitchImageTransformer.new()
	image_transformers["TwitchImageTransformer"] = twitch;
	result.append("TwitchImageTransformer");

	var native = NativeImageTransformer.new()
	image_transformers["NativeImageTransformer"] = native;
	result.append("NativeImageTransformer");

	return result;

static func get_image_transformer() -> TwitchImageTransformer:
	if image_transformers.has(image_tranformer_path):
		return image_transformers[image_tranformer_path];
	var transformer = load(image_tranformer_path);
	return transformer;

## Converts the categoriezed bitset back to the strings
static func get_scopes() -> String:
	var grouped_scopes = TwitchScopes.get_grouped_scopes();
	var result = [];
	for category_name: String in grouped_scopes:
		var scope_property: Property = _scopes[category_name];
		var bitset = scope_property.get_val();
		if typeof(bitset) == TYPE_STRING && bitset == "" || typeof(bitset) == TYPE_INT && bitset == 0: continue
		var scopes = grouped_scopes[category_name];
		for scope: TwitchScopes.Scope in scopes:
			if bitset & scope.bit_value == scope.bit_value:
				result.append(scope.value)
	return " ".join(result);

static func _setup_scopes():
	var grouped_scopes: Dictionary = TwitchScopes.get_grouped_scopes();

	for category_name: String in grouped_scopes:
		var scopes: Array = grouped_scopes[category_name];
		var scope_names: Array[String] = [];
		for scope: TwitchScopes.Scope in scopes:
			scope_names.append(scope.get_name());
		_scopes[category_name] = Property.new("twitch/auth/scopes/" + category_name, "").as_bit_field(scope_names).basic();

static func _get_redirect_port() -> int:
	var url_parts = redirect_url.rsplit(":", true, 1);
	var port: int = int(url_parts[1]);
	if port == 0: port = 80;
	return port;

static func _get_all_irc_capabilities() -> Array[String]:
	var caps = TwitchIrcCapabilities.get_all()
	var result: Array[String] = [];
	for cap in caps:
		result.append(cap.get_name());
	return result;

static func get_irc_capabilities() -> Array[String]:
	var result: Array[String] = []
	var bitset = _irc_capabilities.get_val();
	if typeof(bitset) == TYPE_STRING && bitset == "" || typeof(bitset) == TYPE_INT && bitset == 0:
		return result;
	for cap : TwitchIrcCapabilities.Capability in TwitchIrcCapabilities.get_all():
		if bitset & cap.bit_value == cap.bit_value:
			result.append(cap.value);
	return result;

static func _setup_subscriptions():
	for subscription in TwitchSubscriptions.get_all():
		var subscription_properties = []
		_subscriptions[subscription] = subscription_properties;
		subscription_properties.append(Property.new("twitch/eventsub/%s/subscribed" % subscription.get_name(), false).as_bool().basic());
		for condition in subscription.conditions:
			subscription_properties.append(Property.new("twitch/eventsub/%s/%s" % [subscription.get_name(), condition], "").as_str().basic());

## Return the subscribed subscriptions key = TwitchSubscriptions.Subscription, value = Dictionary with conditions (ready to use)
static func get_subscriptions() -> Dictionary:
	var result = {};
	for subscription in TwitchSubscriptions.get_all():
		var properties: Array = _subscriptions[subscription];
		var subscribed_property: Property = properties[0];

		if subscribed_property.get_val():
			result[subscription] = get_conditions(properties);
	return result;

static func get_conditions(properties: Array) -> Dictionary:
	var condition: Dictionary = {}
	# Skip first property that is the "subscribed" boolean
	for property: Property in properties.slice(1):
		var condition_name: String = property.key
		condition_name = condition_name.substr(condition_name.rfind("/") + 1);
		condition[condition_name] = property.get_val();
	return condition;
