@tool
extends Object

class_name TwitchEventsubDefinition

## All supported subscriptions should be used in comination with get_all method as index.
enum Type {
	AUTOMOD_MESSAGE_HOLD,
	AUTOMOD_MESSAGE_UPDATE,
	AUTOMOD_SETTINGS_UPDATE,
	AUTOMOD_TERMS_UPDATE,
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
	CHANNEL_SUSPICIOUS_USER_UPDATE,
	CHANNEL_SUSPICIOUS_USER_MESSAGE,
	CHANNEL_VIP_ADD,
	CHANNEL_VIP_REMOVE,
	CHANNEL_WARNING_ACKNOWLEDGE,
	CHANNEL_WARNING_SEND,
	CHANNEL_HYPE_TRAIN_BEGIN,
	CHANNEL_HYPE_TRAIN_PROGRESS,
	CHANNEL_HYPE_TRAIN_END,
	CHANNEL_CHARITY_CAMPAIGN_DONATE,
	CHANNEL_CHARITY_CAMPAIGN_START,
	CHANNEL_CHARITY_CAMPAIGN_PROGRESS,
	CHANNEL_CHARITY_CAMPAIGN_STOP,
	CHANNEL_SHARED_CHAT_BEGIN,
	CHANNEL_SHARED_CHAT_UPDATE,
	CHANNEL_SHARED_CHAT_END,
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
	USER_WHISPER_MESSAGE,
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


func _init(typ: Type, val: StringName, ver: StringName, cond: Array[StringName], scps: Array[StringName], doc_link: String):
	type = typ
	value = val
	version = ver
	conditions = cond
	scopes = scps
	documentation_link = doc_link

## Get a human readable name of it
func get_readable_name() -> String:
	return "%s (v%s)" % [value, version]


static var AUTOMOD_MESSAGE_HOLD := TwitchEventsubDefinition.new(Type.AUTOMOD_MESSAGE_HOLD, &"automod.message.hold", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:automod"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessagehold")
static var AUTOMOD_MESSAGE_UPDATE := TwitchEventsubDefinition.new(Type.AUTOMOD_MESSAGE_UPDATE, &"automod.message.update", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:automod"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodmessageupdate")
static var AUTOMOD_SETTINGS_UPDATE := TwitchEventsubDefinition.new(Type.AUTOMOD_SETTINGS_UPDATE, &"automod.settings.update", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:automod_settings"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodsettingsupdate")
static var AUTOMOD_TERMS_UPDATE := TwitchEventsubDefinition.new(Type.AUTOMOD_TERMS_UPDATE, &"automod.terms.update", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:automod"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#automodtermsupdate")
static var CHANNEL_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_UPDATE, &"channel.update", &"2", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelupdate")
static var CHANNEL_FOLLOW := TwitchEventsubDefinition.new(Type.CHANNEL_FOLLOW, &"channel.follow", &"2", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:followers"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelfollow")
static var CHANNEL_AD_BREAK_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_AD_BREAK_BEGIN, &"channel.ad_break.begin", &"1", [&"broadcaster_user_id"], [&"channel:read:ads"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelad_breakbegin")
static var CHANNEL_CHAT_CLEAR := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_CLEAR, &"channel.chat.clear", &"1", [&"broadcaster_user_id",&"user_id"], [&"channel:bot",&"user:bot",&"user:read:chat"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatclear")
static var CHANNEL_CHAT_CLEAR_USER_MESSAGES := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_CLEAR_USER_MESSAGES, &"channel.chat.clear_user_messages", &"1", [&"broadcaster_user_id",&"user_id"], [&"channel:bot",&"user:bot",&"user:read:chat"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatclear_user_messages")
static var CHANNEL_CHAT_MESSAGE := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_MESSAGE, &"channel.chat.message", &"1", [&"broadcaster_user_id",&"user_id"], [&"channel:bot",&"user:bot",&"user:read:chat"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatmessage")
static var CHANNEL_CHAT_MESSAGE_DELETE := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_MESSAGE_DELETE, &"channel.chat.message_delete", &"1", [&"broadcaster_user_id",&"user_id"], [&"channel:bot",&"user:bot",&"user:read:chat"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatmessage_delete")
static var CHANNEL_CHAT_NOTIFICATION := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_NOTIFICATION, &"channel.chat.notification", &"1", [&"broadcaster_user_id",&"user_id"], [&"channel:bot",&"user:bot",&"user:read:chat"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatnotification")
static var CHANNEL_CHAT_SETTINGS_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_SETTINGS_UPDATE, &"channel.chat_settings.update", &"1", [&"broadcaster_user_id",&"user_id"], [&"channel:bot",&"user:bot",&"user:read:chat"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchat_settingsupdate")
static var CHANNEL_CHAT_USER_MESSAGE_HOLD := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_USER_MESSAGE_HOLD, &"channel.chat.user_message_hold", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:bot",&"user:read:chat"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatuser_message_hold")
static var CHANNEL_CHAT_USER_MESSAGE_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHAT_USER_MESSAGE_UPDATE, &"channel.chat.user_message_update", &"1", [&"broadcaster_user_id",&"user_id"], [&"user:bot",&"user:read:chat"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchatuser_message_update")
static var CHANNEL_SUBSCRIBE := TwitchEventsubDefinition.new(Type.CHANNEL_SUBSCRIBE, &"channel.subscribe", &"1", [&"broadcaster_user_id"], [&"channel:read:subscriptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscribe")
static var CHANNEL_SUBSCRIPTION_END := TwitchEventsubDefinition.new(Type.CHANNEL_SUBSCRIPTION_END, &"channel.subscription.end", &"1", [&"broadcaster_user_id"], [&"channel:read:subscriptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptionend")
static var CHANNEL_SUBSCRIPTION_GIFT := TwitchEventsubDefinition.new(Type.CHANNEL_SUBSCRIPTION_GIFT, &"channel.subscription.gift", &"1", [&"broadcaster_user_id"], [&"channel:read:subscriptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptiongift")
static var CHANNEL_SUBSCRIPTION_MESSAGE := TwitchEventsubDefinition.new(Type.CHANNEL_SUBSCRIPTION_MESSAGE, &"channel.subscription.message", &"1", [&"broadcaster_user_id"], [&"channel:read:subscriptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptionmessage")
static var CHANNEL_CHEER := TwitchEventsubDefinition.new(Type.CHANNEL_CHEER, &"channel.cheer", &"1", [&"broadcaster_user_id"], [&"bits:read"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcheer")
static var CHANNEL_RAID := TwitchEventsubDefinition.new(Type.CHANNEL_RAID, &"channel.raid", &"1", [&"to_broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelraid")
static var CHANNEL_BAN := TwitchEventsubDefinition.new(Type.CHANNEL_BAN, &"channel.ban", &"1", [&"broadcaster_user_id"], [&"channel:moderate"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelban")
static var CHANNEL_UNBAN := TwitchEventsubDefinition.new(Type.CHANNEL_UNBAN, &"channel.unban", &"1", [&"broadcaster_user_id"], [&"channel:moderate"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban")
static var CHANNEL_UNBAN_REQUEST_CREATE := TwitchEventsubDefinition.new(Type.CHANNEL_UNBAN_REQUEST_CREATE, &"channel.unban_request.create", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:unban_requests",&"moderator:manage:unban_requests"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban_requestcreate")
static var CHANNEL_UNBAN_REQUEST_RESOLVE := TwitchEventsubDefinition.new(Type.CHANNEL_UNBAN_REQUEST_RESOLVE, &"channel.unban_request.resolve", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:unban_requests",&"moderator:manage:unban_requests"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelunban_requestresolve")
static var CHANNEL_MODERATE := TwitchEventsubDefinition.new(Type.CHANNEL_MODERATE, &"channel.moderate", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:banned_users",&"moderator:manage:blocked_terms",&"moderator:read:banned_users",&"moderator:manage:chat_messages",&"moderator:manage:unban_requests",&"moderator:manage:chat_settings",&"moderator:read:unban_requests",&"moderator:read:chat_settings",&"moderator:read:vips",&"moderator:read:chat_messages",&"moderator:read:blocked_terms",&"moderator:read:moderators"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderate")
static var CHANNEL_MODERATE_V2 := TwitchEventsubDefinition.new(Type.CHANNEL_MODERATE_V2, &"channel.moderate", &"2", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:banned_users",&"moderator:manage:blocked_terms",&"moderator:read:banned_users",&"moderator:manage:chat_messages",&"moderator:manage:unban_requests",&"moderator:manage:warnings",&"moderator:manage:chat_settings",&"moderator:read:unban_requests",&"moderator:read:chat_settings",&"moderator:read:vips",&"moderator:read:warnings",&"moderator:read:chat_messages",&"moderator:read:blocked_terms",&"moderator:read:moderators"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderate-v2")
static var CHANNEL_MODERATOR_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_MODERATOR_ADD, &"channel.moderator.add", &"1", [&"broadcaster_user_id"], [&"moderation:read"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderatoradd")
static var CHANNEL_MODERATOR_REMOVE := TwitchEventsubDefinition.new(Type.CHANNEL_MODERATOR_REMOVE, &"channel.moderator.remove", &"1", [&"broadcaster_user_id"], [&"moderation:read"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelmoderatorremove")
static var CHANNEL_GUEST_STAR_SESSION_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_GUEST_STAR_SESSION_BEGIN, &"channel.guest_star_session.begin", &"beta", [&"broadcaster_user_id",&"moderator_user_id"], [&"channel:read:guest_star",&"moderator:manage:guest_star",&"moderator:read:guest_star",&"channel:manage:guest_star"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_sessionbegin")
static var CHANNEL_GUEST_STAR_SESSION_END := TwitchEventsubDefinition.new(Type.CHANNEL_GUEST_STAR_SESSION_END, &"channel.guest_star_session.end", &"beta", [&"broadcaster_user_id",&"moderator_user_id"], [&"channel:read:guest_star",&"moderator:manage:guest_star",&"moderator:read:guest_star",&"channel:manage:guest_star"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_sessionend")
static var CHANNEL_GUEST_STAR_GUEST_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_GUEST_STAR_GUEST_UPDATE, &"channel.guest_star_guest.update", &"beta", [&"broadcaster_user_id",&"moderator_user_id"], [&"channel:read:guest_star",&"moderator:manage:guest_star",&"moderator:read:guest_star",&"channel:manage:guest_star"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_guestupdate")
static var CHANNEL_GUEST_STAR_SETTINGS_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_GUEST_STAR_SETTINGS_UPDATE, &"channel.guest_star_settings.update", &"beta", [&"broadcaster_user_id",&"moderator_user_id"], [&"channel:read:guest_star",&"moderator:manage:guest_star",&"moderator:read:guest_star",&"channel:manage:guest_star"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelguest_star_settingsupdate")
static var CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_AUTOMATIC_REWARD_REDEMPTION_ADD, &"channel.channel_points_automatic_reward_redemption.add", &"1", [&"broadcaster_user_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_automatic_reward_redemptionadd")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD, &"channel.channel_points_custom_reward.add", &"1", [&"broadcaster_user_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardadd")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE, &"channel.channel_points_custom_reward.update", &"1", [&"broadcaster_user_id",&"reward_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardupdate")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE, &"channel.channel_points_custom_reward.remove", &"1", [&"broadcaster_user_id",&"reward_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardremove")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD, &"channel.channel_points_custom_reward_redemption.add", &"1", [&"broadcaster_user_id",&"reward_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionadd")
static var CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE, &"channel.channel_points_custom_reward_redemption.update", &"1", [&"broadcaster_user_id",&"reward_id"], [&"channel:read:redemptions",&"channel:manage:redemptions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionupdate")
static var CHANNEL_POLL_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_POLL_BEGIN, &"channel.poll.begin", &"1", [&"broadcaster_user_id"], [&"channel:manage:polls",&"channel:read:polls"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollbegin")
static var CHANNEL_POLL_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_POLL_PROGRESS, &"channel.poll.progress", &"1", [&"broadcaster_user_id"], [&"channel:manage:polls",&"channel:read:polls"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollprogress")
static var CHANNEL_POLL_END := TwitchEventsubDefinition.new(Type.CHANNEL_POLL_END, &"channel.poll.end", &"1", [&"broadcaster_user_id"], [&"channel:manage:polls",&"channel:read:polls"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollend")
static var CHANNEL_PREDICTION_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_PREDICTION_BEGIN, &"channel.prediction.begin", &"1", [&"broadcaster_user_id"], [&"channel:manage:predictions",&"channel:read:predictions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionbegin")
static var CHANNEL_PREDICTION_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_PREDICTION_PROGRESS, &"channel.prediction.progress", &"1", [&"broadcaster_user_id"], [&"channel:manage:predictions",&"channel:read:predictions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionprogress")
static var CHANNEL_PREDICTION_LOCK := TwitchEventsubDefinition.new(Type.CHANNEL_PREDICTION_LOCK, &"channel.prediction.lock", &"1", [&"broadcaster_user_id"], [&"channel:manage:predictions",&"channel:read:predictions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionlock")
static var CHANNEL_PREDICTION_END := TwitchEventsubDefinition.new(Type.CHANNEL_PREDICTION_END, &"channel.prediction.end", &"1", [&"broadcaster_user_id"], [&"channel:manage:predictions",&"channel:read:predictions"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionend")
static var CHANNEL_SUSPICIOUS_USER_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_SUSPICIOUS_USER_UPDATE, &"channel.suspicious_user.update", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:suspicious_users"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsuspicious_userupdate")
static var CHANNEL_SUSPICIOUS_USER_MESSAGE := TwitchEventsubDefinition.new(Type.CHANNEL_SUSPICIOUS_USER_MESSAGE, &"channel.suspicious_user.message", &"1", [&"moderator_user_id",&"broadcaster_user_id"], [&"moderator:read:suspicious_users"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsuspicious_usermessage")
static var CHANNEL_VIP_ADD := TwitchEventsubDefinition.new(Type.CHANNEL_VIP_ADD, &"channel.vip.add", &"1", [&"broadcaster_user_id"], [&"channel:manage:vips",&"channel:read:vips"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelvipadd")
static var CHANNEL_VIP_REMOVE := TwitchEventsubDefinition.new(Type.CHANNEL_VIP_REMOVE, &"channel.vip.remove", &"1", [&"broadcaster_user_id"], [&"channel:manage:vips",&"channel:read:vips"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelvipremove")
static var CHANNEL_WARNING_ACKNOWLEDGE := TwitchEventsubDefinition.new(Type.CHANNEL_WARNING_ACKNOWLEDGE, &"channel.warning.acknowledge", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:warnings",&"moderator:read:warnings"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelwarningacknowledge")
static var CHANNEL_WARNING_SEND := TwitchEventsubDefinition.new(Type.CHANNEL_WARNING_SEND, &"channel.warning.send", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:manage:warnings",&"moderator:read:warnings"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelwarningsend")
static var CHANNEL_HYPE_TRAIN_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_BEGIN, &"channel.hype_train.begin", &"1", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainbegin")
static var CHANNEL_HYPE_TRAIN_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_PROGRESS, &"channel.hype_train.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainprogress")
static var CHANNEL_HYPE_TRAIN_END := TwitchEventsubDefinition.new(Type.CHANNEL_HYPE_TRAIN_END, &"channel.hype_train.end", &"1", [&"broadcaster_user_id"], [&"channel:read:hype_train"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainend")
static var CHANNEL_CHARITY_CAMPAIGN_DONATE := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_DONATE, &"channel.charity_campaign.donate", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaigndonate")
static var CHANNEL_CHARITY_CAMPAIGN_START := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_START, &"channel.charity_campaign.start", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstart")
static var CHANNEL_CHARITY_CAMPAIGN_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_PROGRESS, &"channel.charity_campaign.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignprogress")
static var CHANNEL_CHARITY_CAMPAIGN_STOP := TwitchEventsubDefinition.new(Type.CHANNEL_CHARITY_CAMPAIGN_STOP, &"channel.charity_campaign.stop", &"1", [&"broadcaster_user_id"], [&"channel:read:charity"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstop")
static var CHANNEL_SHARED_CHAT_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_BEGIN, &"channel.shared_chat.begin", &"beta", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatbegin")
static var CHANNEL_SHARED_CHAT_UPDATE := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_UPDATE, &"channel.shared_chat.update", &"beta", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatupdate")
static var CHANNEL_SHARED_CHAT_END := TwitchEventsubDefinition.new(Type.CHANNEL_SHARED_CHAT_END, &"channel.shared_chat.end", &"beta", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshared_chatend")
static var CHANNEL_SHIELD_MODE_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_SHIELD_MODE_BEGIN, &"channel.shield_mode.begin", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shield_mode",&"moderator:manage:shield_mode"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modebegin")
static var CHANNEL_SHIELD_MODE_END := TwitchEventsubDefinition.new(Type.CHANNEL_SHIELD_MODE_END, &"channel.shield_mode.end", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shield_mode",&"moderator:manage:shield_mode"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshield_modeend")
static var CHANNEL_SHOUTOUT_CREATE := TwitchEventsubDefinition.new(Type.CHANNEL_SHOUTOUT_CREATE, &"channel.shoutout.create", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shoutouts",&"moderator:manage:shoutouts"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutcreate")
static var CHANNEL_SHOUTOUT_RECEIVE := TwitchEventsubDefinition.new(Type.CHANNEL_SHOUTOUT_RECEIVE, &"channel.shoutout.receive", &"1", [&"broadcaster_user_id",&"moderator_user_id"], [&"moderator:read:shoutouts",&"moderator:manage:shoutouts"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutreceive")
static var CONDUIT_SHARD_DISABLED := TwitchEventsubDefinition.new(Type.CONDUIT_SHARD_DISABLED, &"conduit.shard.disabled", &"1", [&"client_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#conduitsharddisabled")
static var DROP_ENTITLEMENT_GRANT := TwitchEventsubDefinition.new(Type.DROP_ENTITLEMENT_GRANT, &"drop.entitlement.grant", &"1", [&"organization_id",&"category_id",&"campaign_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#dropentitlementgrant")
static var EXTENSION_BITS_TRANSACTION_CREATE := TwitchEventsubDefinition.new(Type.EXTENSION_BITS_TRANSACTION_CREATE, &"extension.bits_transaction.create", &"1", [&"extension_client_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#extensionbits_transactioncreate")
static var CHANNEL_GOAL_BEGIN := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_BEGIN, &"channel.goal.begin", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalbegin")
static var CHANNEL_GOAL_PROGRESS := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_PROGRESS, &"channel.goal.progress", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalprogress")
static var CHANNEL_GOAL_END := TwitchEventsubDefinition.new(Type.CHANNEL_GOAL_END, &"channel.goal.end", &"1", [&"broadcaster_user_id"], [&"channel:read:goals"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalend")
static var STREAM_ONLINE := TwitchEventsubDefinition.new(Type.STREAM_ONLINE, &"stream.online", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#streamonline")
static var STREAM_OFFLINE := TwitchEventsubDefinition.new(Type.STREAM_OFFLINE, &"stream.offline", &"1", [&"broadcaster_user_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#streamoffline")
static var USER_AUTHORIZATION_GRANT := TwitchEventsubDefinition.new(Type.USER_AUTHORIZATION_GRANT, &"user.authorization.grant", &"1", [&"client_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userauthorizationgrant")
static var USER_AUTHORIZATION_REVOKE := TwitchEventsubDefinition.new(Type.USER_AUTHORIZATION_REVOKE, &"user.authorization.revoke", &"1", [&"client_id"], [], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userauthorizationrevoke")
static var USER_UPDATE := TwitchEventsubDefinition.new(Type.USER_UPDATE, &"user.update", &"1", [&"user_id"], [&"user:read:email"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userupdate")
static var USER_WHISPER_MESSAGE := TwitchEventsubDefinition.new(Type.USER_WHISPER_MESSAGE, &"user.whisper.message", &"1", [&"user_id"], [&"user:manage:whispers",&"user:read:whispers"], "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#userwhispermessage")


## Returns all supported subscriptions
## Key: TwitchEventsubDefinition.Type | Value: TwitchEventsubDefinition
static var ALL: Dictionary = {
	Type.AUTOMOD_MESSAGE_HOLD: AUTOMOD_MESSAGE_HOLD,
	Type.AUTOMOD_MESSAGE_UPDATE: AUTOMOD_MESSAGE_UPDATE,
	Type.AUTOMOD_SETTINGS_UPDATE: AUTOMOD_SETTINGS_UPDATE,
	Type.AUTOMOD_TERMS_UPDATE: AUTOMOD_TERMS_UPDATE,
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
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_ADD,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_UPDATE,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REMOVE,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD,
	Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE: CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE,
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
	Type.CHANNEL_HYPE_TRAIN_PROGRESS: CHANNEL_HYPE_TRAIN_PROGRESS,
	Type.CHANNEL_HYPE_TRAIN_END: CHANNEL_HYPE_TRAIN_END,
	Type.CHANNEL_CHARITY_CAMPAIGN_DONATE: CHANNEL_CHARITY_CAMPAIGN_DONATE,
	Type.CHANNEL_CHARITY_CAMPAIGN_START: CHANNEL_CHARITY_CAMPAIGN_START,
	Type.CHANNEL_CHARITY_CAMPAIGN_PROGRESS: CHANNEL_CHARITY_CAMPAIGN_PROGRESS,
	Type.CHANNEL_CHARITY_CAMPAIGN_STOP: CHANNEL_CHARITY_CAMPAIGN_STOP,
	Type.CHANNEL_SHARED_CHAT_BEGIN: CHANNEL_SHARED_CHAT_BEGIN,
	Type.CHANNEL_SHARED_CHAT_UPDATE: CHANNEL_SHARED_CHAT_UPDATE,
	Type.CHANNEL_SHARED_CHAT_END: CHANNEL_SHARED_CHAT_END,
	Type.CHANNEL_SHIELD_MODE_BEGIN: CHANNEL_SHIELD_MODE_BEGIN,
	Type.CHANNEL_SHIELD_MODE_END: CHANNEL_SHIELD_MODE_END,
	Type.CHANNEL_SHOUTOUT_CREATE: CHANNEL_SHOUTOUT_CREATE,
	Type.CHANNEL_SHOUTOUT_RECEIVE: CHANNEL_SHOUTOUT_RECEIVE,
	Type.CONDUIT_SHARD_DISABLED: CONDUIT_SHARD_DISABLED,
	Type.DROP_ENTITLEMENT_GRANT: DROP_ENTITLEMENT_GRANT,
	Type.EXTENSION_BITS_TRANSACTION_CREATE: EXTENSION_BITS_TRANSACTION_CREATE,
	Type.CHANNEL_GOAL_BEGIN: CHANNEL_GOAL_BEGIN,
	Type.CHANNEL_GOAL_PROGRESS: CHANNEL_GOAL_PROGRESS,
	Type.CHANNEL_GOAL_END: CHANNEL_GOAL_END,
	Type.STREAM_ONLINE: STREAM_ONLINE,
	Type.STREAM_OFFLINE: STREAM_OFFLINE,
	Type.USER_AUTHORIZATION_GRANT: USER_AUTHORIZATION_GRANT,
	Type.USER_AUTHORIZATION_REVOKE: USER_AUTHORIZATION_REVOKE,
	Type.USER_UPDATE: USER_UPDATE,
	Type.USER_WHISPER_MESSAGE: USER_WHISPER_MESSAGE,
}
