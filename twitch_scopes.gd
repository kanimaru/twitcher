@tool
extends Object

class_name TwitchScopes

class Scope extends RefCounted:
	var value: String;
	var bit_value: int;

	func _init(val: String, bit_val: int) -> void:
		value = val;
		bit_value = bit_val;

	func get_name() -> String:
		return value.replace(":", "_") + ":" + str(bit_value);

	func get_category() -> String:
		return value.substr(0, value.find(":"));

static var CHAT_READ = Scope.new("chat:read", 1);
static var CHAT_EDIT = Scope.new("chat:edit", 2);
static var ANALYTICS_READ_EXTENSIONS = Scope.new("analytics:read:extensions", 1);
static var ANALYTICS_READ_GAMES = Scope.new("analytics:read:games", 2);
static var BITS_READ = Scope.new("bits:read", 1);
static var CHANNEL_EDIT_COMMERCIAL = Scope.new("channel:edit:commercial", 1);
static var CHANNEL_MANAGE_ADS = Scope.new("channel:manage:ads", 2);
static var CHANNEL_MANAGE_BROADCAST = Scope.new("channel:manage:broadcast", 4);
static var CHANNEL_MANAGE_EXTENSIONS = Scope.new("channel:manage:extensions", 8);
static var CHANNEL_MANAGE_GUEST_STAR = Scope.new("channel:manage:guest_star", 16);
static var CHANNEL_MANAGE_MODERATORS = Scope.new("channel:manage:moderators", 32);
static var CHANNEL_MANAGE_POLLS = Scope.new("channel:manage:polls", 64);
static var CHANNEL_MANAGE_PREDICTIONS = Scope.new("channel:manage:predictions", 128);
static var CHANNEL_MANAGE_RAIDS = Scope.new("channel:manage:raids", 256);
static var CHANNEL_MANAGE_REDEMPTIONS = Scope.new("channel:manage:redemptions", 512);
static var CHANNEL_MANAGE_SCHEDULE = Scope.new("channel:manage:schedule", 1024);
static var CHANNEL_MANAGE_VIDEOS = Scope.new("channel:manage:videos", 2048);
static var CHANNEL_MANAGE_VIPS = Scope.new("channel:manage:vips", 4096);
static var CHANNEL_READ_ADS = Scope.new("channel:read:ads", 8192);
static var CHANNEL_READ_CHARITY = Scope.new("channel:read:charity", 16384);
static var CHANNEL_READ_EDITORS = Scope.new("channel:read:editors", 32768);
static var CHANNEL_READ_GOALS = Scope.new("channel:read:goals", 65536);
static var CHANNEL_READ_GUEST_STAR = Scope.new("channel:read:guest_star", 131072);
static var CHANNEL_READ_HYPE_TRAIN = Scope.new("channel:read:hype_train", 262144);
static var CHANNEL_READ_POLLS = Scope.new("channel:read:polls", 524288);
static var CHANNEL_READ_PREDICTIONS = Scope.new("channel:read:predictions", 1048576);
static var CHANNEL_READ_REDEMPTIONS = Scope.new("channel:read:redemptions", 2097152);
static var CHANNEL_READ_STREAM_KEY = Scope.new("channel:read:stream_key", 4194304);
static var CHANNEL_READ_SUBSCRIPTIONS = Scope.new("channel:read:subscriptions", 8388608);
static var CHANNEL_READ_VIPS = Scope.new("channel:read:vips", 16777216);
static var CHANNEL_CHANNEL_BOT = Scope.new("channel:bot", 33554432);
static var CHANNEL_CHANNEL_MODERATE = Scope.new("channel:moderate", 67108864);
static var CLIPS_EDIT = Scope.new("clips:edit", 1);
static var MODERATION_READ = Scope.new("moderation:read", 1);
static var MODERATOR_MANAGE_ANNOUNCEMENTS = Scope.new("moderator:manage:announcements", 1);
static var MODERATOR_MANAGE_AUTOMOD = Scope.new("moderator:manage:automod", 2);
static var MODERATOR_MANAGE_AUTOMOD_SETTINGS = Scope.new("moderator:manage:automod_settings", 4);
static var MODERATOR_MANAGE_BANNED_USERS = Scope.new("moderator:manage:banned_users", 8);
static var MODERATOR_MANAGE_BLOCKED_TERMS = Scope.new("moderator:manage:blocked_terms", 16);
static var MODERATOR_MANAGE_CHAT_MESSAGES = Scope.new("moderator:manage:chat_messages", 32);
static var MODERATOR_MANAGE_CHAT_SETTINGS = Scope.new("moderator:manage:chat_settings", 64);
static var MODERATOR_MANAGE_GUEST_STAR = Scope.new("moderator:manage:guest_star", 128);
static var MODERATOR_MANAGE_SHIELD_MODE = Scope.new("moderator:manage:shield_mode", 256);
static var MODERATOR_MANAGE_SHOUTOUTS = Scope.new("moderator:manage:shoutouts", 512);
static var MODERATOR_READ_AUTOMOD_SETTINGS = Scope.new("moderator:read:automod_settings", 1024);
static var MODERATOR_READ_BLOCKED_TERMS = Scope.new("moderator:read:blocked_terms", 2048);
static var MODERATOR_READ_CHATTERS = Scope.new("moderator:read:chatters", 8192);
static var MODERATOR_READ_CHAT_SETTINGS = Scope.new("moderator:read:chat_settings", 4096);
static var MODERATOR_READ_FOLLOWERS = Scope.new("moderator:read:followers", 16384);
static var MODERATOR_READ_GUEST_STAR = Scope.new("moderator:read:guest_star", 32768);
static var MODERATOR_READ_SHIELD_MODE = Scope.new("moderator:read:shield_mode", 65536);
static var MODERATOR_READ_SHOUTOUTS = Scope.new("moderator:read:shoutouts", 131072);
static var USER_EDIT = Scope.new("user:edit", 1);
static var USER_EDIT_FOLLOWS = Scope.new("user:edit:follows", 2);
static var USER_MANAGE_BLOCKED_USERS = Scope.new("user:manage:blocked_users", 4);
static var USER_MANAGE_CHAT_COLOR = Scope.new("user:manage:chat_color", 8);
static var USER_MANAGE_WHISPERS = Scope.new("user:manage:whispers", 16);
static var USER_READ_BLOCKED_USERS = Scope.new("user:read:blocked_users", 32);
static var USER_READ_BROADCAST = Scope.new("user:read:broadcast", 64);
static var USER_READ_EMAIL = Scope.new("user:read:email", 128);
static var USER_READ_FOLLOWS = Scope.new("user:read:follows", 256);
static var USER_READ_MODERATED_CHANNELS = Scope.new("user:read:moderated_channels", 512);
static var USER_READ_SUBSCRIPTIONS = Scope.new("user:read:subscriptions", 1024);
static var USER_BOT = Scope.new("user:bot", 2048);
static var USER_READ_CHAT = Scope.new("user:read:chat", 4096);
static var USER_WRITE_CHAT = Scope.new("user:write:chat", 8192);
static var WHISPERS_READ = Scope.new("whispers:read", 1);
static var WHISPERS_EDIT = Scope.new("whispers:edit", 2);

