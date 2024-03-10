@tool
extends Object

class_name TwitchSubscriptions

## All supported subscriptions should be used in comination with get_all method as index.
enum Subscriptions {
	CHANNEL_UPDATE,
	CHANNEL_FOLLOW,
	CHANNEL_AD_BREAK_BEGIN,
	CHANNEL_CHAT_CLEAR,
	CHANNEL_CHAT_CLEAR_USER_MESSAGES,
	CHANNEL_CHAT_MESSAGE,
	CHANNEL_CHAT_MESSAGE_DELETE,
	CHANNEL_CHAT_NOTIFICATION,
	CHANNEL_CHAT_SETTINGS_UPDATE,
	CHANNEL_SUBSCRIBE,
	CHANNEL_SUBSCRIPTION_END,
	CHANNEL_SUBSCRIPTION_GIFT,
	CHANNEL_SUBSCRIPTION_MESSAGE,
	CHANNEL_CHEER,
	CHANNEL_RAID,
	CHANNEL_BAN,
	CHANNEL_UNBAN,
	CHANNEL_MODERATOR_ADD,
	CHANNEL_MODERATOR_REMOVE,
	CHANNEL_GUEST_STAR_SESSION_BEGIN,
	CHANNEL_GUEST_STAR_SESSION_END,
	CHANNEL_GUEST_STAR_GUEST_UPDATE,
	CHANNEL_GUEST_STAR_SETTINGS_UPDATE,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE,
	CHANNEL_POLL_BEGIN,
	CHANNEL_POLL_PROGRESS,
	CHANNEL_POLL_END,
	CHANNEL_PREDICTION_BEGIN,
	CHANNEL_PREDICTION_PROGRESS,
	CHANNEL_PREDICTION_LOCK,
	CHANNEL_PREDICTION_END,
	CHANNEL_HYPE_TRAIN_BEGIN,
	CHANNEL_HYPE_TRAIN_PROGRESS,
	CHANNEL_HYPE_TRAIN_END,
	CHANNEL_CHARITY_CAMPAIGN_DONATE,
	CHANNEL_CHARITY_CAMPAIGN_START,
	CHANNEL_CHARITY_CAMPAIGN_PROGRESS,
	CHANNEL_CHARITY_CAMPAIGN_STOP,
	CHANNEL_SHIELD_MODE_BEGIN,
	CHANNEL_SHIELD_MODE_END,
	CHANNEL_SHOUTOUT_CREATE,
	CHANNEL_SHOUTOUT_RECEIVE,
	CONDUIT_SHARD_DISABLED,
	DROP_ENTITLEMENT_GRANT,
	EXTENSION_BITS_TRANSACTION_CREATE,
	CHANNEL_GOAL_BEGIN,
	CHANNEL_GOAL_PROGRESS,
	CHANNEL_GOAL_END,
	STREAM_ONLINE,
	STREAM_OFFLINE,
	USER_AUTHORIZATION_GRANT,
	USER_AUTHORIZATION_REVOKE,
	USER_UPDATE
}

## Definition of a subscription.
class Subscription extends RefCounted:
	var value: String;
	var version: String;
	var conditions: Array[String];

	func _init(val: String, ver: String, cond: Array[String]):
		value = val;
		version = ver;
		conditions = cond;

	func get_name() -> String:
		return value.replace(".", "_");

