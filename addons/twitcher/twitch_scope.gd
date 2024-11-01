@tool
extends Resource

class_name TwitchScope

class Definition extends Object:
	var value: StringName;
	var description: String;

	func _init(val: StringName, desc: String) -> void:
		value = val;
		description = desc;

	func get_category() -> String:
		return value.substr(0, value.find(":"));

static var ANALYTICS_READ_EXTENSIONS = Definition.new(&"analytics:read:extensions", "View analytics data for the Twitch Extensions owned by the authenticated account.")
static var ANALYTICS_READ_GAMES = Definition.new(&"analytics:read:games", "View analytics data for the games owned by the authenticated account.")
static var BITS_READ = Definition.new(&"bits:read", "View Bits information for a channel.")
static var CHANNEL_BOT = Definition.new(&"channel:bot", "Joins your channel’s chatroom as a bot user, and perform chat-related actions as that user.")
static var CHANNEL_MANAGE_ADS = Definition.new(&"channel:manage:ads", "Manage ads schedule on a channel.")
static var CHANNEL_READ_ADS = Definition.new(&"channel:read:ads", "Read the ads schedule and details on your channel.")
static var CHANNEL_MANAGE_BROADCAST = Definition.new(&"channel:manage:broadcast", "Manage a channel’s broadcast configuration, including updating channel configuration and managing stream markers and stream tags.")
static var CHANNEL_READ_CHARITY = Definition.new(&"channel:read:charity", "Read charity campaign details and user donations on your channel.")
static var CHANNEL_EDIT_COMMERCIAL = Definition.new(&"channel:edit:commercial", "Run commercials on a channel.")
static var CHANNEL_READ_EDITORS = Definition.new(&"channel:read:editors", "View a list of users with the editor role for a channel.")
static var CHANNEL_MANAGE_EXTENSIONS = Definition.new(&"channel:manage:extensions", "Manage a channel’s Extension configuration, including activating Extensions.")
static var CHANNEL_READ_GOALS = Definition.new(&"channel:read:goals", "View Creator Goals for a channel.")
static var CHANNEL_READ_GUEST_STAR = Definition.new(&"channel:read:guest_star", "Read Guest Star details for your channel.")
static var CHANNEL_MANAGE_GUEST_STAR = Definition.new(&"channel:manage:guest_star", "Manage Guest Star for your channel.")
static var CHANNEL_READ_HYPE_TRAIN = Definition.new(&"channel:read:hype_train", "View Hype Train information for a channel.")
static var CHANNEL_MANAGE_MODERATORS = Definition.new(&"channel:manage:moderators", "Add or remove the moderator role from users in your channel.")
static var CHANNEL_READ_POLLS = Definition.new(&"channel:read:polls", "View a channel’s polls.")
static var CHANNEL_MANAGE_POLLS = Definition.new(&"channel:manage:polls", "Manage a channel’s polls.")
static var CHANNEL_READ_PREDICTIONS = Definition.new(&"channel:read:predictions", "View a channel’s Channel Points Predictions.")
static var CHANNEL_MANAGE_PREDICTIONS = Definition.new(&"channel:manage:predictions", "Manage of channel’s Channel Points Predictions")
static var CHANNEL_MANAGE_RAIDS = Definition.new(&"channel:manage:raids", "Manage a channel raiding another channel.")
static var CHANNEL_READ_REDEMPTIONS = Definition.new(&"channel:read:redemptions", "View Channel Points custom rewards and their redemptions on a channel.")
static var CHANNEL_MANAGE_REDEMPTIONS = Definition.new(&"channel:manage:redemptions", "Manage Channel Points custom rewards and their redemptions on a channel.")
static var CHANNEL_MANAGE_SCHEDULE = Definition.new(&"channel:manage:schedule", "Manage a channel’s stream schedule.")
static var CHANNEL_READ_STREAM_KEY = Definition.new(&"channel:read:stream_key", "View an authorized user’s stream key.")
static var CHANNEL_READ_SUBSCRIPTIONS = Definition.new(&"channel:read:subscriptions", "View a list of all subscribers to a channel and check if a user is subscribed to a channel.")
static var CHANNEL_MANAGE_VIDEOS = Definition.new(&"channel:manage:videos", "Manage a channel’s videos, including deleting videos.")
static var CHANNEL_READ_VIPS = Definition.new(&"channel:read:vips", "Read the list of VIPs in your channel.")
static var CHANNEL_MANAGE_VIPS = Definition.new(&"channel:manage:vips", "Add or remove the VIP role from users in your channel.")
static var CLIPS_EDIT = Definition.new(&"clips:edit", "Manage Clips for a channel.")
static var MODERATION_READ = Definition.new(&"moderation:read", "View a channel’s moderation data including Moderators, Bans, Timeouts, and Automod settings.")
static var MODERATOR_MANAGE_ANNOUNCEMENTS = Definition.new(&"moderator:manage:announcements", "Send announcements in channels where you have the moderator role.")
static var MODERATOR_MANAGE_AUTOMOD = Definition.new(&"moderator:manage:automod", "Manage messages held for review by AutoMod in channels where you are a moderator.")
static var MODERATOR_READ_AUTOMOD_SETTINGS = Definition.new(&"moderator:read:automod_settings", "View a broadcaster’s AutoMod settings.")
static var MODERATOR_MANAGE_AUTOMOD_SETTINGS = Definition.new(&"moderator:manage:automod_settings", "Manage a broadcaster’s AutoMod settings.")
static var MODERATOR_READ_BANNED_USERS = Definition.new(&"moderator:read:banned_users", "Read the list of bans or unbans in channels where you have the moderator role.")
static var MODERATOR_MANAGE_BANNED_USERS = Definition.new(&"moderator:manage:banned_users", "Ban and unban users.")
static var MODERATOR_READ_BLOCKED_TERMS = Definition.new(&"moderator:read:blocked_terms", "View a broadcaster’s list of blocked terms.")
static var MODERATOR_READ_CHAT_MESSAGES = Definition.new(&"moderator:read:chat_messages", "Read deleted chat messages in channels where you have the moderator role.")
static var MODERATOR_MANAGE_BLOCKED_TERMS = Definition.new(&"moderator:manage:blocked_terms", "Manage a broadcaster’s list of blocked terms.")
static var MODERATOR_MANAGE_CHAT_MESSAGES = Definition.new(&"moderator:manage:chat_messages", "Delete chat messages in channels where you have the moderator role")
static var MODERATOR_READ_CHAT_SETTINGS = Definition.new(&"moderator:read:chat_settings", "View a broadcaster’s chat room settings.")
static var MODERATOR_MANAGE_CHAT_SETTINGS = Definition.new(&"moderator:manage:chat_settings", "Manage a broadcaster’s chat room settings.")
static var MODERATOR_READ_CHATTERS = Definition.new(&"moderator:read:chatters", "View the chatters in a broadcaster’s chat room.")
static var MODERATOR_READ_FOLLOWERS = Definition.new(&"moderator:read:followers", "Read the followers of a broadcaster.")
static var MODERATOR_READ_GUEST_STAR = Definition.new(&"moderator:read:guest_star", "Read Guest Star details for channels where you are a Guest Star moderator.")
static var MODERATOR_MANAGE_GUEST_STAR = Definition.new(&"moderator:manage:guest_star", "Manage Guest Star for channels where you are a Guest Star moderator.")
static var MODERATOR_READ_MODERATORS = Definition.new(&"moderator:read:moderators", "Read the list of moderators in channels where you have the moderator role.")
static var MODERATOR_READ_SHIELD_MODE = Definition.new(&"moderator:read:shield_mode", "View a broadcaster’s Shield Mode status.")
static var MODERATOR_MANAGE_SHIELD_MODE = Definition.new(&"moderator:manage:shield_mode", "Manage a broadcaster’s Shield Mode status.")
static var MODERATOR_READ_SHOUTOUTS = Definition.new(&"moderator:read:shoutouts", "View a broadcaster’s shoutouts.")
static var MODERATOR_MANAGE_SHOUTOUTS = Definition.new(&"moderator:manage:shoutouts", "Manage a broadcaster’s shoutouts.")
static var MODERATOR_READ_SUSPICIOUS_USERS = Definition.new(&"moderator:read:suspicious_users", "Read chat messages from suspicious users and see users flagged as suspicious in channels where you have the moderator role.")
static var MODERATOR_READ_UNBAN_REQUESTS = Definition.new(&"moderator:read:unban_requests", "View a broadcaster’s unban requests.")
static var MODERATOR_MANAGE_UNBAN_REQUESTS = Definition.new(&"moderator:manage:unban_requests", "Manage a broadcaster’s unban requests.")
static var MODERATOR_READ_VIPS = Definition.new(&"moderator:read:vips", "Read the list of VIPs in channels where you have the moderator role.")
static var MODERATOR_READ_WARNINGS = Definition.new(&"moderator:read:warnings", "Read warnings in channels where you have the moderator role.")
static var MODERATOR_MANAGE_WARNINGS = Definition.new(&"moderator:manage:warnings", "Warn users in channels where you have the moderator role.")
static var USER_BOT = Definition.new(&"user:bot", "Join a specified chat channel as your user and appear as a bot, and perform chat-related actions as your user.")
static var USER_EDIT = Definition.new(&"user:edit", "Manage a user object.")
static var USER_EDIT_BROADCAST = Definition.new(&"user:edit:broadcast", "View and edit a user’s broadcasting configuration, including Extension configurations.")
static var USER_READ_BLOCKED_USERS = Definition.new(&"user:read:blocked_users", "View the block list of a user.")
static var USER_MANAGE_BLOCKED_USERS = Definition.new(&"user:manage:blocked_users", "Manage the block list of a user.")
static var USER_READ_BROADCAST = Definition.new(&"user:read:broadcast", "View a user’s broadcasting configuration, including Extension configurations.")
static var USER_READ_CHAT = Definition.new(&"user:read:chat", "Receive chatroom messages and informational notifications relating to a channel’s chatroom.")
static var USER_MANAGE_CHAT_COLOR = Definition.new(&"user:manage:chat_color", "Update the color used for the user’s name in chat.")
static var USER_READ_EMAIL = Definition.new(&"user:read:email", "View a user’s email address.")
static var USER_READ_EMOTES = Definition.new(&"user:read:emotes", "View emotes available to a user")
static var USER_READ_FOLLOWS = Definition.new(&"user:read:follows", "View the list of channels a user follows.")
static var USER_READ_MODERATED_CHANNELS = Definition.new(&"user:read:moderated_channels", "Read the list of channels you have moderator privileges in.")
static var USER_READ_SUBSCRIPTIONS = Definition.new(&"user:read:subscriptions", "View if an authorized user is subscribed to specific channels.")
static var USER_READ_WHISPERS = Definition.new(&"user:read:whispers", "Receive whispers sent to your user.")
static var USER_MANAGE_WHISPERS = Definition.new(&"user:manage:whispers", "Receive whispers sent to your user, and send whispers on your user’s behalf.")
static var USER_WRITE_CHAT = Definition.new(&"user:write:chat", "Send chat messages to a chatroom.")
static var CHAT_READ = Definition.new(&"chat:edit", "Send chat messages to a chatroom using an IRC connection.");
static var CHAT_EDIT = Definition.new(&"chat:read", "View chat messages sent in a chatroom using an IRC connection.");