## Key as category, value as Array[Scope]
static func get_grouped_scopes() -> Dictionary:
	var result = {}
	for scope: Scope in get_all_scopes():
		var category_name = scope.get_category();
		var category = [];
		if not result.has(category_name):
			result[category_name] = category;
		else:
			category = result[category_name];
		category.append(scope);
	return result;

static func get_all_scopes() -> Array[Scope]:
	return [
		CHAT_READ,
		CHAT_EDIT,
		ANALYTICS_READ_EXTENSIONS,
		ANALYTICS_READ_GAMES,
		BITS_READ,
		CHANNEL_EDIT_COMMERCIAL,
		CHANNEL_MANAGE_ADS,
		CHANNEL_MANAGE_BROADCAST,
		CHANNEL_MANAGE_EXTENSIONS,
		CHANNEL_MANAGE_GUEST_STAR,
		CHANNEL_MANAGE_MODERATORS,
		CHANNEL_MANAGE_POLLS,
		CHANNEL_MANAGE_PREDICTIONS,
		CHANNEL_MANAGE_RAIDS,
		CHANNEL_MANAGE_REDEMPTIONS,
		CHANNEL_MANAGE_SCHEDULE,
		CHANNEL_MANAGE_VIDEOS,
		CHANNEL_MANAGE_VIPS,
		CHANNEL_READ_ADS,
		CHANNEL_READ_CHARITY,
		CHANNEL_READ_EDITORS,
		CHANNEL_READ_GOALS,
		CHANNEL_READ_GUEST_STAR,
		CHANNEL_READ_HYPE_TRAIN,
		CHANNEL_READ_POLLS,
		CHANNEL_READ_PREDICTIONS,
		CHANNEL_READ_REDEMPTIONS,
		CHANNEL_READ_STREAM_KEY,
		CHANNEL_READ_SUBSCRIPTIONS,
		CHANNEL_READ_VIPS,
		CHANNEL_CHANNEL_BOT,
		CHANNEL_CHANNEL_MODERATE,
		CLIPS_EDIT,
		MODERATION_READ,
		MODERATOR_MANAGE_ANNOUNCEMENTS,
		MODERATOR_MANAGE_AUTOMOD,
		MODERATOR_MANAGE_AUTOMOD_SETTINGS,
		MODERATOR_MANAGE_BANNED_USERS,
		MODERATOR_MANAGE_BLOCKED_TERMS,
		MODERATOR_MANAGE_CHAT_MESSAGES,
		MODERATOR_MANAGE_CHAT_SETTINGS,
		MODERATOR_MANAGE_GUEST_STAR,
		MODERATOR_MANAGE_SHIELD_MODE,
		MODERATOR_MANAGE_SHOUTOUTS,
		MODERATOR_READ_AUTOMOD_SETTINGS,
		MODERATOR_READ_BLOCKED_TERMS,
		MODERATOR_READ_CHATTERS,
		MODERATOR_READ_CHAT_SETTINGS,
		MODERATOR_READ_FOLLOWERS,
		MODERATOR_READ_GUEST_STAR,
		MODERATOR_READ_SHIELD_MODE,
		MODERATOR_READ_SHOUTOUTS,
		USER_EDIT,
		USER_EDIT_FOLLOWS,
		USER_MANAGE_BLOCKED_USERS,
		USER_MANAGE_CHAT_COLOR,
		USER_MANAGE_WHISPERS,
		USER_READ_BLOCKED_USERS,
		USER_READ_BROADCAST,
		USER_READ_EMAIL,
		USER_READ_FOLLOWS,
		USER_READ_MODERATED_CHANNELS,
		USER_READ_SUBSCRIPTIONS,
		USER_BOT,
		USER_READ_CHAT,
		USER_WRITE_CHAT,
		WHISPERS_READ,
		WHISPERS_EDIT
	]
