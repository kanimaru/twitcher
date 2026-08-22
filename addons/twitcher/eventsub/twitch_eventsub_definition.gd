@tool
extends Object

class_name TwitchEventsubDefinition

## All supported subscriptions should be used in comination with get_all method as index.
enum Type {
	AUTOMOD_MESSAGE_HOLD,
	AUTOMOD_MESSAGE_HOLD_V2,
	AUTOMOD_MESSAGE_UPDATE,
	AUTOMOD_MESSAGE_UPDATE_V2,
	AUTOMOD_SETTINGS_UPDATE,
	AUTOMOD_TERMS_UPDATE,
	CHANNEL_BITS_USE,
	CHANNEL_UPDATE,
	CHANNEL_FOLLOW,
	CHANNEL_AD_BREAK_BEGIN,
	CHANNEL_CHAT_CLEAR,
	CHANNEL_CHAT_CLEAR_USER_MESSAGES,
	CHANNEL_CHAT_MESSAGE,
	CHANNEL_CHAT_MESSAGE_DELETE,
	CHANNEL_CHAT_NOTIFICATION,
	CHANNEL_CHAT_SETTINGS_UPDATE,
	CHANNEL_CHAT_USER_MESSAGE_HOLD,
	CHANNEL_CHAT_USER_MESSAGE_UPDATE,
	CHANNEL_SUBSCRIBE,
	CHANNEL_SUBSCRIPTION_END,
	CHANNEL_SUBSCRIPTION_GIFT,
	CHANNEL_SUBSCRIPTION_MESSAGE,
	CHANNEL_CHEER,
	CHANNEL_RAID,
	CHANNEL_BAN,
	CHANNEL_UNBAN,
	CHANNEL_UNBAN_REQUEST_CREATE,
	CHANNEL_UNBAN_REQUEST_RESOLVE,
	CHANNEL_MODERATE,
	CHANNEL_MODERATE_V2,
	CHANNEL_MODERATOR_ADD,
	CHANNEL_MODERATOR_REMOVE,
	CHANNEL_GUEST_STAR_SESSION_BEGIN,
	CHANNEL_GUEST_STAR_SESSION_END,
	CHANNEL_GUEST_STAR_GUEST_UPDATE,
	CHANNEL_GUEST_STAR_SETTINGS_UPDATE,
	CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD,
	CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD_V2,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE,
	CHANNEL_CUSTOM_POWER_UP_REDEMPTION_ADD,
	CHANNEL_POLL_BEGIN,
	CHANNEL_POLL_PROGRESS,
	CHANNEL_POLL_END,
	CHANNEL_PREDICTION_BEGIN,
	CHANNEL_PREDICTION_PROGRESS,
	CHANNEL_PREDICTION_LOCK,
	CHANNEL_PREDICTION_END,
	CHANNEL_SUSPICIOUS_USER_UPDATE,
	CHANNEL_SUSPICIOUS_USER_MESSAGE,
	CHANNEL_VIP_ADD,
	CHANNEL_VIP_REMOVE,
	CHANNEL_WARNING_ACKNOWLEDGE,
	CHANNEL_WARNING_SEND,
	CHANNEL_HYPE_TRAIN_BEGIN,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_hype_train_begin". Use CHANNEL_HYPE_TRAIN_BEGIN instead.
	CHANNEL_HYPE_TRAIN_BEGIN_LEGACY,
	CHANNEL_HYPE_TRAIN_PROGRESS,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_hype_train_progress". Use CHANNEL_HYPE_TRAIN_PROGRESS instead.
	CHANNEL_HYPE_TRAIN_PROGRESS_LEGACY,
	CHANNEL_HYPE_TRAIN_END,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_hype_train_end". Use CHANNEL_HYPE_TRAIN_END instead.
	CHANNEL_HYPE_TRAIN_END_LEGACY,
	CHANNEL_CHARITY_CAMPAIGN_DONATE,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_charity_campaign_donate". Use CHANNEL_CHARITY_CAMPAIGN_DONATE instead.
	CHANNEL_CHARITY_CAMPAIGN_DONATE_LEGACY,
	CHANNEL_CHARITY_CAMPAIGN_START,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_charity_campaign_start". Use CHANNEL_CHARITY_CAMPAIGN_START instead.
	CHANNEL_CHARITY_CAMPAIGN_START_LEGACY,
	CHANNEL_CHARITY_CAMPAIGN_PROGRESS,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_charity_campaign_progress". Use CHANNEL_CHARITY_CAMPAIGN_PROGRESS instead.
	CHANNEL_CHARITY_CAMPAIGN_PROGRESS_LEGACY,
	CHANNEL_CHARITY_CAMPAIGN_STOP,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_charity_campaign_stop". Use CHANNEL_CHARITY_CAMPAIGN_STOP instead.
	CHANNEL_CHARITY_CAMPAIGN_STOP_LEGACY,
	CHANNEL_SHARED_CHAT_BEGIN,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shared_chat_begin". Use CHANNEL_SHARED_CHAT_BEGIN instead.
	CHANNEL_SHARED_CHAT_BEGIN_LEGACY,
	CHANNEL_SHARED_CHAT_UPDATE,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shared_chat_update". Use CHANNEL_SHARED_CHAT_UPDATE instead.
	CHANNEL_SHARED_CHAT_UPDATE_LEGACY,
	CHANNEL_SHARED_CHAT_END,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shared_chat_end". Use CHANNEL_SHARED_CHAT_END instead.
	CHANNEL_SHARED_CHAT_END_LEGACY,
	CHANNEL_SHIELD_MODE_BEGIN,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shield_mode_begin". Use CHANNEL_SHIELD_MODE_BEGIN instead.
	CHANNEL_SHIELD_MODE_BEGIN_LEGACY,
	CHANNEL_SHIELD_MODE_END,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shield_mode_end". Use CHANNEL_SHIELD_MODE_END instead.
	CHANNEL_SHIELD_MODE_END_LEGACY,
	CHANNEL_SHOUTOUT_CREATE,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shoutout_create". Use CHANNEL_SHOUTOUT_CREATE instead.
	CHANNEL_SHOUTOUT_CREATE_LEGACY,
	CHANNEL_SHOUTOUT_RECEIVE,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shoutout_receive". Use CHANNEL_SHOUTOUT_RECEIVE instead.
	CHANNEL_SHOUTOUT_RECEIVE_LEGACY,
	CONDUIT_SHARD_DISABLED,
	DROP_ENTITLEMENT_GRANT,
	EXTENSION_BITS_TRANSACTION_CREATE,
	CHANNEL_GOAL_BEGIN,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_goal_begin". Use CHANNEL_GOAL_BEGIN instead.
	CHANNEL_GOAL_BEGIN_LEGACY,
	CHANNEL_GOAL_PROGRESS,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_goal_progress". Use CHANNEL_GOAL_PROGRESS instead.
	CHANNEL_GOAL_PROGRESS_LEGACY,
	CHANNEL_GOAL_END,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_goal_end". Use CHANNEL_GOAL_END instead.
	CHANNEL_GOAL_END_LEGACY,
	STREAM_ONLINE,
	STREAM_OFFLINE,
	USER_AUTHORIZATION_GRANT,
	USER_AUTHORIZATION_REVOKE,
	USER_UPDATE,
	USER_WHISPER_MESSAGE,
	## @deprecated: Kept for backwards compatibility - points at the pre-override script name "user_whisper_message". Use USER_WHISPER_MESSAGE instead.
	USER_WHISPER_MESSAGE_LEGACY,
}