## Key: Scope Name as String | Value: Definition
static var SCOPE_MAP: Dictionary = {
	"analytics:read:extensions" =	ANALYTICS_READ_EXTENSIONS,
	"analytics:read:games" = ANALYTICS_READ_GAMES,
	"bits:read" = BITS_READ,
	"channel:bot" = CHANNEL_BOT,
	"channel:manage:ads" = CHANNEL_MANAGE_ADS,
	"channel:read:ads" = CHANNEL_READ_ADS,
	"channel:manage:broadcast" = CHANNEL_MANAGE_BROADCAST,
	"channel:read:charity" = CHANNEL_READ_CHARITY,
	"channel:edit:commercial" = CHANNEL_EDIT_COMMERCIAL,
	"channel:read:editors" = CHANNEL_READ_EDITORS,
	"channel:manage:extensions" = CHANNEL_MANAGE_EXTENSIONS,
	"channel:read:goals" = CHANNEL_READ_GOALS,
	"channel:read:guest_star" = CHANNEL_READ_GUEST_STAR,
	"channel:manage:guest_star" = CHANNEL_MANAGE_GUEST_STAR,
	"channel:read:hype_train" = CHANNEL_READ_HYPE_TRAIN,
	"channel:manage:moderators" = CHANNEL_MANAGE_MODERATORS,
	"channel:read:polls" = CHANNEL_READ_POLLS,
	"channel:manage:polls" = CHANNEL_MANAGE_POLLS,
	"channel:read:predictions" = CHANNEL_READ_PREDICTIONS,
	"channel:manage:predictions" = CHANNEL_MANAGE_PREDICTIONS,
	"channel:manage:raids" = CHANNEL_MANAGE_RAIDS,
	"channel:read:redemptions" = CHANNEL_READ_REDEMPTIONS,
	"channel:manage:redemptions" = CHANNEL_MANAGE_REDEMPTIONS,
	"channel:manage:schedule" = CHANNEL_MANAGE_SCHEDULE,
	"channel:read:stream_key" = CHANNEL_READ_STREAM_KEY,
	"channel:read:subscriptions" = CHANNEL_READ_SUBSCRIPTIONS,
	"channel:manage:videos" = CHANNEL_MANAGE_VIDEOS,
	"channel:read:vips" = CHANNEL_READ_VIPS,
	"channel:manage:vips" = CHANNEL_MANAGE_VIPS,
	"clips:edit" = CLIPS_EDIT,
	"moderation:read" = MODERATION_READ,
	"moderator:manage:announcements" = MODERATOR_MANAGE_ANNOUNCEMENTS,
	"moderator:manage:automod" = MODERATOR_MANAGE_AUTOMOD,
	"moderator:read:automod_settings" = MODERATOR_READ_AUTOMOD_SETTINGS,
	"moderator:manage:automod_settings" = MODERATOR_MANAGE_AUTOMOD_SETTINGS,
	"moderator:read:banned_users" = MODERATOR_READ_BANNED_USERS,
	"moderator:manage:banned_users" = MODERATOR_MANAGE_BANNED_USERS,
	"moderator:read:blocked_terms" = MODERATOR_READ_BLOCKED_TERMS,
	"moderator:read:chat_messages" = MODERATOR_READ_CHAT_MESSAGES,
	"moderator:manage:blocked_terms" = MODERATOR_MANAGE_BLOCKED_TERMS,
	"moderator:manage:chat_messages" = MODERATOR_MANAGE_CHAT_MESSAGES,
	"moderator:read:chat_settings" = MODERATOR_READ_CHAT_SETTINGS,
	"moderator:manage:chat_settings" = MODERATOR_MANAGE_CHAT_SETTINGS,
	"moderator:read:chatters" = MODERATOR_READ_CHATTERS,
	"moderator:read:followers" = MODERATOR_READ_FOLLOWERS,
	"moderator:read:guest_star" = MODERATOR_READ_GUEST_STAR,
	"moderator:manage:guest_star" = MODERATOR_MANAGE_GUEST_STAR,
	"moderator:read:moderators" = MODERATOR_READ_MODERATORS,
	"moderator:read:shield_mode" = MODERATOR_READ_SHIELD_MODE,
	"moderator:manage:shield_mode" = MODERATOR_MANAGE_SHIELD_MODE,
	"moderator:read:shoutouts" = MODERATOR_READ_SHOUTOUTS,
	"moderator:manage:shoutouts" = MODERATOR_MANAGE_SHOUTOUTS,
	"moderator:read:suspicious_users" = MODERATOR_READ_SUSPICIOUS_USERS,
	"moderator:read:unban_requests" = MODERATOR_READ_UNBAN_REQUESTS,
	"moderator:manage:unban_requests" = MODERATOR_MANAGE_UNBAN_REQUESTS,
	"moderator:read:vips" = MODERATOR_READ_VIPS,
	"moderator:read:warnings" = MODERATOR_READ_WARNINGS,
	"moderator:manage:warnings" = MODERATOR_MANAGE_WARNINGS,
	"user:bot" = USER_BOT,
	"user:edit" = USER_EDIT,
	"user:edit:broadcast" = USER_EDIT_BROADCAST,
	"user:read:blocked_users" = USER_READ_BLOCKED_USERS,
	"user:manage:blocked_users" = USER_MANAGE_BLOCKED_USERS,
	"user:read:broadcast" = USER_READ_BROADCAST,
	"user:read:chat" = USER_READ_CHAT,
	"user:manage:chat_color" = USER_MANAGE_CHAT_COLOR,
	"user:read:email" = USER_READ_EMAIL,
	"user:read:emotes" = USER_READ_EMOTES,
	"user:read:follows" = USER_READ_FOLLOWS,
	"user:read:moderated_channels" = USER_READ_MODERATED_CHANNELS,
	"user:read:subscriptions" = USER_READ_SUBSCRIPTIONS,
	"user:read:whispers" = USER_READ_WHISPERS,
	"user:manage:whispers" = USER_MANAGE_WHISPERS,
	"user:write:chat" = USER_WRITE_CHAT,
	"chat:read" = CHAT_READ,
	"chat:edit" = CHAT_EDIT,
};


## Key: Category as String, value as Array[Definition]
static func get_grouped_scopes() -> Dictionary:
	var result = {}
	for scope: Definition in get_all_scopes():
		var category_name = scope.get_category();
		var category = result.get_or_add(category_name, []);
		category.append(scope);
	return result;


static func get_all_scopes() -> Array[Definition]:
	var scopes: Array[Definition] = [];
	for scope in SCOPE_MAP.values():
		scopes.append(scope);
	return scopes;