static var CHANNEL_UPDATE = Subscription.new("channel.update", "2", ["broadcaster_user_id"]);
static var CHANNEL_FOLLOW = Subscription.new("channel.follow", "2", ["broadcaster_user_id","moderator_user_id"]);
static var CHANNEL_AD_BREAK_BEGIN = Subscription.new("channel.ad_break.begin", "1", ["broadcaster_user_id"]);
static var CHANNEL_CHAT_CLEAR = Subscription.new("channel.chat.clear", "1", ["broadcaster_user_id","user_id"]);
static var CHANNEL_CHAT_CLEAR_USER_MESSAGES = Subscription.new("channel.chat.clear_user_messages", "1", ["broadcaster_user_id","user_id"]);
static var CHANNEL_CHAT_MESSAGE = Subscription.new("channel.chat.message", "1", ["broadcaster_user_id","user_id"]);
static var CHANNEL_CHAT_MESSAGE_DELETE = Subscription.new("channel.chat.message_delete", "1", ["broadcaster_user_id","user_id"]);
static var CHANNEL_CHAT_NOTIFICATION = Subscription.new("channel.chat.notification", "1", ["broadcaster_user_id","user_id"]);
static var CHANNEL_CHAT_SETTINGS_UPDATE = Subscription.new("channel.chat_settings.update", "beta", ["broadcaster_user_id","user_id",]);
static var CHANNEL_SUBSCRIBE = Subscription.new("channel.subscribe", "1", ["broadcaster_user_id"]);
static var CHANNEL_SUBSCRIPTION_END = Subscription.new("channel.subscription.end", "1", ["broadcaster_user_id"]);
static var CHANNEL_SUBSCRIPTION_GIFT = Subscription.new("channel.subscription.gift", "1", ["broadcaster_user_id"]);
static var CHANNEL_SUBSCRIPTION_MESSAGE = Subscription.new("channel.subscription.message", "1", ["broadcaster_user_id"]);
static var CHANNEL_CHEER = Subscription.new("channel.cheer", "1", ["broadcaster_user_id"]);
static var CHANNEL_RAID = Subscription.new("channel.raid", "1", ["to_broadcaster_user_id"]);
static var CHANNEL_BAN = Subscription.new("channel.ban", "1", ["broadcaster_user_id"]);
static var CHANNEL_UNBAN = Subscription.new("channel.unban", "1", ["broadcaster_user_id"]);
static var CHANNEL_MODERATOR_ADD = Subscription.new("channel.moderator.add", "1", ["broadcaster_user_id"]);
static var CHANNEL_MODERATOR_REMOVE = Subscription.new("channel.moderator.remove", "1", ["broadcaster_user_id"]);
static var CHANNEL_GUEST_STAR_SESSION_BEGIN = Subscription.new("channel.guest_star_session.begin", "beta", ["broadcaster_user_id","moderator_user_id"]);
static var CHANNEL_GUEST_STAR_SESSION_END = Subscription.new("channel.guest_star_session.end", "beta", ["broadcaster_user_id","moderator_user_id"]);
static var CHANNEL_GUEST_STAR_GUEST_UPDATE = Subscription.new("channel.guest_star_guest.update", "beta", ["broadcaster_user_id","moderator_user_id"]);
static var CHANNEL_GUEST_STAR_SETTINGS_UPDATE = Subscription.new("channel.guest_star_settings.update", "beta", ["broadcaster_user_id","moderator_user_id"]);
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD = Subscription.new("channel.channel_points_custom_reward.add", "1", ["broadcaster_user_id"]);
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE = Subscription.new("channel.channel_points_custom_reward.update", "1", ["broadcaster_user_id","reward_id"]);
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE = Subscription.new("channel.channel_points_custom_reward.remove", "1", ["broadcaster_user_id","reward_id"]);
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD = Subscription.new("channel.channel_points_custom_reward_redemption.add", "1", ["broadcaster_user_id","reward_id"]);
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE = Subscription.new("channel.channel_points_custom_reward_redemption.update", "1", ["broadcaster_user_id","reward_id"]);
static var CHANNEL_POLL_BEGIN = Subscription.new("channel.poll.begin", "1", ["broadcaster_user_id"]);
static var CHANNEL_POLL_PROGRESS = Subscription.new("channel.poll.progress", "1", ["broadcaster_user_id"]);
static var CHANNEL_POLL_END = Subscription.new("channel.poll.end", "1", ["broadcaster_user_id"]);
static var CHANNEL_PREDICTION_BEGIN = Subscription.new("channel.prediction.begin", "1", ["broadcaster_user_id"]);
static var CHANNEL_PREDICTION_PROGRESS = Subscription.new("channel.prediction.progress", "1", ["broadcaster_user_id"]);
static var CHANNEL_PREDICTION_LOCK = Subscription.new("channel.prediction.lock", "1", ["broadcaster_user_id"]);
static var CHANNEL_PREDICTION_END = Subscription.new("channel.prediction.end", "1", ["broadcaster_user_id"]);
static var CHANNEL_HYPE_TRAIN_BEGIN = Subscription.new("channel.hype_train.begin", "1", ["broadcaster_user_id"]);
static var CHANNEL_HYPE_TRAIN_PROGRESS = Subscription.new("channel.hype_train.progress", "1", ["broadcaster_user_id"]);
static var CHANNEL_HYPE_TRAIN_END = Subscription.new("channel.hype_train.end", "1", ["broadcaster_user_id"]);
static var CHANNEL_CHARITY_CAMPAIGN_DONATE = Subscription.new("channel.charity_campaign.donate", "1", ["broadcaster_user_id"]);
static var CHANNEL_CHARITY_CAMPAIGN_START = Subscription.new("channel.charity_campaign.start", "1", ["broadcaster_user_id"]);
static var CHANNEL_CHARITY_CAMPAIGN_PROGRESS = Subscription.new("channel.charity_campaign.progress", "1", ["broadcaster_user_id"]);
static var CHANNEL_CHARITY_CAMPAIGN_STOP = Subscription.new("channel.charity_campaign.stop", "1", ["broadcaster_user_id"]);
static var CHANNEL_SHIELD_MODE_BEGIN = Subscription.new("channel.shield_mode.begin", "1", ["broadcaster_user_id","moderator_user_id"]);
static var CHANNEL_SHIELD_MODE_END = Subscription.new("channel.shield_mode.end", "1", ["broadcaster_user_id","moderator_user_id"]);
static var CHANNEL_SHOUTOUT_CREATE = Subscription.new("channel.shoutout.create", "1", ["broadcaster_user_id","moderator_user_id"]);
static var CHANNEL_SHOUTOUT_RECEIVE = Subscription.new("channel.shoutout.receive", "1", ["broadcaster_user_id","moderator_user_id"]);
static var CONDUIT_SHARD_DISABLED = Subscription.new("conduit.shard.disabled", "beta", ["client_id"]);
static var DROP_ENTITLEMENT_GRANT = Subscription.new("drop.entitlement.grant", "1", ["organization_id","category_id","campaign_id"]);
static var EXTENSION_BITS_TRANSACTION_CREATE = Subscription.new("extension.bits_transaction.create", "1", ["extension_client_id"]);
static var CHANNEL_GOAL_BEGIN = Subscription.new("channel.goal.begin", "1", ["broadcaster_user_id"]);
static var CHANNEL_GOAL_PROGRESS = Subscription.new("channel.goal.progress", "1", ["broadcaster_user_id"]);
static var CHANNEL_GOAL_END = Subscription.new("channel.goal.end", "1", ["broadcaster_user_id"]);
static var STREAM_ONLINE = Subscription.new("stream.online", "1", ["broadcaster_user_id"]);
static var STREAM_OFFLINE = Subscription.new("stream.offline", "1", ["broadcaster_user_id"]);
static var USER_AUTHORIZATION_GRANT = Subscription.new("user.authorization.grant", "1", ["client_id"]);
static var USER_AUTHORIZATION_REVOKE = Subscription.new("user.authorization.revoke", "1", ["client_id"]);
static var USER_UPDATE = Subscription.new("user.update", "1", ["user_id"]);

