
# Starts a commercial on the specified channel.
func start_commercial() -> Dictionary:
	var response = await request("/channels/commercial", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Returns ad schedule related information.
func get_ad_schedule(broadcaster_id) -> Dictionary:
	var response = await request("/channels/ads", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Pushes back the timestamp of the upcoming automatic mid-roll ad by 5 minutes.
func snooze_next_ad(broadcaster_id) -> Dictionary:
	var response = await request("/channels/ads/schedule/snooze", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets an analytics report for one or more extensions.
func get_extension_analytics(extension_id, type, started_at, ended_at, first, after) -> Dictionary:
	var response = await request("/analytics/extensions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets an analytics report for one or more games.
func get_game_analytics(game_id, type, started_at, ended_at, first, after) -> Dictionary:
	var response = await request("/analytics/games", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the Bits leaderboard for the authenticated broadcaster.
func get_bits_leaderboard(count, period, started_at, user_id) -> Dictionary:
	var response = await request("/bits/leaderboard", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of Cheermotes that users can use to cheer Bits.
func get_cheermotes(broadcaster_id) -> Dictionary:
	var response = await request("/bits/cheermotes", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets an extension’s list of transactions.
func get_extension_transactions(extension_id, id, first, after) -> Dictionary:
	var response = await request("/extensions/transactions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about one or more channels.
func get_channel_information(broadcaster_id) -> Dictionary:
	var response = await request("/channels", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates a channel’s properties.
func modify_channel_information(broadcaster_id) -> void:
	var response = await request("/channels", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s list editors.
func get_channel_editors(broadcaster_id) -> Dictionary:
	var response = await request("/channels/editors", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of broadcasters that the specified user follows. You can also use this endpoint to see whether a user follows a specific broadcaster.
func get_followed_channels(user_id, broadcaster_id, first, after) -> Dictionary:
	var response = await request("/channels/followed", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of users that follow the specified broadcaster. You can also use this endpoint to see whether a specific user follows the broadcaster.
func get_channel_followers(user_id, broadcaster_id, first, after) -> Dictionary:
	var response = await request("/channels/followers", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Creates a Custom Reward in the broadcaster’s channel.
func create_custom_rewards(broadcaster_id) -> Dictionary:
	var response = await request("/channel_points/custom_rewards", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Deletes a custom reward that the broadcaster created.
func delete_custom_reward(broadcaster_id, id) -> void:
	var response = await request("/channel_points/custom_rewards", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of custom rewards that the specified broadcaster created.
func get_custom_reward(broadcaster_id, id, only_manageable_rewards) -> Dictionary:
	var response = await request("/channel_points/custom_rewards", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates a custom reward.
func update_custom_reward(broadcaster_id, id) -> Dictionary:
	var response = await request("/channel_points/custom_rewards", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of redemptions for a custom reward.
func get_custom_reward_redemption(broadcaster_id, reward_id, status, id, sort, after, first) -> Dictionary:
	var response = await request("/channel_points/custom_rewards/redemptions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates a redemption’s status.
func update_redemption_status(id, broadcaster_id, reward_id) -> Dictionary:
	var response = await request("/channel_points/custom_rewards/redemptions", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about the broadcaster’s active charity campaign.
func get_charity_campaign(broadcaster_id) -> Dictionary:
	var response = await request("/charity/campaigns", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the list of donations that users have made to the broadcaster’s active charity campaign.
func get_charity_campaign_donations(broadcaster_id, first, after) -> Dictionary:
	var response = await request("/charity/donations", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the list of users that are connected to the broadcaster’s chat session.
func get_chatters(broadcaster_id, moderator_id, first, after) -> Dictionary:
	var response = await request("/chat/chatters", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s list of custom emotes.
func get_channel_emotes(broadcaster_id) -> Dictionary:
	var response = await request("/chat/emotes", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets all global emotes.
func get_global_emotes() -> Dictionary:
	var response = await request("/chat/emotes/global", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets emotes for one or more specified emote sets.
func get_emote_sets(emote_set_id) -> Dictionary:
	var response = await request("/chat/emotes/set", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s list of custom chat badges.
func get_channel_chat_badges(broadcaster_id) -> Dictionary:
	var response = await request("/chat/badges", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets Twitch’s list of chat badges.
func get_global_chat_badges() -> Dictionary:
	var response = await request("/chat/badges/global", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s chat settings.
func get_chat_settings(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/chat/settings", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates the broadcaster’s chat settings.
func update_chat_settings(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/chat/settings", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Sends an announcement to the broadcaster’s chat room.
func send_chat_announcement(broadcaster_id, moderator_id) -> void:
	var response = await request("/chat/announcements", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Sends a Shoutout to the specified broadcaster.
func send_a_shoutout(from_broadcaster_id, to_broadcaster_id, moderator_id) -> void:
	var response = await request("/chat/shoutouts", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# NEW Sends a message to the broadcaster’s chat room.
func send_chat_message() -> Dictionary:
	var response = await request("/chat/messages", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the color used for the user’s name in chat.
func get_user_chat_color(user_id) -> Dictionary:
	var response = await request("/chat/color", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates the color used for the user’s name in chat.
func update_user_chat_color(user_id, color) -> void:
	var response = await request("/chat/color", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Creates a clip from the broadcaster’s stream.
func create_clip(broadcaster_id, has_delay) -> void:
	var response = await request("/clips", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets one or more video clips.
func get_clips(broadcaster_id, game_id, id, started_at, ended_at, first, before, after, is_featured) -> Dictionary:
	var response = await request("/clips", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# NEW  Gets the conduits for a client ID.
func get_conduits() -> Dictionary:
	var response = await request("/eventsub/conduits", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# NEW Creates a new conduit.
func create_conduits() -> Dictionary:
	var response = await request("/eventsub/conduits", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# NEW Updates a conduit’s shard count.
func update_conduits() -> Dictionary:
	var response = await request("/eventsub/conduits", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# NEW Deletes a specified conduit.
func delete_conduit(id) -> void:
	var response = await request("/eventsub/conduits", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# NEW Gets a lists of all shards for a conduit.
func get_conduit_shards(conduit_id, status, after) -> Dictionary:
	var response = await request("/eventsub/conduits/shards", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# NEW Updates shard(s) for a conduit.
func update_conduit_shards() -> void:
	var response = await request("/eventsub/conduits/shards", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about Twitch content classification labels.
func get_content_classification_labels(locale) -> Dictionary:
	var response = await request("/content_classification_labels", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets an organization’s list of entitlements that have been granted to a game, a user, or both.
func get_drops_entitlements(id, user_id, game_id, fulfillment_status, after, first) -> Dictionary:
	var response = await request("/entitlements/drops", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates the Drop entitlement’s fulfillment status.
func update_drops_entitlements() -> Dictionary:
	var response = await request("/entitlements/drops", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the specified configuration segment from the specified extension.
func get_extension_configuration_segment(broadcaster_id, extension_id, segment) -> Dictionary:
	var response = await request("/extensions/configurations", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates a configuration segment.
func set_extension_configuration_segment() -> void:
	var response = await request("/extensions/configurations", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates the extension’s required_configuration string.
func set_extension_required_configuration(broadcaster_id) -> void:
	var response = await request("/extensions/required_configuration", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Sends a message to one or more viewers.
func send_extension_pubsub_message() -> void:
	var response = await request("/extensions/pubsub", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of broadcasters that are streaming live and have installed or activated the extension.
func get_extension_live_channels(extension_id, first, after) -> Dictionary:
	var response = await request("/extensions/live", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets an extension’s list of shared secrets.
func get_extension_secrets() -> Dictionary:
	var response = await request("/extensions/jwt/secrets", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Creates a shared secret used to sign and verify JWT tokens.
func create_extension_secret(extension_id, delay) -> Dictionary:
	var response = await request("/extensions/jwt/secrets", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Sends a message to the specified broadcaster’s chat room.
func send_extension_chat_message(broadcaster_id) -> void:
	var response = await request("/extensions/chat", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about an extension.
func get_extensions(extension_id, extension_version) -> Dictionary:
	var response = await request("/extensions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about a released extension.
func get_released_extensions(extension_id, extension_version) -> Dictionary:
	var response = await request("/extensions/released", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the list of Bits products that belongs to the extension.
func get_extension_bits_products(should_include_all) -> Dictionary:
	var response = await request("/bits/extensions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Adds or updates a Bits product that the extension created.
func update_extension_bits_product() -> Dictionary:
	var response = await request("/bits/extensions", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Creates an EventSub subscription.
func create_eventsub_subscription() -> void:
	var response = await request("/eventsub/subscriptions", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Deletes an EventSub subscription.
func delete_eventsub_subscription(id) -> void:
	var response = await request("/eventsub/subscriptions", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of EventSub subscriptions that the client in the access token created.
func get_eventsub_subscriptions(status, type, user_id, after) -> Dictionary:
	var response = await request("/eventsub/subscriptions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about all broadcasts on Twitch.
func get_top_games(first, after, before) -> Dictionary:
	var response = await request("/games/top", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about specified games.
func get_games(id, name, igdb_id) -> Dictionary:
	var response = await request("/games", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s list of active goals.
func get_creator_goals(broadcaster_id) -> Dictionary:
	var response = await request("/goals", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Gets the channel settings for configuration of the Guest Star feature for a particular host.
func get_channel_guest_star_settings(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/guest_star/channel_settings", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Mutates the channel settings for configuration of the Guest Star feature for a particular host.
func update_channel_guest_star_settings(broadcaster_id) -> void:
	var response = await request("/guest_star/channel_settings", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Gets information about an ongoing Guest Star session for a particular channel.
func get_guest_star_session(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/guest_star/session", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Programmatically creates a Guest Star session on behalf of the broadcaster.
func create_guest_star_session(broadcaster_id) -> Dictionary:
	var response = await request("/guest_star/session", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Programmatically ends a Guest Star session on behalf of the broadcaster.
func end_guest_star_session(broadcaster_id, session_id) -> void:
	var response = await request("/guest_star/session", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Provides the caller with a list of pending invites to a Guest Star session.
func get_guest_star_invites(broadcaster_id, moderator_id, session_id) -> Dictionary:
	var response = await request("/guest_star/invites", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Sends an invite to a specified guest on behalf of the broadcaster for a Guest Star session in progress.
func send_guest_star_invite(broadcaster_id, moderator_id, session_id, guest_id) -> void:
	var response = await request("/guest_star/invites", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Revokes a previously sent invite for a Guest Star session.
func delete_guest_star_invite(broadcaster_id, moderator_id, session_id, guest_id) -> void:
	var response = await request("/guest_star/invites", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Allows a previously invited user to be assigned a slot within the active Guest Star session.
func assign_guest_star_slot(broadcaster_id, moderator_id, session_id, guest_id, slot_id) -> void:
	var response = await request("/guest_star/slot", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Allows a user to update the assigned slot for a particular user within the active Guest Star session.
func update_guest_star_slot(broadcaster_id, moderator_id, session_id, source_slot_id, destination_slot_id) -> void:
	var response = await request("/guest_star/slot", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Allows a caller to remove a slot assignment from a user participating in an active Guest Star session.
func delete_guest_star_slot(broadcaster_id, moderator_id, session_id, guest_id, slot_id, should_reinvite_guest) -> void:
	var response = await request("/guest_star/slot", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# BETA Allows a user to update slot settings for a particular guest within a Guest Star session.
func update_guest_star_slot_settings(broadcaster_id, moderator_id, session_id, slot_id, is_audio_enabled, is_video_enabled, is_live, volume) -> void:
	var response = await request("/guest_star/slot_settings", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about the broadcaster’s current or most recent Hype Train event.
func get_hype_train_events(broadcaster_id, first, after) -> Dictionary:
	var response = await request("/hypetrain/events", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Checks whether AutoMod would flag the specified message for review.
func check_automod_status(broadcaster_id) -> Dictionary:
	var response = await request("/moderation/enforcements/status", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Allow or deny the message that AutoMod flagged for review.
func manage_held_automod_messages() -> void:
	var response = await request("/moderation/automod/message", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s AutoMod settings.
func get_automod_settings(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/moderation/automod/settings", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates the broadcaster’s AutoMod settings.
func update_automod_settings(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/moderation/automod/settings", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets all users that the broadcaster banned or put in a timeout.
func get_banned_users(broadcaster_id, user_id, first, after, before) -> Dictionary:
	var response = await request("/moderation/banned", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Bans a user from participating in a broadcaster’s chat room or puts them in a timeout.
func ban_user(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/moderation/bans", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Removes the ban or timeout that was placed on the specified user.
func unban_user(broadcaster_id, moderator_id, user_id) -> void:
	var response = await request("/moderation/bans", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s list of non-private, blocked words or phrases.
func get_blocked_terms(broadcaster_id, moderator_id, first, after) -> Dictionary:
	var response = await request("/moderation/blocked_terms", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Adds a word or phrase to the broadcaster’s list of blocked terms.
func add_blocked_term(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/moderation/blocked_terms", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Removes the word or phrase from the broadcaster’s list of blocked terms.
func remove_blocked_term(broadcaster_id, moderator_id, id) -> void:
	var response = await request("/moderation/blocked_terms", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Removes a single chat message or all chat messages from the broadcaster’s chat room.
func delete_chat_messages(broadcaster_id, moderator_id, message_id) -> void:
	var response = await request("/moderation/chat", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of channels that the specified user has moderator privileges in.
func get_moderated_channels(user_id, after, first) -> Dictionary:
	var response = await request("/moderation/channels", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets all users allowed to moderate the broadcaster’s chat room.
func get_moderators(broadcaster_id, user_id, first, after) -> Dictionary:
	var response = await request("/moderation/moderators", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Adds a moderator to the broadcaster’s chat room.
func add_channel_moderator(broadcaster_id, user_id) -> void:
	var response = await request("/moderation/moderators", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Removes a moderator from the broadcaster’s chat room.
func remove_channel_moderator(broadcaster_id, user_id) -> void:
	var response = await request("/moderation/moderators", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of the broadcaster’s VIPs.
func get_vips(user_id, broadcaster_id, first, after) -> Dictionary:
	var response = await request("/channels/vips", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Adds the specified user as a VIP in the broadcaster’s channel.
func add_channel_vip(user_id, broadcaster_id) -> void:
	var response = await request("/channels/vips", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Removes the specified user as a VIP in the broadcaster’s channel.
func remove_channel_vip(user_id, broadcaster_id) -> void:
	var response = await request("/channels/vips", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Activates or deactivates the broadcaster’s Shield Mode.
func update_shield_mode_status(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/moderation/shield_mode", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s Shield Mode activation status.
func get_shield_mode_status(broadcaster_id, moderator_id) -> Dictionary:
	var response = await request("/moderation/shield_mode", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of polls that the broadcaster created.
func get_polls(broadcaster_id, id, first, after) -> Dictionary:
	var response = await request("/polls", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Creates a poll that viewers in the broadcaster’s channel can vote on.
func create_poll() -> Dictionary:
	var response = await request("/polls", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# End an active poll.
func end_poll() -> Dictionary:
	var response = await request("/polls", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of Channel Points Predictions that the broadcaster created.
func get_predictions(broadcaster_id, id, first, after) -> Dictionary:
	var response = await request("/predictions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Create a Channel Points Prediction.
func create_prediction() -> Dictionary:
	var response = await request("/predictions", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Locks, resolves, or cancels a Channel Points Prediction.
func end_prediction() -> Dictionary:
	var response = await request("/predictions", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Raid another channel by sending the broadcaster’s viewers to the targeted channel.
func start_a_raid(from_broadcaster_id, to_broadcaster_id) -> Dictionary:
	var response = await request("/raids", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Cancel a pending raid.
func cancel_a_raid(broadcaster_id) -> void:
	var response = await request("/raids", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s streaming schedule.
func get_channel_stream_schedule(broadcaster_id, id, start_time, utc_offset, first, after) -> Dictionary:
	var response = await request("/schedule", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the broadcaster’s streaming schedule as an iCalendar.
func get_channel_icalendar(broadcaster_id) -> Dictionary:
	var response = await request("/schedule/icalendar", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates the broadcaster’s schedule settings, such as scheduling a vacation.
func update_channel_stream_schedule(broadcaster_id, is_vacation_enabled, vacation_start_time, vacation_end_time, timezone) -> void:
	var response = await request("/schedule/settings", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Adds a single or recurring broadcast to the broadcaster’s streaming schedule.
func create_channel_stream_schedule_segment(broadcaster_id) -> Dictionary:
	var response = await request("/schedule/segment", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates a scheduled broadcast segment.
func update_channel_stream_schedule_segment(broadcaster_id, id) -> Dictionary:
	var response = await request("/schedule/segment", HTTPClient.METHOD_PATCH, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Deletes a broadcast from the broadcaster’s streaming schedule.
func delete_channel_stream_schedule_segment(broadcaster_id, id) -> void:
	var response = await request("/schedule/segment", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the games or categories that match the specified query.
func search_categories(query, first, after) -> Dictionary:
	var response = await request("/search/categories", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the channels that match the specified query and have streamed content within the past 6 months.
func search_channels(query, live_only, first, after) -> Dictionary:
	var response = await request("/search/channels", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the channel’s stream key.
func get_stream_key(broadcaster_id) -> Dictionary:
	var response = await request("/streams/key", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of all streams.
func get_streams(user_id, user_login, game_id, type, language, first, before, after) -> Dictionary:
	var response = await request("/streams", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the list of broadcasters that the user follows and that are streaming live.
func get_followed_streams(user_id, first, after) -> Dictionary:
	var response = await request("/streams/followed", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Adds a marker to a live stream.
func create_stream_marker() -> Dictionary:
	var response = await request("/streams/markers", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of markers from the user’s most recent stream or from the specified VOD/video.
func get_stream_markers(user_id, video_id, first, before, after) -> Dictionary:
	var response = await request("/streams/markers", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of users that subscribe to the specified broadcaster.
func get_broadcaster_subscriptions(broadcaster_id, user_id, first, after, before) -> Dictionary:
	var response = await request("/subscriptions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Checks whether the user subscribes to the broadcaster’s channel.
func check_user_subscription(broadcaster_id, user_id) -> Dictionary:
	var response = await request("/subscriptions/user", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the list of all stream tags that Twitch defines. You can also filter the list by one or more tag IDs.
func get_all_stream_tags(tag_id, first, after) -> Dictionary:
	var response = await request("/tags/streams", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the list of stream tags that the broadcaster or Twitch added to their channel.
func get_stream_tags(broadcaster_id) -> Dictionary:
	var response = await request("/streams/tags", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the list of Twitch teams that the broadcaster is a member of.
func get_channel_teams(broadcaster_id) -> Dictionary:
	var response = await request("/teams/channel", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about the specified Twitch team.
func get_teams(name, id) -> Dictionary:
	var response = await request("/teams", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about one or more users.
func get_users(id, login) -> Dictionary:
	var response = await request("/users", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates the user’s information.
func update_user(description) -> Dictionary:
	var response = await request("/users", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the list of users that the broadcaster has blocked.
func get_user_block_list(broadcaster_id, first, after) -> Dictionary:
	var response = await request("/users/blocks", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Blocks the specified user from interacting with or having contact with the broadcaster.
func block_user(target_user_id, source_context, reason) -> void:
	var response = await request("/users/blocks", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Removes the user from the broadcaster’s list of blocked users.
func unblock_user(target_user_id) -> void:
	var response = await request("/users/blocks", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets a list of all extensions (both active and inactive) that the broadcaster has installed.
func get_user_extensions() -> Dictionary:
	var response = await request("/users/extensions/list", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets the active extensions that the broadcaster has installed for each configuration.
func get_user_active_extensions(user_id) -> Dictionary:
	var response = await request("/users/extensions", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Updates an installed extension’s information.
func update_user_extensions() -> Dictionary:
	var response = await request("/users/extensions", HTTPClient.METHOD_PUT, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Gets information about one or more published videos.
func get_videos(id, user_id, game_id, language, period, sort, type, first, after, before) -> Dictionary:
	var response = await request("/videos", HTTPClient.METHOD_GET, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Deletes one or more videos.
func delete_videos(id) -> Dictionary:
	var response = await request("/videos", HTTPClient.METHOD_DELETE, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result

# Sends a whisper message to the specified user.
func send_whisper(from_user_id, to_user_id) -> void:
	var response = await request("/whispers", HTTPClient.METHOD_POST, {}, null)
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	return result
