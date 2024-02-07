class_name TwitchRestAPI

var repo: TwitchRepository

func _init(twitch_repository: TwitchRepository):
	repo = twitch_repository;

## Starts a commercial on the specified channel.
func start_commercial(body: Dictionary) -> Dictionary:

	var response = await repo.request("/channels/commercial", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Returns ad schedule related information.
func get_ad_schedule(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channels/ads", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Pushes back the timestamp of the upcoming automatic mid-roll ad by 5 minutes.
func snooze_next_ad(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channels/ads/schedule/snooze", HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets an analytics report for one or more extensions.
func get_extension_analytics(extension_id: String, type: String, started_at: Variant, ended_at: Variant, first: int, after: String) -> Dictionary:
	started_at = get_rfc_3339_date_format(started_at);
	ended_at = get_rfc_3339_date_format(ended_at);

	var response = await repo.request("/analytics/extensions?extension_id=%s&type=%s&started_at=%s&ended_at=%s&first=%s&after=%s" % [extension_id,type,started_at,ended_at,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets an analytics report for one or more games.
func get_game_analytics(game_id: String, type: String, started_at: Variant, ended_at: Variant, first: int, after: String) -> Dictionary:
	started_at = get_rfc_3339_date_format(started_at);
	ended_at = get_rfc_3339_date_format(ended_at);

	var response = await repo.request("/analytics/games?game_id=%s&type=%s&started_at=%s&ended_at=%s&first=%s&after=%s" % [game_id,type,started_at,ended_at,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the Bits leaderboard for the authenticated broadcaster.
func get_bits_leaderboard(count: int, period: String, started_at: Variant, user_id: String) -> Dictionary:
	started_at = get_rfc_3339_date_format(started_at);

	var response = await repo.request("/bits/leaderboard?count=%s&period=%s&started_at=%s&user_id=%s" % [count,period,started_at,user_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of Cheermotes that users can use to cheer Bits.
func get_cheermotes(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/bits/cheermotes", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets an extension’s list of transactions.
func get_extension_transactions(extension_id: String, id: Variant, first: int, after: String) -> Dictionary:

	var response = await repo.request("/extensions/transactions?extension_id=%s&id=%s&first=%s&after=%s" % [extension_id,id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets information about one or more channels.
func get_channel_information(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channels", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates a channel’s properties.
func modify_channel_information(body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/channels", HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets the broadcaster’s list editors.
func get_channel_editors(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channels/editors", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of broadcasters that the specified user follows. You can also use this endpoint to see whether a user follows a specific broadcaster.
func get_followed_channels(user_id: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channels/followed?user_id=%s&first=%s&after=%s" % [user_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of users that follow the specified broadcaster. You can also use this endpoint to see whether a specific user follows the broadcaster.
func get_channel_followers(user_id: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channels/followers?user_id=%s&first=%s&after=%s" % [user_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Creates a Custom Reward in the broadcaster’s channel.
func create_custom_rewards(body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channel_points/custom_rewards", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Deletes a custom reward that the broadcaster created.
func delete_custom_reward(id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/channel_points/custom_rewards?id=%s" % [id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets a list of custom rewards that the specified broadcaster created.
func get_custom_reward(id: Variant, only_manageable_rewards: Variant, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channel_points/custom_rewards?id=%s&only_manageable_rewards=%s" % [id,only_manageable_rewards], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates a custom reward.
func update_custom_reward(id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channel_points/custom_rewards?id=%s" % [id], HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of redemptions for a custom reward.
func get_custom_reward_redemption(reward_id: String, status: String, id: Variant, sort: String, after: String, first: int, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channel_points/custom_rewards/redemptions?reward_id=%s&status=%s&id=%s&sort=%s&after=%s&first=%s" % [reward_id,status,id,sort,after,first], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates a redemption’s status.
func update_redemption_status(id: Variant, reward_id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channel_points/custom_rewards/redemptions?id=%s&reward_id=%s" % [id,reward_id], HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets information about the broadcaster’s active charity campaign.
func get_charity_campaign(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/charity/campaigns", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the list of donations that users have made to the broadcaster’s active charity campaign.
func get_charity_campaign_donations(first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/charity/donations?first=%s&after=%s" % [first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the list of users that are connected to the broadcaster’s chat session.
func get_chatters(moderator_id: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/chat/chatters?moderator_id=%s&first=%s&after=%s" % [moderator_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the broadcaster’s list of custom emotes.
func get_channel_emotes(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/chat/emotes", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets all global emotes.
func get_global_emotes() -> Dictionary:

	var response = await repo.request("/chat/emotes/global", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets emotes for one or more specified emote sets.
func get_emote_sets(emote_set_id: Variant) -> Dictionary:

	var response = await repo.request("/chat/emotes/set?emote_set_id=%s" % [emote_set_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the broadcaster’s list of custom chat badges.
func get_channel_chat_badges(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/chat/badges", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets Twitch’s list of chat badges.
func get_global_chat_badges() -> Dictionary:

	var response = await repo.request("/chat/badges/global", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the broadcaster’s chat settings.
func get_chat_settings(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/chat/settings?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates the broadcaster’s chat settings.
func update_chat_settings(moderator_id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/chat/settings?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Sends an announcement to the broadcaster’s chat room.
func send_chat_announcement(moderator_id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/chat/announcements?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Sends a Shoutout to the specified broadcaster.
func send_a_shoutout(from_broadcaster_id: String, to_broadcaster_id: String, moderator_id: String) -> void:

	var response = await repo.request("/chat/shoutouts?from_broadcaster_id=%s&to_broadcaster_id=%s&moderator_id=%s" % [from_broadcaster_id,to_broadcaster_id,moderator_id], HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## NEW Sends a message to the broadcaster’s chat room.
func send_chat_message(body: Dictionary) -> Dictionary:

	var response = await repo.request("/chat/messages", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the color used for the user’s name in chat.
func get_user_chat_color(user_id: Variant) -> Dictionary:

	var response = await repo.request("/chat/color?user_id=%s" % [user_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates the color used for the user’s name in chat.
func update_user_chat_color(user_id: String, color: String) -> void:

	var response = await repo.request("/chat/color?user_id=%s&color=%s" % [user_id,color], HTTPClient.METHOD_PUT, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Creates a clip from the broadcaster’s stream.
func create_clip(has_delay: Variant, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/clips?has_delay=%s" % [has_delay], HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets one or more video clips.
func get_clips(game_id: String, id: Variant, started_at: Variant, ended_at: Variant, first: int, before: String, after: String, is_featured: Variant, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:
	started_at = get_rfc_3339_date_format(started_at);
	ended_at = get_rfc_3339_date_format(ended_at);

	var response = await repo.request("/clips?game_id=%s&id=%s&started_at=%s&ended_at=%s&first=%s&before=%s&after=%s&is_featured=%s" % [game_id,id,started_at,ended_at,first,before,after,is_featured], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## NEW  Gets the conduits for a client ID.
func get_conduits() -> Dictionary:

	var response = await repo.request("/eventsub/conduits", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## NEW Creates a new conduit.
func create_conduits(body: Dictionary) -> Dictionary:

	var response = await repo.request("/eventsub/conduits", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## NEW Updates a conduit’s shard count.
func update_conduits(body: Dictionary) -> Dictionary:

	var response = await repo.request("/eventsub/conduits", HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## NEW Deletes a specified conduit.
func delete_conduit(id: String) -> void:

	var response = await repo.request("/eventsub/conduits?id=%s" % [id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## NEW Gets a lists of all shards for a conduit.
func get_conduit_shards(conduit_id: String, status: String, after: String) -> Dictionary:

	var response = await repo.request("/eventsub/conduits/shards?conduit_id=%s&status=%s&after=%s" % [conduit_id,status,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## NEW Updates shard(s) for a conduit.
func update_conduit_shards(body: Dictionary) -> void:

	var response = await repo.request("/eventsub/conduits/shards", HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets information about Twitch content classification labels.
func get_content_classification_labels(locale: String) -> Dictionary:

	var response = await repo.request("/content_classification_labels?locale=%s" % [locale], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets an organization’s list of entitlements that have been granted to a game, a user, or both.
func get_drops_entitlements(id: Variant, user_id: String, game_id: String, fulfillment_status: String, after: String, first: int) -> Dictionary:

	var response = await repo.request("/entitlements/drops?id=%s&user_id=%s&game_id=%s&fulfillment_status=%s&after=%s&first=%s" % [id,user_id,game_id,fulfillment_status,after,first], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates the Drop entitlement’s fulfillment status.
func update_drops_entitlements(body: Dictionary) -> Dictionary:

	var response = await repo.request("/entitlements/drops", HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the specified configuration segment from the specified extension.
func get_extension_configuration_segment(extension_id: String, segment: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/extensions/configurations?extension_id=%s&segment=%s" % [extension_id,segment], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates a configuration segment.
func set_extension_configuration_segment(body: Dictionary) -> void:

	var response = await repo.request("/extensions/configurations", HTTPClient.METHOD_PUT, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Updates the extension’s required_configuration string.
func set_extension_required_configuration(body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/extensions/required_configuration", HTTPClient.METHOD_PUT, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Sends a message to one or more viewers.
func send_extension_pubsub_message(body: Dictionary) -> void:

	var response = await repo.request("/extensions/pubsub", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets a list of broadcasters that are streaming live and have installed or activated the extension.
func get_extension_live_channels(extension_id: String, first: int, after: String) -> Dictionary:

	var response = await repo.request("/extensions/live?extension_id=%s&first=%s&after=%s" % [extension_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets an extension’s list of shared secrets.
func get_extension_secrets() -> Dictionary:

	var response = await repo.request("/extensions/jwt/secrets", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Creates a shared secret used to sign and verify JWT tokens.
func create_extension_secret(extension_id: String, delay: int) -> Dictionary:

	var response = await repo.request("/extensions/jwt/secrets?extension_id=%s&delay=%s" % [extension_id,delay], HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Sends a message to the specified broadcaster’s chat room.
func send_extension_chat_message(body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/extensions/chat", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets information about an extension.
func get_extensions(extension_id: String, extension_version: String) -> Dictionary:

	var response = await repo.request("/extensions?extension_id=%s&extension_version=%s" % [extension_id,extension_version], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets information about a released extension.
func get_released_extensions(extension_id: String, extension_version: String) -> Dictionary:

	var response = await repo.request("/extensions/released?extension_id=%s&extension_version=%s" % [extension_id,extension_version], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the list of Bits products that belongs to the extension.
func get_extension_bits_products(should_include_all: Variant) -> Dictionary:

	var response = await repo.request("/bits/extensions?should_include_all=%s" % [should_include_all], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Adds or updates a Bits product that the extension created.
func update_extension_bits_product(body: Dictionary) -> Dictionary:

	var response = await repo.request("/bits/extensions", HTTPClient.METHOD_PUT, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Creates an EventSub subscription.
func create_eventsub_subscription(body: Dictionary) -> void:

	var response = await repo.request("/eventsub/subscriptions", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Deletes an EventSub subscription.
func delete_eventsub_subscription(id: String) -> void:

	var response = await repo.request("/eventsub/subscriptions?id=%s" % [id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets a list of EventSub subscriptions that the client in the access token created.
func get_eventsub_subscriptions(status: String, type: String, user_id: String, after: String) -> Dictionary:

	var response = await repo.request("/eventsub/subscriptions?status=%s&type=%s&user_id=%s&after=%s" % [status,type,user_id,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets information about all broadcasts on Twitch.
func get_top_games(first: int, after: String, before: String) -> Dictionary:

	var response = await repo.request("/games/top?first=%s&after=%s&before=%s" % [first,after,before], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets information about specified games.
func get_games(id: Variant, name: Variant, igdb_id: Variant) -> Dictionary:

	var response = await repo.request("/games?id=%s&name=%s&igdb_id=%s" % [id,name,igdb_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the broadcaster’s list of active goals.
func get_creator_goals(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/goals", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## BETA Gets the channel settings for configuration of the Guest Star feature for a particular host.
func get_channel_guest_star_settings(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/guest_star/channel_settings?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## BETA Mutates the channel settings for configuration of the Guest Star feature for a particular host.
func update_channel_guest_star_settings(body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/guest_star/channel_settings", HTTPClient.METHOD_PUT, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## BETA Gets information about an ongoing Guest Star session for a particular channel.
func get_guest_star_session(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/guest_star/session?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## BETA Programmatically creates a Guest Star session on behalf of the broadcaster.
func create_guest_star_session(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/guest_star/session", HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## BETA Programmatically ends a Guest Star session on behalf of the broadcaster.
func end_guest_star_session(session_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/guest_star/session?session_id=%s" % [session_id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## BETA Provides the caller with a list of pending invites to a Guest Star session.
func get_guest_star_invites(moderator_id: String, session_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/guest_star/invites?moderator_id=%s&session_id=%s" % [moderator_id,session_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## BETA Sends an invite to a specified guest on behalf of the broadcaster for a Guest Star session in progress.
func send_guest_star_invite(moderator_id: String, session_id: String, guest_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/guest_star/invites?moderator_id=%s&session_id=%s&guest_id=%s" % [moderator_id,session_id,guest_id], HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## BETA Revokes a previously sent invite for a Guest Star session.
func delete_guest_star_invite(moderator_id: String, session_id: String, guest_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/guest_star/invites?moderator_id=%s&session_id=%s&guest_id=%s" % [moderator_id,session_id,guest_id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## BETA Allows a previously invited user to be assigned a slot within the active Guest Star session.
func assign_guest_star_slot(moderator_id: String, session_id: String, guest_id: String, slot_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/guest_star/slot?moderator_id=%s&session_id=%s&guest_id=%s&slot_id=%s" % [moderator_id,session_id,guest_id,slot_id], HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## BETA Allows a user to update the assigned slot for a particular user within the active Guest Star session.
func update_guest_star_slot(moderator_id: String, session_id: String, source_slot_id: String, destination_slot_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/guest_star/slot?moderator_id=%s&session_id=%s&source_slot_id=%s&destination_slot_id=%s" % [moderator_id,session_id,source_slot_id,destination_slot_id], HTTPClient.METHOD_PATCH, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## BETA Allows a caller to remove a slot assignment from a user participating in an active Guest Star session.
func delete_guest_star_slot(moderator_id: String, session_id: String, guest_id: String, slot_id: String, should_reinvite_guest: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/guest_star/slot?moderator_id=%s&session_id=%s&guest_id=%s&slot_id=%s&should_reinvite_guest=%s" % [moderator_id,session_id,guest_id,slot_id,should_reinvite_guest], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## BETA Allows a user to update slot settings for a particular guest within a Guest Star session.
func update_guest_star_slot_settings(moderator_id: String, session_id: String, slot_id: String, is_audio_enabled: Variant, is_video_enabled: Variant, is_live: Variant, volume: int, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/guest_star/slot_settings?moderator_id=%s&session_id=%s&slot_id=%s&is_audio_enabled=%s&is_video_enabled=%s&is_live=%s&volume=%s" % [moderator_id,session_id,slot_id,is_audio_enabled,is_video_enabled,is_live,volume], HTTPClient.METHOD_PATCH, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets information about the broadcaster’s current or most recent Hype Train event.
func get_hype_train_events(first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/hypetrain/events?first=%s&after=%s" % [first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Checks whether AutoMod would flag the specified message for review.
func check_automod_status(body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/enforcements/status", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Allow or deny the message that AutoMod flagged for review.
func manage_held_automod_messages(body: Dictionary) -> void:

	var response = await repo.request("/moderation/automod/message", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets the broadcaster’s AutoMod settings.
func get_automod_settings(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/automod/settings?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates the broadcaster’s AutoMod settings.
func update_automod_settings(moderator_id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/automod/settings?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_PUT, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets all users that the broadcaster banned or put in a timeout.
func get_banned_users(user_id: Variant, first: int, after: String, before: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/banned?user_id=%s&first=%s&after=%s&before=%s" % [user_id,first,after,before], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Bans a user from participating in a broadcaster’s chat room or puts them in a timeout.
func ban_user(moderator_id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/bans?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Removes the ban or timeout that was placed on the specified user.
func unban_user(moderator_id: String, user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/moderation/bans?moderator_id=%s&user_id=%s" % [moderator_id,user_id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets the broadcaster’s list of non-private, blocked words or phrases.
func get_blocked_terms(moderator_id: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/blocked_terms?moderator_id=%s&first=%s&after=%s" % [moderator_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Adds a word or phrase to the broadcaster’s list of blocked terms.
func add_blocked_term(moderator_id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/blocked_terms?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Removes the word or phrase from the broadcaster’s list of blocked terms.
func remove_blocked_term(moderator_id: String, id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/moderation/blocked_terms?moderator_id=%s&id=%s" % [moderator_id,id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Removes a single chat message or all chat messages from the broadcaster’s chat room.
func delete_chat_messages(moderator_id: String, message_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/moderation/chat?moderator_id=%s&message_id=%s" % [moderator_id,message_id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets a list of channels that the specified user has moderator privileges in.
func get_moderated_channels(user_id: String, after: String, first: int) -> Dictionary:

	var response = await repo.request("/moderation/channels?user_id=%s&after=%s&first=%s" % [user_id,after,first], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets all users allowed to moderate the broadcaster’s chat room.
func get_moderators(user_id: Variant, first: String, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/moderators?user_id=%s&first=%s&after=%s" % [user_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Adds a moderator to the broadcaster’s chat room.
func add_channel_moderator(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/moderation/moderators?user_id=%s" % [user_id], HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Removes a moderator from the broadcaster’s chat room.
func remove_channel_moderator(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/moderation/moderators?user_id=%s" % [user_id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets a list of the broadcaster’s VIPs.
func get_vips(user_id: Variant, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/channels/vips?user_id=%s&first=%s&after=%s" % [user_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Adds the specified user as a VIP in the broadcaster’s channel.
func add_channel_vip(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/channels/vips?user_id=%s" % [user_id], HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Removes the specified user as a VIP in the broadcaster’s channel.
func remove_channel_vip(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/channels/vips?user_id=%s" % [user_id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Activates or deactivates the broadcaster’s Shield Mode.
func update_shield_mode_status(moderator_id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/shield_mode?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_PUT, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the broadcaster’s Shield Mode activation status.
func get_shield_mode_status(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/moderation/shield_mode?moderator_id=%s" % [moderator_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of polls that the broadcaster created.
func get_polls(id: Variant, first: String, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/polls?id=%s&first=%s&after=%s" % [id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Creates a poll that viewers in the broadcaster’s channel can vote on.
func create_poll(body: Dictionary) -> Dictionary:

	var response = await repo.request("/polls", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## End an active poll.
func end_poll(body: Dictionary) -> Dictionary:

	var response = await repo.request("/polls", HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of Channel Points Predictions that the broadcaster created.
func get_predictions(id: Variant, first: String, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/predictions?id=%s&first=%s&after=%s" % [id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Create a Channel Points Prediction.
func create_prediction(body: Dictionary) -> Dictionary:

	var response = await repo.request("/predictions", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Locks, resolves, or cancels a Channel Points Prediction.
func end_prediction(body: Dictionary) -> Dictionary:

	var response = await repo.request("/predictions", HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Raid another channel by sending the broadcaster’s viewers to the targeted channel.
func start_a_raid(from_broadcaster_id: String, to_broadcaster_id: String) -> Dictionary:

	var response = await repo.request("/raids?from_broadcaster_id=%s&to_broadcaster_id=%s" % [from_broadcaster_id,to_broadcaster_id], HTTPClient.METHOD_POST, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Cancel a pending raid.
func cancel_a_raid(broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/raids", HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets the broadcaster’s streaming schedule.
func get_channel_stream_schedule(id: Variant, start_time: Variant, utc_offset: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:
	start_time = get_rfc_3339_date_format(start_time);

	var response = await repo.request("/schedule?id=%s&start_time=%s&utc_offset=%s&first=%s&after=%s" % [id,start_time,utc_offset,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the broadcaster’s streaming schedule as an iCalendar.
func get_channel_icalendar(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/schedule/icalendar", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates the broadcaster’s schedule settings, such as scheduling a vacation.
func update_channel_stream_schedule(is_vacation_enabled: Variant, vacation_start_time: Variant, vacation_end_time: Variant, timezone: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:
	vacation_start_time = get_rfc_3339_date_format(vacation_start_time);
	vacation_end_time = get_rfc_3339_date_format(vacation_end_time);

	var response = await repo.request("/schedule/settings?is_vacation_enabled=%s&vacation_start_time=%s&vacation_end_time=%s&timezone=%s" % [is_vacation_enabled,vacation_start_time,vacation_end_time,timezone], HTTPClient.METHOD_PATCH, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Adds a single or recurring broadcast to the broadcaster’s streaming schedule.
func create_channel_stream_schedule_segment(body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/schedule/segment", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates a scheduled broadcast segment.
func update_channel_stream_schedule_segment(id: String, body: Dictionary, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/schedule/segment?id=%s" % [id], HTTPClient.METHOD_PATCH, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Deletes a broadcast from the broadcaster’s streaming schedule.
func delete_channel_stream_schedule_segment(id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> void:

	var response = await repo.request("/schedule/segment?id=%s" % [id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets the games or categories that match the specified query.
func search_categories(query: String, first: int, after: String) -> Dictionary:

	var response = await repo.request("/search/categories?query=%s&first=%s&after=%s" % [query,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the channels that match the specified query and have streamed content within the past 6 months.
func search_channels(query: String, live_only: Variant, first: int, after: String) -> Dictionary:

	var response = await repo.request("/search/channels?query=%s&live_only=%s&first=%s&after=%s" % [query,live_only,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the channel’s stream key.
func get_stream_key(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/streams/key", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of all streams.
func get_streams(user_id: Variant, user_login: Variant, game_id: Variant, type: String, language: Variant, first: int, before: String, after: String) -> Dictionary:

	var response = await repo.request("/streams?user_id=%s&user_login=%s&game_id=%s&type=%s&language=%s&first=%s&before=%s&after=%s" % [user_id,user_login,game_id,type,language,first,before,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the list of broadcasters that the user follows and that are streaming live.
func get_followed_streams(user_id: String, first: int, after: String) -> Dictionary:

	var response = await repo.request("/streams/followed?user_id=%s&first=%s&after=%s" % [user_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Adds a marker to a live stream.
func create_stream_marker(body: Dictionary) -> Dictionary:

	var response = await repo.request("/streams/markers", HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of markers from the user’s most recent stream or from the specified VOD/video.
func get_stream_markers(user_id: String, video_id: String, first: String, before: String, after: String) -> Dictionary:

	var response = await repo.request("/streams/markers?user_id=%s&video_id=%s&first=%s&before=%s&after=%s" % [user_id,video_id,first,before,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets a list of users that subscribe to the specified broadcaster.
func get_broadcaster_subscriptions(user_id: Variant, first: String, after: String, before: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/subscriptions?user_id=%s&first=%s&after=%s&before=%s" % [user_id,first,after,before], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Checks whether the user subscribes to the broadcaster’s channel.
func check_user_subscription(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/subscriptions/user?user_id=%s" % [user_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the list of all stream tags that Twitch defines. You can also filter the list by one or more tag IDs.
func get_all_stream_tags(tag_id: Variant, first: int, after: String) -> Dictionary:

	var response = await repo.request("/tags/streams?tag_id=%s&first=%s&after=%s" % [tag_id,first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the list of stream tags that the broadcaster or Twitch added to their channel.
func get_stream_tags(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/streams/tags", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the list of Twitch teams that the broadcaster is a member of.
func get_channel_teams(broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/teams/channel", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets information about the specified Twitch team.
func get_teams(name: String, id: String) -> Dictionary:

	var response = await repo.request("/teams?name=%s&id=%s" % [name,id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets information about one or more users.
func get_users(id: Variant, login: Variant) -> Dictionary:

	var response = await repo.request("/users?id=%s&login=%s" % [id,login], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates the user’s information.
func update_user(description: String) -> Dictionary:

	var response = await repo.request("/users?description=%s" % [description], HTTPClient.METHOD_PUT, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the list of users that the broadcaster has blocked.
func get_user_block_list(first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> Dictionary:

	var response = await repo.request("/users/blocks?first=%s&after=%s" % [first,after], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Blocks the specified user from interacting with or having contact with the broadcaster.
func block_user(target_user_id: String, source_context: String, reason: String) -> void:

	var response = await repo.request("/users/blocks?target_user_id=%s&source_context=%s&reason=%s" % [target_user_id,source_context,reason], HTTPClient.METHOD_PUT, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Removes the user from the broadcaster’s list of blocked users.
func unblock_user(target_user_id: String) -> void:

	var response = await repo.request("/users/blocks?target_user_id=%s" % [target_user_id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());


## Gets a list of all extensions (both active and inactive) that the broadcaster has installed.
func get_user_extensions() -> Dictionary:

	var response = await repo.request("/users/extensions/list", HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets the active extensions that the broadcaster has installed for each configuration.
func get_user_active_extensions(user_id: String) -> Dictionary:

	var response = await repo.request("/users/extensions?user_id=%s" % [user_id], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Updates an installed extension’s information.
func update_user_extensions(body: Dictionary) -> Dictionary:

	var response = await repo.request("/users/extensions", HTTPClient.METHOD_PUT, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Gets information about one or more published videos.
func get_videos(id: Variant, user_id: String, game_id: String, language: String, period: String, sort: String, type: String, first: String, after: String, before: String) -> Dictionary:

	var response = await repo.request("/videos?id=%s&user_id=%s&game_id=%s&language=%s&period=%s&sort=%s&type=%s&first=%s&after=%s&before=%s" % [id,user_id,game_id,language,period,sort,type,first,after,before], HTTPClient.METHOD_GET, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Deletes one or more videos.
func delete_videos(id: Variant) -> Dictionary:

	var response = await repo.request("/videos?id=%s" % [id], HTTPClient.METHOD_DELETE, {}, );
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());

	return result;


## Sends a whisper message to the specified user.
func send_whisper(from_user_id: String, to_user_id: String, body: Dictionary) -> void:

	var response = await repo.request("/whispers?from_user_id=%s&to_user_id=%s" % [from_user_id,to_user_id], HTTPClient.METHOD_POST, {}, body);
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());




## Converts unix timestamp to RFC 3339 (example: 2021-10-27T00:00:00Z) when passed a string uses as is
static func get_rfc_3339_date_format(time: Variant) -> String:
	if typeof(time) == TYPE_INT:
		var date_time = Time.get_datetime_dict_from_unix_time(time);
		return "%s-%02d-%02dT%02d:%02d:%02dZ" % [date_time['year'], date_time['month'], date_time['day'], date_time['hour'], date_time['minute'], date_time['second']];
	return str(time);