## The type of itself
var type: Type
## Name within Twitch
var value: StringName
## Version defined in Twitch
var version: StringName
## Keys of the conditions it need for setup
var conditions: Array[StringName]
## Possible scopes it needs (on some of them its more then needed)
var scopes: Array[StringName]
## Link to the twitch documentation
var documentation_link: String
## The actual script that represents the return value
var response_script: Script


func _init(typ: Type, val: StringName, ver: StringName, cond: Array[StringName], scps: Array[StringName], doc_link: String, script_name: String):
	type = typ
	value = val
	version = ver
	conditions = cond
	scopes = scps
	documentation_link = doc_link
	response_script = load("res://addons/twitcher/generated_eventsub/twitch_es_%s.gd" % script_name)

## Get a human readable name of it
func get_readable_name() -> String:
	return "%s (v%s)" % [value, version]


static var AUTOMOD_MESSAGE_HOLD := TwitchEventsubDefinition.new(Type.AUTOMOD_MESSAGE_HOLD, &"automod.message.hold", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:automod"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessagehold", "automod_message_hold")
static var AUTOMOD_MESSAGE_HOLD_V2 := TwitchEventsubDefinition.new(Type.AUTOMOD_MESSAGE_HOLD_V2, &"automod.message.hold", &"2", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:automod"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessagehold-v2", "automod_message_hold")
static var AUTOMOD_MESSAGE_UPDATE := TwitchEventsubDefinition.new(Type.AUTOMOD_MESSAGE_UPDATE, &"automod.message.update", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:automod"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessageupdate", "automod_message_update")
static var AUTOMOD_MESSAGE_UPDATE_V2 := TwitchEventsubDefinition.new(Type.AUTOMOD_MESSAGE_UPDATE_V2, &"automod.message.update", &"2", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:automod"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessageupdate-v2", "automod_message_update")
static var AUTOMOD_SETTINGS_UPDATE := TwitchEventsubDefinition.new(Type.AUTOMOD_SETTINGS_UPDATE, &"automod.settings.update", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:automod_settings"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodsettingsupdate", "automod_settings_update")
static var AUTOMOD_TERMS_UPDATE := TwitchEventsubDefinition.new(Type.AUTOMOD_TERMS_UPDATE, &"automod.terms.update", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:automod"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodtermsupdate", "automod_terms_update")
static var CHANNEL_BITS_USE := TwitchEventsubDefinition.new(Type.CHANNEL_BITS_USE, &"channel.bits.use", &"1", [&"broadcaster_user_id"], [&"bits:read"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelbitsuse", "channel_bits_use")
static var CHANNEL_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_UPDATE, &"channel.update", &"2", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelupdate", "channel_update")
static var CHANNEL_FOLLOW := TwitchEventsubDefinition.new(Type.CHANNEL_FOLLOW, &"channel.follow", &"2", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:followers"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelfollow", "channel_follow")
static var CHANNEL_AD_BREAK_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_AD_BREAK_BEGIN, &"channel.ad_break.begin", &"1", [&"broadcaster_user_id"], [&"channel:read:ads"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelad_breakbegin", "channel_ad_break_begin")
static var CHANNEL_CHAT_CLEAR := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_CLEAR, &"channel.chat.clear", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:read:chat",&"user:bot",&"channel:bot"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatclear", "channel_chat_clear")
static var CHANNEL_CHAT_CLEAR_USER_MESSAGES := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_CLEAR_USER_MESSAGES, &"channel.chat.clear_user_messages", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:read:chat",&"user:bot",&"channel:bot"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatclear_user_messages", "channel_chat_clear_user_messages")
static var CHANNEL_CHAT_MESSAGE := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_MESSAGE, &"channel.chat.message", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:read:chat",&"user:bot",&"channel:bot"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatmessage", "channel_chat_message")
static var CHANNEL_CHAT_MESSAGE_DELETE := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_MESSAGE_DELETE, &"channel.chat.message_delete", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:read:chat",&"user:bot",&"channel:bot"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatmessage_delete", "channel_chat_message_delete")
static var CHANNEL_CHAT_NOTIFICATION := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_NOTIFICATION, &"channel.chat.notification", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:read:chat",&"user:bot",&"channel:bot"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatnotification", "channel_chat_notification")
static var CHANNEL_CHAT_SETTINGS_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_SETTINGS_UPDATE, &"channel.chat_settings.update", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:read:chat",&"user:bot",&"channel:bot"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchat_settingsupdate", "channel_chat_settings_update")
static var CHANNEL_CHAT_USER_MESSAGE_HOLD := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_USER_MESSAGE_HOLD, &"channel.chat.user_message_hold", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:read:chat",&"user:bot"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatuser_message_hold", "channel_chat_user_message_hold")
static var CHANNEL_CHAT_USER_MESSAGE_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_USER_MESSAGE_UPDATE, &"channel.chat.user_message_update", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:read:chat",&"user:bot"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatuser_message_update", "channel_chat_user_message_update")
static var CHANNEL_SUBSCRIBE := TwitchEventsubDefinition.new(Type.CHANNEL_SUBSCRIBE, &"channel.subscribe", &"1", [&"broadcaster_user_id"], [&"channel:read:subscriptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscribe", "channel_subscribe")
static var CHANNEL_SUBSCRIPTION_END := TwitchEventsubDefinition.new(Type.CHANNEL_SUBSCRIPTION_END, &"channel.subscription.end", &"1", [&"broadcaster_user_id"], [&"channel:read:subscriptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptionend", "channel_subscription_end")
static var CHANNEL_SUBSCRIPTION_GIFT := TwitchEventsubDefinition.new(Type.CHANNEL_SUBSCRIPTION_GIFT, &"channel.subscription.gift", &"1", [&"broadcaster_user_id"], [&"channel:read:subscriptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptiongift", "channel_subscription_gift")
static var CHANNEL_SUBSCRIPTION_MESSAGE := TwitchEventsubDefinition.new(Type.CHANNEL_SUBSCRIPTION_MESSAGE, &"channel.subscription.message", &"1", [&"broadcaster_user_id"], [&"channel:read:subscriptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptionmessage", "channel_subscription_message")
static var CHANNEL_CHEER := TwitchEventsubDefinition.new(Type.CHANNEL_CHEER, &"channel.cheer", &"1", [&"broadcaster_user_id"], [&"bits:read"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcheer", "channel_cheer")
static var CHANNEL_RAID := TwitchEventsubDefinition.new(Type.CHANNEL_RAID, &"channel.raid", &"1", [&"from_broadcaster_user_id",&"to_broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelraid", "channel_raid")
static var CHANNEL_BAN := TwitchEventsubDefinition.new(Type.CHANNEL_BAN, &"channel.ban", &"1", [&"broadcaster_user_id"], [&"channel:moderate"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelban", "channel_ban")
static var CHANNEL_UNBAN := TwitchEventsubDefinition.new(Type.CHANNEL_UNBAN, &"channel.unban", &"1", [&"broadcaster_user_id"], [&"channel:moderate"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban", "channel_unban")
static var CHANNEL_UNBAN_REQUEST_CREATE := TwitchEventsubDefinition.new(Type.CHANNEL_UNBAN_REQUEST_CREATE, &"channel.unban_request.create", &"1", [&"moderator_user_id",&"broadcaster_user_id"], [&"moderator:read:unban_requests",&"moderator:manage:unban_requests"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban_requestcreate", "channel_unban_request_create")
static var CHANNEL_UNBAN_REQUEST_RESOLVE := TwitchEventsubDefinition.new(Type.CHANNEL_UNBAN_REQUEST_RESOLVE, &"channel.unban_request.resolve", &"1", [&"moderator_user_id",&"broadcaster_user_id"], [&"moderator:read:unban_requests",&"moderator:manage:unban_requests"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban_requestresolve", "channel_unban_request_resolve")
static var CHANNEL_MODERATE := TwitchEventsubDefinition.new(Type.CHANNEL_MODERATE, &"channel.moderate", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:blocked_terms",&"moderator:manage:blocked_terms",&"moderator:read:chat_settings",&"moderator:manage:chat_settings",&"moderator:read:unban_requests",&"moderator:manage:unban_requests",&"moderator:read:banned_users",&"moderator:manage:banned_users",&"moderator:read:chat_messages",&"moderator:manage:chat_messages",&"moderator:read:moderators",&"moderator:read:vips"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderate", "channel_moderate")
static var CHANNEL_MODERATE_V2 := TwitchEventsubDefinition.new(Type.CHANNEL_MODERATE_V2, &"channel.moderate", &"2", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:blocked_terms",&"moderator:manage:blocked_terms",&"moderator:read:chat_settings",&"moderator:manage:chat_settings",&"moderator:read:unban_requests",&"moderator:manage:unban_requests",&"moderator:read:banned_users",&"moderator:manage:banned_users",&"moderator:read:chat_messages",&"moderator:manage:chat_messages",&"moderator:read:warnings",&"moderator:manage:warnings",&"moderator:read:moderators",&"moderator:read:vips"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderate-v2", "channel_moderate")
static var CHANNEL_MODERATOR_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_MODERATOR_ADD, &"channel.moderator.add", &"1", [&"broadcaster_user_id"], [&"moderation:read"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderatoradd", "channel_moderator_add")
static var CHANNEL_MODERATOR_REMOVE := TwitchEventsubDefinition.new(Type.CHANNEL_MODERATOR_REMOVE, &"channel.moderator.remove", &"1", [&"broadcaster_user_id"], [&"moderation:read"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderatorremove", "channel_moderator_remove")
static var CHANNEL_GUEST_STAR_SESSION_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_GUEST_STAR_SESSION_BEGIN, &"channel.guest_star_session.begin", &"beta", [&"broadcaster_user_id",&"moderator_user_id"], [&"channel:read:guest_star",&"channel:manage:guest_star",&"moderator:read:guest_star",&"moderator:manage:guest_star"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_sessionbegin", "channel_guest_star_session_begin")
static var CHANNEL_GUEST_STAR_SESSION_END := TwitchEventsubDefinition.new(Type.CHANNEL_GUEST_STAR_SESSION_END, &"channel.guest_star_session.end", &"beta", [&"broadcaster_user_id",&"moderator_user_id"], [&"channel:read:guest_star",&"channel:manage:guest_star",&"moderator:read:guest_star",&"moderator:manage:guest_star"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_sessionend", "channel_guest_star_session_end")
static var CHANNEL_GUEST_STAR_GUEST_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_GUEST_STAR_GUEST_UPDATE, &"channel.guest_star_guest.update", &"beta", [&"broadcaster_user_id",&"moderator_user_id"], [&"channel:read:guest_star",&"channel:manage:guest_star",&"moderator:read:guest_star",&"moderator:manage:guest_star"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_guestupdate", "channel_guest_star_guest_update")
static var CHANNEL_GUEST_STAR_SETTINGS_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_GUEST_STAR_SETTINGS_UPDATE, &"channel.guest_star_settings.update", &"beta", [&"broadcaster_user_id",&"moderator_user_id"], [&"channel:read:guest_star",&"channel:manage:guest_star",&"moderator:read:guest_star",&"moderator:manage:guest_star"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_settingsupdate", "channel_guest_star_settings_update")
static var CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD, &"channel.channel_points_automatic_reward_redemption.add", &"1", [&"broadcaster_user_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_automatic_reward_redemptionadd", "channel_points_automatic_reward_redemption_add")
static var CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD_V2 := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD_V2, &"channel.channel_points_automatic_reward_redemption.add", &"2", [&"broadcaster_user_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_automatic_reward_redemptionadd-v2", "channel_points_automatic_reward_redemption_add")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD, &"channel.channel_points_custom_reward.add", &"1", [&"broadcaster_user_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardadd", "channel_points_custom_reward_add")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE, &"channel.channel_points_custom_reward.update", &"1", [&"broadcaster_user_id",&"reward_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardupdate", "channel_points_custom_reward_update")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE, &"channel.channel_points_custom_reward.remove", &"1", [&"broadcaster_user_id",&"reward_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardremove", "channel_points_custom_reward_remove")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD, &"channel.channel_points_custom_reward_redemption.add", &"1", [&"broadcaster_user_id",&"reward_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionadd", "channel_points_custom_reward_redemption_add")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE, &"channel.channel_points_custom_reward_redemption.update", &"1", [&"broadcaster_user_id",&"reward_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionupdate", "channel_points_custom_reward_redemption_update")
static var CHANNEL_CUSTOM_POWER_UP_REDEMPTION_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_CUSTOM_POWER_UP_REDEMPTION_ADD, &"channel.custom_power_up_redemption.add", &"1", [&"broadcaster_user_id",&"reward_id"], [&"bits:read"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcustom_power_up_redemptionadd", "channel_custom_power_up_redemption_add")
static var CHANNEL_POLL_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_POLL_BEGIN, &"channel.poll.begin", &"1", [&"broadcaster_user_id"], [&"channel:read:polls",&"channel:manage:polls"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollbegin", "channel_poll_begin")
static var CHANNEL_POLL_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_POLL_PROGRESS, &"channel.poll.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:polls",&"channel:manage:polls"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollprogress", "channel_poll_progress")
static var CHANNEL_POLL_END := TwitchEventsubDefinition.new(Type.CHANNEL_POLL_END, &"channel.poll.end", &"1", [&"broadcaster_user_id"], [&"channel:read:polls",&"channel:manage:polls"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollend", "channel_poll_end")
static var CHANNEL_PREDICTION_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_PREDICTION_BEGIN, &"channel.prediction.begin", &"1", [&"broadcaster_user_id"], [&"channel:read:predictions",&"channel:manage:predictions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionbegin", "channel_prediction_begin")
static var CHANNEL_PREDICTION_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_PREDICTION_PROGRESS, &"channel.prediction.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:predictions",&"channel:manage:predictions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionprogress", "channel_prediction_progress")
static var CHANNEL_PREDICTION_LOCK := TwitchEventsubDefinition.new(Type.CHANNEL_PREDICTION_LOCK, &"channel.prediction.lock", &"1", [&"broadcaster_user_id"], [&"channel:read:predictions",&"channel:manage:predictions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionlock", "channel_prediction_lock")
static var CHANNEL_PREDICTION_END := TwitchEventsubDefinition.new(Type.CHANNEL_PREDICTION_END, &"channel.prediction.end", &"1", [&"broadcaster_user_id"], [&"channel:read:predictions",&"channel:manage:predictions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionend", "channel_prediction_end")
static var CHANNEL_SUSPICIOUS_USER_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_SUSPICIOUS_USER_UPDATE, &"channel.suspicious_user.update", &"1", [&"moderator_user_id",&"broadcaster_user_id"], [&"moderator:read:suspicious_users"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsuspicious_userupdate", "channel_suspicious_user_update")
static var CHANNEL_SUSPICIOUS_USER_MESSAGE := TwitchEventsubDefinition.new(Type.CHANNEL_SUSPICIOUS_USER_MESSAGE, &"channel.suspicious_user.message", &"1", [&"moderator_user_id",&"broadcaster_user_id"], [&"moderator:read:suspicious_users"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsuspicious_usermessage", "channel_suspicious_user_message")
static var CHANNEL_VIP_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_VIP_ADD, &"channel.vip.add", &"1", [&"broadcaster_user_id"], [&"channel:read:vips",&"channel:manage:vips"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelvipadd", "channel_vip_add")
static var CHANNEL_VIP_REMOVE := TwitchEventsubDefinition.new(Type.CHANNEL_VIP_REMOVE, &"channel.vip.remove", &"1", [&"broadcaster_user_id"], [&"channel:read:vips",&"channel:manage:vips"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelvipremove", "channel_vip_remove")
static var CHANNEL_WARNING_ACKNOWLEDGE := TwitchEventsubDefinition.new(Type.CHANNEL_WARNING_ACKNOWLEDGE, &"channel.warning.acknowledge", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:warnings",&"moderator:manage:warnings"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelwarningacknowledge", "channel_warning_acknowledge")
static var CHANNEL_WARNING_SEND := TwitchEventsubDefinition.new(Type.CHANNEL_WARNING_SEND, &"channel.warning.send", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:warnings",&"moderator:manage:warnings"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelwarningsend", "channel_warning_send")
static var CHANNEL_HYPE_TRAIN_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_BEGIN, &"channel.hype_train.begin", &"2", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainbegin", "hype_train_begin")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_hype_train_begin". Use CHANNEL_HYPE_TRAIN_BEGIN instead.
static var CHANNEL_HYPE_TRAIN_BEGIN_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_BEGIN_LEGACY, &"channel.hype_train.begin", &"2", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainbegin", "channel_hype_train_begin")
static var CHANNEL_HYPE_TRAIN_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_PROGRESS, &"channel.hype_train.progress", &"2", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainprogress", "hype_train_progress")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_hype_train_progress". Use CHANNEL_HYPE_TRAIN_PROGRESS instead.
static var CHANNEL_HYPE_TRAIN_PROGRESS_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_PROGRESS_LEGACY, &"channel.hype_train.progress", &"2", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainprogress", "channel_hype_train_progress")
static var CHANNEL_HYPE_TRAIN_END := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_END, &"channel.hype_train.end", &"2", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainend", "hype_train_end")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_hype_train_end". Use CHANNEL_HYPE_TRAIN_END instead.
static var CHANNEL_HYPE_TRAIN_END_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_END_LEGACY, &"channel.hype_train.end", &"2", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainend", "channel_hype_train_end")
static var CHANNEL_CHARITY_CAMPAIGN_DONATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_DONATE, &"channel.charity_campaign.donate", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaigndonate", "charity_donation")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_charity_campaign_donate". Use CHANNEL_CHARITY_CAMPAIGN_DONATE instead.
static var CHANNEL_CHARITY_CAMPAIGN_DONATE_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_DONATE_LEGACY, &"channel.charity_campaign.donate", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaigndonate", "channel_charity_campaign_donate")
static var CHANNEL_CHARITY_CAMPAIGN_START := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_START, &"channel.charity_campaign.start", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstart", "charity_campaign_start")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_charity_campaign_start". Use CHANNEL_CHARITY_CAMPAIGN_START instead.
static var CHANNEL_CHARITY_CAMPAIGN_START_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_START_LEGACY, &"channel.charity_campaign.start", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstart", "channel_charity_campaign_start")
static var CHANNEL_CHARITY_CAMPAIGN_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_PROGRESS, &"channel.charity_campaign.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignprogress", "charity_campaign_progress")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_charity_campaign_progress". Use CHANNEL_CHARITY_CAMPAIGN_PROGRESS instead.
static var CHANNEL_CHARITY_CAMPAIGN_PROGRESS_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_PROGRESS_LEGACY, &"channel.charity_campaign.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignprogress", "channel_charity_campaign_progress")
static var CHANNEL_CHARITY_CAMPAIGN_STOP := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_STOP, &"channel.charity_campaign.stop", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstop", "charity_campaign_stop")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_charity_campaign_stop". Use CHANNEL_CHARITY_CAMPAIGN_STOP instead.
static var CHANNEL_CHARITY_CAMPAIGN_STOP_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_STOP_LEGACY, &"channel.charity_campaign.stop", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstop", "channel_charity_campaign_stop")
static var CHANNEL_SHARED_CHAT_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_BEGIN, &"channel.shared_chat.begin", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatbegin", "channel_shared_chat_session_begin")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shared_chat_begin". Use CHANNEL_SHARED_CHAT_BEGIN instead.
static var CHANNEL_SHARED_CHAT_BEGIN_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_BEGIN_LEGACY, &"channel.shared_chat.begin", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatbegin", "channel_shared_chat_begin")
static var CHANNEL_SHARED_CHAT_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_UPDATE, &"channel.shared_chat.update", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatupdate", "channel_shared_chat_session_update")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shared_chat_update". Use CHANNEL_SHARED_CHAT_UPDATE instead.
static var CHANNEL_SHARED_CHAT_UPDATE_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_UPDATE_LEGACY, &"channel.shared_chat.update", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatupdate", "channel_shared_chat_update")
static var CHANNEL_SHARED_CHAT_END := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_END, &"channel.shared_chat.end", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatend", "channel_shared_chat_session_end")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shared_chat_end". Use CHANNEL_SHARED_CHAT_END instead.
static var CHANNEL_SHARED_CHAT_END_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_END_LEGACY, &"channel.shared_chat.end", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatend", "channel_shared_chat_end")
static var CHANNEL_SHIELD_MODE_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_SHIELD_MODE_BEGIN, &"channel.shield_mode.begin", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shield_mode",&"moderator:manage:shield_mode"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modebegin", "shield_mode")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shield_mode_begin". Use CHANNEL_SHIELD_MODE_BEGIN instead.
static var CHANNEL_SHIELD_MODE_BEGIN_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_SHIELD_MODE_BEGIN_LEGACY, &"channel.shield_mode.begin", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shield_mode",&"moderator:manage:shield_mode"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modebegin", "channel_shield_mode_begin")
static var CHANNEL_SHIELD_MODE_END := TwitchEventsubDefinition.new(Type.CHANNEL_SHIELD_MODE_END, &"channel.shield_mode.end", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shield_mode",&"moderator:manage:shield_mode"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modeend", "shield_mode")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shield_mode_end". Use CHANNEL_SHIELD_MODE_END instead.
static var CHANNEL_SHIELD_MODE_END_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_SHIELD_MODE_END_LEGACY, &"channel.shield_mode.end", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shield_mode",&"moderator:manage:shield_mode"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modeend", "channel_shield_mode_end")
static var CHANNEL_SHOUTOUT_CREATE := TwitchEventsubDefinition.new(Type.CHANNEL_SHOUTOUT_CREATE, &"channel.shoutout.create", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shoutouts",&"moderator:manage:shoutouts"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutcreate", "shoutout_create")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shoutout_create". Use CHANNEL_SHOUTOUT_CREATE instead.
static var CHANNEL_SHOUTOUT_CREATE_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_SHOUTOUT_CREATE_LEGACY, &"channel.shoutout.create", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shoutouts",&"moderator:manage:shoutouts"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutcreate", "channel_shoutout_create")
static var CHANNEL_SHOUTOUT_RECEIVE := TwitchEventsubDefinition.new(Type.CHANNEL_SHOUTOUT_RECEIVE, &"channel.shoutout.receive", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shoutouts",&"moderator:manage:shoutouts"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutreceive", "shoutout_received")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_shoutout_receive". Use CHANNEL_SHOUTOUT_RECEIVE instead.
static var CHANNEL_SHOUTOUT_RECEIVE_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_SHOUTOUT_RECEIVE_LEGACY, &"channel.shoutout.receive", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shoutouts",&"moderator:manage:shoutouts"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutreceive", "channel_shoutout_receive")
static var CONDUIT_SHARD_DISABLED := TwitchEventsubDefinition.new(Type.CONDUIT_SHARD_DISABLED, &"conduit.shard.disabled", &"1", [&"client_id",&"conduit_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#conduitsharddisabled", "conduit_shard_disabled")
static var DROP_ENTITLEMENT_GRANT := TwitchEventsubDefinition.new(Type.DROP_ENTITLEMENT_GRANT, &"drop.entitlement.grant", &"1", [&"organization_id",&"category_id",&"campaign_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#dropentitlementgrant", "drop_entitlement_grant")
static var EXTENSION_BITS_TRANSACTION_CREATE := TwitchEventsubDefinition.new(Type.EXTENSION_BITS_TRANSACTION_CREATE, &"extension.bits_transaction.create", &"1", [&"extension_client_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#extensionbits_transactioncreate", "extension_bits_transaction_create")
static var CHANNEL_GOAL_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_BEGIN, &"channel.goal.begin", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalbegin", "goals")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_goal_begin". Use CHANNEL_GOAL_BEGIN instead.
static var CHANNEL_GOAL_BEGIN_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_BEGIN_LEGACY, &"channel.goal.begin", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalbegin", "channel_goal_begin")
static var CHANNEL_GOAL_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_PROGRESS, &"channel.goal.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalprogress", "goals")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_goal_progress". Use CHANNEL_GOAL_PROGRESS instead.
static var CHANNEL_GOAL_PROGRESS_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_PROGRESS_LEGACY, &"channel.goal.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalprogress", "channel_goal_progress")
static var CHANNEL_GOAL_END := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_END, &"channel.goal.end", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalend", "goals")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "channel_goal_end". Use CHANNEL_GOAL_END instead.
static var CHANNEL_GOAL_END_LEGACY := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_END_LEGACY, &"channel.goal.end", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalend", "channel_goal_end")
static var STREAM_ONLINE := TwitchEventsubDefinition.new(Type.STREAM_ONLINE, &"stream.online", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#streamonline", "stream_online")
static var STREAM_OFFLINE := TwitchEventsubDefinition.new(Type.STREAM_OFFLINE, &"stream.offline", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#streamoffline", "stream_offline")
static var USER_AUTHORIZATION_GRANT := TwitchEventsubDefinition.new(Type.USER_AUTHORIZATION_GRANT, &"user.authorization.grant", &"1", [&"client_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userauthorizationgrant", "user_authorization_grant")
static var USER_AUTHORIZATION_REVOKE := TwitchEventsubDefinition.new(Type.USER_AUTHORIZATION_REVOKE, &"user.authorization.revoke", &"1", [&"client_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userauthorizationrevoke", "user_authorization_revoke")
static var USER_UPDATE := TwitchEventsubDefinition.new(Type.USER_UPDATE, &"user.update", &"1", [&"user_id"], [&"user:read:email"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userupdate", "user_update")
static var USER_WHISPER_MESSAGE := TwitchEventsubDefinition.new(Type.USER_WHISPER_MESSAGE, &"user.whisper.message", &"1", [&"user_id"], [&"user:read:whispers",&"user:manage:whispers"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userwhispermessage", "whisper_received")
## @deprecated: Kept for backwards compatibility - points at the pre-override script name "user_whisper_message". Use USER_WHISPER_MESSAGE instead.
static var USER_WHISPER_MESSAGE_LEGACY := TwitchEventsubDefinition.new(Type.USER_WHISPER_MESSAGE_LEGACY, &"user.whisper.message", &"1", [&"user_id"], [&"user:read:whispers",&"user:manage:whispers"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userwhispermessage", "user_whisper_message")

## Returns all supported subscriptions
static var ALL: Dictionary[TwitchEventsubDefinition.Type, TwitchEventsubDefinition] = {
	Type.AUTOMOD_MESSAGE_HOLD: AUTOMOD_MESSAGE_HOLD,
	Type.AUTOMOD_MESSAGE_HOLD_V2: AUTOMOD_MESSAGE_HOLD_V2,
	Type.AUTOMOD_MESSAGE_UPDATE: AUTOMOD_MESSAGE_UPDATE,
	Type.AUTOMOD_MESSAGE_UPDATE_V2: AUTOMOD_MESSAGE_UPDATE_V2,
	Type.AUTOMOD_SETTINGS_UPDATE: AUTOMOD_SETTINGS_UPDATE,
	Type.AUTOMOD_TERMS_UPDATE: AUTOMOD_TERMS_UPDATE,
	Type.CHANNEL_BITS_USE: CHANNEL_BITS_USE,
	Type.CHANNEL_UPDATE: CHANNEL_UPDATE,
	Type.CHANNEL_FOLLOW: CHANNEL_FOLLOW,
	Type.CHANNEL_AD_BREAK_BEGIN: CHANNEL_AD_BREAK_BEGIN,
	Type.CHANNEL_CHAT_CLEAR: CHANNEL_CHAT_CLEAR,
	Type.CHANNEL_CHAT_CLEAR_USER_MESSAGES: CHANNEL_CHAT_CLEAR_USER_MESSAGES,
	Type.CHANNEL_CHAT_MESSAGE: CHANNEL_CHAT_MESSAGE,
	Type.CHANNEL_CHAT_MESSAGE_DELETE: CHANNEL_CHAT_MESSAGE_DELETE,
	Type.CHANNEL_CHAT_NOTIFICATION: CHANNEL_CHAT_NOTIFICATION,
	Type.CHANNEL_CHAT_SETTINGS_UPDATE: CHANNEL_CHAT_SETTINGS_UPDATE,
	Type.CHANNEL_CHAT_USER_MESSAGE_HOLD: CHANNEL_CHAT_USER_MESSAGE_HOLD,
	Type.CHANNEL_CHAT_USER_MESSAGE_UPDATE: CHANNEL_CHAT_USER_MESSAGE_UPDATE,
	Type.CHANNEL_SUBSCRIBE: CHANNEL_SUBSCRIBE,
	Type.CHANNEL_SUBSCRIPTION_END: CHANNEL_SUBSCRIPTION_END,
	Type.CHANNEL_SUBSCRIPTION_GIFT: CHANNEL_SUBSCRIPTION_GIFT,
	Type.CHANNEL_SUBSCRIPTION_MESSAGE: CHANNEL_SUBSCRIPTION_MESSAGE,
	Type.CHANNEL_CHEER: CHANNEL_CHEER,
	Type.CHANNEL_RAID: CHANNEL_RAID,
	Type.CHANNEL_BAN: CHANNEL_BAN,
	Type.CHANNEL_UNBAN: CHANNEL_UNBAN,
	Type.CHANNEL_UNBAN_REQUEST_CREATE: CHANNEL_UNBAN_REQUEST_CREATE,
	Type.CHANNEL_UNBAN_REQUEST_RESOLVE: CHANNEL_UNBAN_REQUEST_RESOLVE,
	Type.CHANNEL_MODERATE: CHANNEL_MODERATE,
	Type.CHANNEL_MODERATE_V2: CHANNEL_MODERATE_V2,
	Type.CHANNEL_MODERATOR_ADD: CHANNEL_MODERATOR_ADD,
	Type.CHANNEL_MODERATOR_REMOVE: CHANNEL_MODERATOR_REMOVE,
	Type.CHANNEL_GUEST_STAR_SESSION_BEGIN: CHANNEL_GUEST_STAR_SESSION_BEGIN,
	Type.CHANNEL_GUEST_STAR_SESSION_END: CHANNEL_GUEST_STAR_SESSION_END,
	Type.CHANNEL_GUEST_STAR_GUEST_UPDATE: CHANNEL_GUEST_STAR_GUEST_UPDATE,
	Type.CHANNEL_GUEST_STAR_SETTINGS_UPDATE: CHANNEL_GUEST_STAR_SETTINGS_UPDATE,
	Type.CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD: CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD,
	Type.CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD_V2: CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD_V2,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE,
	Type.CHANNEL_CUSTOM_POWER_UP_REDEMPTION_ADD: CHANNEL_CUSTOM_POWER_UP_REDEMPTION_ADD,
	Type.CHANNEL_POLL_BEGIN: CHANNEL_POLL_BEGIN,
	Type.CHANNEL_POLL_PROGRESS: CHANNEL_POLL_PROGRESS,
	Type.CHANNEL_POLL_END: CHANNEL_POLL_END,
	Type.CHANNEL_PREDICTION_BEGIN: CHANNEL_PREDICTION_BEGIN,
	Type.CHANNEL_PREDICTION_PROGRESS: CHANNEL_PREDICTION_PROGRESS,
	Type.CHANNEL_PREDICTION_LOCK: CHANNEL_PREDICTION_LOCK,
	Type.CHANNEL_PREDICTION_END: CHANNEL_PREDICTION_END,
	Type.CHANNEL_SUSPICIOUS_USER_UPDATE: CHANNEL_SUSPICIOUS_USER_UPDATE,
	Type.CHANNEL_SUSPICIOUS_USER_MESSAGE: CHANNEL_SUSPICIOUS_USER_MESSAGE,
	Type.CHANNEL_VIP_ADD: CHANNEL_VIP_ADD,
	Type.CHANNEL_VIP_REMOVE: CHANNEL_VIP_REMOVE,
	Type.CHANNEL_WARNING_ACKNOWLEDGE: CHANNEL_WARNING_ACKNOWLEDGE,
	Type.CHANNEL_WARNING_SEND: CHANNEL_WARNING_SEND,
	Type.CHANNEL_HYPE_TRAIN_BEGIN: CHANNEL_HYPE_TRAIN_BEGIN,
	Type.CHANNEL_HYPE_TRAIN_BEGIN_LEGACY: CHANNEL_HYPE_TRAIN_BEGIN_LEGACY,
	Type.CHANNEL_HYPE_TRAIN_PROGRESS: CHANNEL_HYPE_TRAIN_PROGRESS,
	Type.CHANNEL_HYPE_TRAIN_PROGRESS_LEGACY: CHANNEL_HYPE_TRAIN_PROGRESS_LEGACY,
	Type.CHANNEL_HYPE_TRAIN_END: CHANNEL_HYPE_TRAIN_END,
	Type.CHANNEL_HYPE_TRAIN_END_LEGACY: CHANNEL_HYPE_TRAIN_END_LEGACY,
	Type.CHANNEL_CHARITY_CAMPAIGN_DONATE: CHANNEL_CHARITY_CAMPAIGN_DONATE,
	Type.CHANNEL_CHARITY_CAMPAIGN_DONATE_LEGACY: CHANNEL_CHARITY_CAMPAIGN_DONATE_LEGACY,
	Type.CHANNEL_CHARITY_CAMPAIGN_START: CHANNEL_CHARITY_CAMPAIGN_START,
	Type.CHANNEL_CHARITY_CAMPAIGN_START_LEGACY: CHANNEL_CHARITY_CAMPAIGN_START_LEGACY,
	Type.CHANNEL_CHARITY_CAMPAIGN_PROGRESS: CHANNEL_CHARITY_CAMPAIGN_PROGRESS,
	Type.CHANNEL_CHARITY_CAMPAIGN_PROGRESS_LEGACY: CHANNEL_CHARITY_CAMPAIGN_PROGRESS_LEGACY,
	Type.CHANNEL_CHARITY_CAMPAIGN_STOP: CHANNEL_CHARITY_CAMPAIGN_STOP,
	Type.CHANNEL_CHARITY_CAMPAIGN_STOP_LEGACY: CHANNEL_CHARITY_CAMPAIGN_STOP_LEGACY,
	Type.CHANNEL_SHARED_CHAT_BEGIN: CHANNEL_SHARED_CHAT_BEGIN,
	Type.CHANNEL_SHARED_CHAT_BEGIN_LEGACY: CHANNEL_SHARED_CHAT_BEGIN_LEGACY,
	Type.CHANNEL_SHARED_CHAT_UPDATE: CHANNEL_SHARED_CHAT_UPDATE,
	Type.CHANNEL_SHARED_CHAT_UPDATE_LEGACY: CHANNEL_SHARED_CHAT_UPDATE_LEGACY,
	Type.CHANNEL_SHARED_CHAT_END: CHANNEL_SHARED_CHAT_END,
	Type.CHANNEL_SHARED_CHAT_END_LEGACY: CHANNEL_SHARED_CHAT_END_LEGACY,
	Type.CHANNEL_SHIELD_MODE_BEGIN: CHANNEL_SHIELD_MODE_BEGIN,
	Type.CHANNEL_SHIELD_MODE_BEGIN_LEGACY: CHANNEL_SHIELD_MODE_BEGIN_LEGACY,
	Type.CHANNEL_SHIELD_MODE_END: CHANNEL_SHIELD_MODE_END,
	Type.CHANNEL_SHIELD_MODE_END_LEGACY: CHANNEL_SHIELD_MODE_END_LEGACY,
	Type.CHANNEL_SHOUTOUT_CREATE: CHANNEL_SHOUTOUT_CREATE,
	Type.CHANNEL_SHOUTOUT_CREATE_LEGACY: CHANNEL_SHOUTOUT_CREATE_LEGACY,
	Type.CHANNEL_SHOUTOUT_RECEIVE: CHANNEL_SHOUTOUT_RECEIVE,
	Type.CHANNEL_SHOUTOUT_RECEIVE_LEGACY: CHANNEL_SHOUTOUT_RECEIVE_LEGACY,
	Type.CONDUIT_SHARD_DISABLED: CONDUIT_SHARD_DISABLED,
	Type.DROP_ENTITLEMENT_GRANT: DROP_ENTITLEMENT_GRANT,
	Type.EXTENSION_BITS_TRANSACTION_CREATE: EXTENSION_BITS_TRANSACTION_CREATE,
	Type.CHANNEL_GOAL_BEGIN: CHANNEL_GOAL_BEGIN,
	Type.CHANNEL_GOAL_BEGIN_LEGACY: CHANNEL_GOAL_BEGIN_LEGACY,
	Type.CHANNEL_GOAL_PROGRESS: CHANNEL_GOAL_PROGRESS,
	Type.CHANNEL_GOAL_PROGRESS_LEGACY: CHANNEL_GOAL_PROGRESS_LEGACY,
	Type.CHANNEL_GOAL_END: CHANNEL_GOAL_END,
	Type.CHANNEL_GOAL_END_LEGACY: CHANNEL_GOAL_END_LEGACY,
	Type.STREAM_ONLINE: STREAM_ONLINE,
	Type.STREAM_OFFLINE: STREAM_OFFLINE,
	Type.USER_AUTHORIZATION_GRANT: USER_AUTHORIZATION_GRANT,
	Type.USER_AUTHORIZATION_REVOKE: USER_AUTHORIZATION_REVOKE,
	Type.USER_UPDATE: USER_UPDATE,
	Type.USER_WHISPER_MESSAGE: USER_WHISPER_MESSAGE,
	Type.USER_WHISPER_MESSAGE_LEGACY: USER_WHISPER_MESSAGE_LEGACY,
}

## Returns all supported subscriptions by name
static var BY_NAME: Dictionary[StringName, TwitchEventsubDefinition] = {
	AUTOMOD_MESSAGE_HOLD.value: AUTOMOD_MESSAGE_HOLD,
	AUTOMOD_MESSAGE_HOLD_V2.value: AUTOMOD_MESSAGE_HOLD_V2,
	AUTOMOD_MESSAGE_UPDATE.value: AUTOMOD_MESSAGE_UPDATE,
	AUTOMOD_MESSAGE_UPDATE_V2.value: AUTOMOD_MESSAGE_UPDATE_V2,
	AUTOMOD_SETTINGS_UPDATE.value: AUTOMOD_SETTINGS_UPDATE,
	AUTOMOD_TERMS_UPDATE.value: AUTOMOD_TERMS_UPDATE,
	CHANNEL_BITS_USE.value: CHANNEL_BITS_USE,
	CHANNEL_UPDATE.value: CHANNEL_UPDATE,
	CHANNEL_FOLLOW.value: CHANNEL_FOLLOW,
	CHANNEL_AD_BREAK_BEGIN.value: CHANNEL_AD_BREAK_BEGIN,
	CHANNEL_CHAT_CLEAR.value: CHANNEL_CHAT_CLEAR,
	CHANNEL_CHAT_CLEAR_USER_MESSAGES.value: CHANNEL_CHAT_CLEAR_USER_MESSAGES,
	CHANNEL_CHAT_MESSAGE.value: CHANNEL_CHAT_MESSAGE,
	CHANNEL_CHAT_MESSAGE_DELETE.value: CHANNEL_CHAT_MESSAGE_DELETE,
	CHANNEL_CHAT_NOTIFICATION.value: CHANNEL_CHAT_NOTIFICATION,
	CHANNEL_CHAT_SETTINGS_UPDATE.value: CHANNEL_CHAT_SETTINGS_UPDATE,
	CHANNEL_CHAT_USER_MESSAGE_HOLD.value: CHANNEL_CHAT_USER_MESSAGE_HOLD,
	CHANNEL_CHAT_USER_MESSAGE_UPDATE.value: CHANNEL_CHAT_USER_MESSAGE_UPDATE,
	CHANNEL_SUBSCRIBE.value: CHANNEL_SUBSCRIBE,
	CHANNEL_SUBSCRIPTION_END.value: CHANNEL_SUBSCRIPTION_END,
	CHANNEL_SUBSCRIPTION_GIFT.value: CHANNEL_SUBSCRIPTION_GIFT,
	CHANNEL_SUBSCRIPTION_MESSAGE.value: CHANNEL_SUBSCRIPTION_MESSAGE,
	CHANNEL_CHEER.value: CHANNEL_CHEER,
	CHANNEL_RAID.value: CHANNEL_RAID,
	CHANNEL_BAN.value: CHANNEL_BAN,
	CHANNEL_UNBAN.value: CHANNEL_UNBAN,
	CHANNEL_UNBAN_REQUEST_CREATE.value: CHANNEL_UNBAN_REQUEST_CREATE,
	CHANNEL_UNBAN_REQUEST_RESOLVE.value: CHANNEL_UNBAN_REQUEST_RESOLVE,
	CHANNEL_MODERATE.value: CHANNEL_MODERATE,
	CHANNEL_MODERATE_V2.value: CHANNEL_MODERATE_V2,
	CHANNEL_MODERATOR_ADD.value: CHANNEL_MODERATOR_ADD,
	CHANNEL_MODERATOR_REMOVE.value: CHANNEL_MODERATOR_REMOVE,
	CHANNEL_GUEST_STAR_SESSION_BEGIN.value: CHANNEL_GUEST_STAR_SESSION_BEGIN,
	CHANNEL_GUEST_STAR_SESSION_END.value: CHANNEL_GUEST_STAR_SESSION_END,
	CHANNEL_GUEST_STAR_GUEST_UPDATE.value: CHANNEL_GUEST_STAR_GUEST_UPDATE,
	CHANNEL_GUEST_STAR_SETTINGS_UPDATE.value: CHANNEL_GUEST_STAR_SETTINGS_UPDATE,
	CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD.value: CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD,
	CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD_V2.value: CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD_V2,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD.value: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE.value: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE.value: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD.value: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD,
	CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE.value: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE,
	CHANNEL_CUSTOM_POWER_UP_REDEMPTION_ADD.value: CHANNEL_CUSTOM_POWER_UP_REDEMPTION_ADD,
	CHANNEL_POLL_BEGIN.value: CHANNEL_POLL_BEGIN,
	CHANNEL_POLL_PROGRESS.value: CHANNEL_POLL_PROGRESS,
	CHANNEL_POLL_END.value: CHANNEL_POLL_END,
	CHANNEL_PREDICTION_BEGIN.value: CHANNEL_PREDICTION_BEGIN,
	CHANNEL_PREDICTION_PROGRESS.value: CHANNEL_PREDICTION_PROGRESS,
	CHANNEL_PREDICTION_LOCK.value: CHANNEL_PREDICTION_LOCK,
	CHANNEL_PREDICTION_END.value: CHANNEL_PREDICTION_END,
	CHANNEL_SUSPICIOUS_USER_UPDATE.value: CHANNEL_SUSPICIOUS_USER_UPDATE,
	CHANNEL_SUSPICIOUS_USER_MESSAGE.value: CHANNEL_SUSPICIOUS_USER_MESSAGE,
	CHANNEL_VIP_ADD.value: CHANNEL_VIP_ADD,
	CHANNEL_VIP_REMOVE.value: CHANNEL_VIP_REMOVE,
	CHANNEL_WARNING_ACKNOWLEDGE.value: CHANNEL_WARNING_ACKNOWLEDGE,
	CHANNEL_WARNING_SEND.value: CHANNEL_WARNING_SEND,
	CHANNEL_HYPE_TRAIN_BEGIN.value: CHANNEL_HYPE_TRAIN_BEGIN,
	CHANNEL_HYPE_TRAIN_BEGIN_LEGACY.value: CHANNEL_HYPE_TRAIN_BEGIN_LEGACY,
	CHANNEL_HYPE_TRAIN_PROGRESS.value: CHANNEL_HYPE_TRAIN_PROGRESS,
	CHANNEL_HYPE_TRAIN_PROGRESS_LEGACY.value: CHANNEL_HYPE_TRAIN_PROGRESS_LEGACY,
	CHANNEL_HYPE_TRAIN_END.value: CHANNEL_HYPE_TRAIN_END,
	CHANNEL_HYPE_TRAIN_END_LEGACY.value: CHANNEL_HYPE_TRAIN_END_LEGACY,
	CHANNEL_CHARITY_CAMPAIGN_DONATE.value: CHANNEL_CHARITY_CAMPAIGN_DONATE,
	CHANNEL_CHARITY_CAMPAIGN_DONATE_LEGACY.value: CHANNEL_CHARITY_CAMPAIGN_DONATE_LEGACY,
	CHANNEL_CHARITY_CAMPAIGN_START.value: CHANNEL_CHARITY_CAMPAIGN_START,
	CHANNEL_CHARITY_CAMPAIGN_START_LEGACY.value: CHANNEL_CHARITY_CAMPAIGN_START_LEGACY,
	CHANNEL_CHARITY_CAMPAIGN_PROGRESS.value: CHANNEL_CHARITY_CAMPAIGN_PROGRESS,
	CHANNEL_CHARITY_CAMPAIGN_PROGRESS_LEGACY.value: CHANNEL_CHARITY_CAMPAIGN_PROGRESS_LEGACY,
	CHANNEL_CHARITY_CAMPAIGN_STOP.value: CHANNEL_CHARITY_CAMPAIGN_STOP,
	CHANNEL_CHARITY_CAMPAIGN_STOP_LEGACY.value: CHANNEL_CHARITY_CAMPAIGN_STOP_LEGACY,
	CHANNEL_SHARED_CHAT_BEGIN.value: CHANNEL_SHARED_CHAT_BEGIN,
	CHANNEL_SHARED_CHAT_BEGIN_LEGACY.value: CHANNEL_SHARED_CHAT_BEGIN_LEGACY,
	CHANNEL_SHARED_CHAT_UPDATE.value: CHANNEL_SHARED_CHAT_UPDATE,
	CHANNEL_SHARED_CHAT_UPDATE_LEGACY.value: CHANNEL_SHARED_CHAT_UPDATE_LEGACY,
	CHANNEL_SHARED_CHAT_END.value: CHANNEL_SHARED_CHAT_END,
	CHANNEL_SHARED_CHAT_END_LEGACY.value: CHANNEL_SHARED_CHAT_END_LEGACY,
	CHANNEL_SHIELD_MODE_BEGIN.value: CHANNEL_SHIELD_MODE_BEGIN,
	CHANNEL_SHIELD_MODE_BEGIN_LEGACY.value: CHANNEL_SHIELD_MODE_BEGIN_LEGACY,
	CHANNEL_SHIELD_MODE_END.value: CHANNEL_SHIELD_MODE_END,
	CHANNEL_SHIELD_MODE_END_LEGACY.value: CHANNEL_SHIELD_MODE_END_LEGACY,
	CHANNEL_SHOUTOUT_CREATE.value: CHANNEL_SHOUTOUT_CREATE,
	CHANNEL_SHOUTOUT_CREATE_LEGACY.value: CHANNEL_SHOUTOUT_CREATE_LEGACY,
	CHANNEL_SHOUTOUT_RECEIVE.value: CHANNEL_SHOUTOUT_RECEIVE,
	CHANNEL_SHOUTOUT_RECEIVE_LEGACY.value: CHANNEL_SHOUTOUT_RECEIVE_LEGACY,
	CONDUIT_SHARD_DISABLED.value: CONDUIT_SHARD_DISABLED,
	DROP_ENTITLEMENT_GRANT.value: DROP_ENTITLEMENT_GRANT,
	EXTENSION_BITS_TRANSACTION_CREATE.value: EXTENSION_BITS_TRANSACTION_CREATE,
	CHANNEL_GOAL_BEGIN.value: CHANNEL_GOAL_BEGIN,
	CHANNEL_GOAL_BEGIN_LEGACY.value: CHANNEL_GOAL_BEGIN_LEGACY,
	CHANNEL_GOAL_PROGRESS.value: CHANNEL_GOAL_PROGRESS,
	CHANNEL_GOAL_PROGRESS_LEGACY.value: CHANNEL_GOAL_PROGRESS_LEGACY,
	CHANNEL_GOAL_END.value: CHANNEL_GOAL_END,
	CHANNEL_GOAL_END_LEGACY.value: CHANNEL_GOAL_END_LEGACY,
	STREAM_ONLINE.value: STREAM_ONLINE,
	STREAM_OFFLINE.value: STREAM_OFFLINE,
	USER_AUTHORIZATION_GRANT.value: USER_AUTHORIZATION_GRANT,
	USER_AUTHORIZATION_REVOKE.value: USER_AUTHORIZATION_REVOKE,
	USER_UPDATE.value: USER_UPDATE,
	USER_WHISPER_MESSAGE.value: USER_WHISPER_MESSAGE,
	USER_WHISPER_MESSAGE_LEGACY.value: USER_WHISPER_MESSAGE_LEGACY,
}