## Returns all supported subscriptions
static func get_all() -> Array[Subscription]:
	return [
		CHANNEL_UPDATE,
		CHANNEL_FOLLOW,
		CHANNEL_AD_BREAK_BEGIN,
		CHANNEL_CHAT_CLEAR,
		CHANNEL_CHAT_CLEAR_USER_MESSAGES,
		CHANNEL_CHAT_MESSAGE,
		CHANNEL_CHAT_MESSAGE_DELETE,
		CHANNEL_CHAT_NOTIFICATION,
		CHANNEL_CHAT_SETTINGS_UPDATE,
		CHANNEL_SUBSCRIBE,
		CHANNEL_SUBSCRIPTION_END,
		CHANNEL_SUBSCRIPTION_GIFT,
		CHANNEL_SUBSCRIPTION_MESSAGE,
		CHANNEL_CHEER,
		CHANNEL_RAID,
		CHANNEL_BAN,
		CHANNEL_UNBAN,
		CHANNEL_MODERATOR_ADD,
		CHANNEL_MODERATOR_REMOVE,
		CHANNEL_GUEST_STAR_SESSION_BEGIN,
		CHANNEL_GUEST_STAR_SESSION_END,
		CHANNEL_GUEST_STAR_GUEST_UPDATE,
		CHANNEL_GUEST_STAR_SETTINGS_UPDATE,
		CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD,
		CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE,
		CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE,
		CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD,
		CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE,
		CHANNEL_POLL_BEGIN,
		CHANNEL_POLL_PROGRESS,
		CHANNEL_POLL_END,
		CHANNEL_PREDICTION_BEGIN,
		CHANNEL_PREDICTION_PROGRESS,
		CHANNEL_PREDICTION_LOCK,
		CHANNEL_PREDICTION_END,
		CHANNEL_HYPE_TRAIN_BEGIN,
		CHANNEL_HYPE_TRAIN_PROGRESS,
		CHANNEL_HYPE_TRAIN_END,
		CHANNEL_CHARITY_CAMPAIGN_DONATE,
		CHANNEL_CHARITY_CAMPAIGN_START,
		CHANNEL_CHARITY_CAMPAIGN_PROGRESS,
		CHANNEL_CHARITY_CAMPAIGN_STOP,
		CHANNEL_SHIELD_MODE_BEGIN,
		CHANNEL_SHIELD_MODE_END,
		CHANNEL_SHOUTOUT_CREATE,
		CHANNEL_SHOUTOUT_RECEIVE,
		CONDUIT_SHARD_DISABLED,
		DROP_ENTITLEMENT_GRANT,
		EXTENSION_BITS_TRANSACTION_CREATE,
		CHANNEL_GOAL_BEGIN,
		CHANNEL_GOAL_PROGRESS,
		CHANNEL_GOAL_END,
		STREAM_ONLINE,
		STREAM_OFFLINE,
		USER_AUTHORIZATION_GRANT,
		USER_AUTHORIZATION_REVOKE,
		USER_UPDATE,
	]
