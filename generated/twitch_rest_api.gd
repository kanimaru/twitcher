extends RefCounted

## Interaction with the Twitch REST API.
class_name TwitchRestAPI

## Maximal tries to reauthrorize before giving up the request.
const MAX_AUTH_ERRORS = 3;

var client: BufferedHTTPClient;
var auth: TwitchAuth;

func _init(twitch_auth: TwitchAuth) -> void:
	client = BufferedHTTPClient.new(TwitchSetting.api_host);
	auth = twitch_auth;

func request(path: String, method: int, body: Variant = "", content_type: String = "application/json", error_count: int = 0) -> BufferedHTTPClient.ResponseData:
	var header : Dictionary = {
		"Authorization": "Bearer %s" % [await auth.get_token()],
		"Client-ID": TwitchSetting.client_id,
		"Content-Type": content_type
	};

	var request_body: String = "";
	if body is Object && body.has_method("to_json"):
		request_body = body.to_json()
	else:
		request_body = JSON.stringify(body);

	var request = client.request(path, method, header, request_body)
	var response = await client.wait_for_request(request);

	# Token expired / or missing permissions
	if response.client.get_response_code() == 401 || response.client.get_response_code() == 403:
		await auth.login();
		if error_count + 1 < MAX_AUTH_ERRORS:
			return await request(path, method, body, content_type, error_count + 1);
		else:
			# Give up the request after trying multiple times and
			# return an empty response with correct error code
			var empty_response = client.empty_response(request);
			empty_response.response_code = response.client.get_response_code();
			return empty_response;
	return response;

## Starts a commercial on the specified channel.
##
## https://dev.twitch.tv/docs/api/reference#start-commercial
func start_commercial(body: TwitchStartCommercialBody) -> TwitchStartCommercialResponse:
	var path = "/helix/channels/commercial?"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchStartCommercialResponse.from_json(result);
{else}
	return response;


## Returns ad schedule related information.
##
## https://dev.twitch.tv/docs/api/reference#get-ad-schedule
func get_ad_schedule(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetAdScheduleResponse:
	var path = "/helix/channels/ads?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetAdScheduleResponse.from_json(result);
{else}
	return response;


## Pushes back the timestamp of the upcoming automatic mid-roll ad by 5 minutes.
##
## https://dev.twitch.tv/docs/api/reference#snooze-next-ad
func snooze_next_ad(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchSnoozeNextAdResponse:
	var path = "/helix/channels/ads/schedule/snooze?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchSnoozeNextAdResponse.from_json(result);
{else}
	return response;


## Gets an analytics report for one or more extensions.
##
## https://dev.twitch.tv/docs/api/reference#get-extension-analytics
func get_extension_analytics(extension_id: String, type: String, started_at: Variant, ended_at: Variant, first: int, after: String) -> TwitchGetExtensionAnalyticsResponse:
	var path = "/helix/analytics/extensions?"
	path += "started_at=" + get_rfc_3339_date_format(started_at) + "&"
	path += "ended_at=" + get_rfc_3339_date_format(ended_at) + "&"
	path += "extension_id=" + str(extension_id) + "&"
	path += "type=" + str(type) + "&"
	path += "started_at=" + str(started_at) + "&"
	path += "ended_at=" + str(ended_at) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetExtensionAnalyticsResponse.from_json(result);
{else}
	return response;


## Gets an analytics report for one or more games.
##
## https://dev.twitch.tv/docs/api/reference#get-game-analytics
func get_game_analytics(game_id: String, type: String, started_at: Variant, ended_at: Variant, first: int, after: String) -> TwitchGetGameAnalyticsResponse:
	var path = "/helix/analytics/games?"
	path += "started_at=" + get_rfc_3339_date_format(started_at) + "&"
	path += "ended_at=" + get_rfc_3339_date_format(ended_at) + "&"
	path += "game_id=" + str(game_id) + "&"
	path += "type=" + str(type) + "&"
	path += "started_at=" + str(started_at) + "&"
	path += "ended_at=" + str(ended_at) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetGameAnalyticsResponse.from_json(result);
{else}
	return response;


## Gets the Bits leaderboard for the authenticated broadcaster.
##
## https://dev.twitch.tv/docs/api/reference#get-bits-leaderboard
func get_bits_leaderboard(count: int, period: String, started_at: Variant, user_id: String) -> TwitchGetBitsLeaderboardResponse:
	var path = "/helix/bits/leaderboard?"
	path += "started_at=" + get_rfc_3339_date_format(started_at) + "&"
	path += "count=" + str(count) + "&"
	path += "period=" + str(period) + "&"
	path += "started_at=" + str(started_at) + "&"
	path += "user_id=" + str(user_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetBitsLeaderboardResponse.from_json(result);
{else}
	return response;


## Gets a list of Cheermotes that users can use to cheer Bits.
##
## https://dev.twitch.tv/docs/api/reference#get-cheermotes
func get_cheermotes(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetCheermotesResponse:
	var path = "/helix/bits/cheermotes?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetCheermotesResponse.from_json(result);
{else}
	return response;


## Gets an extension’s list of transactions.
##
## https://dev.twitch.tv/docs/api/reference#get-extension-transactions
func get_extension_transactions(extension_id: String, id: Array[String], first: int, after: String) -> TwitchGetExtensionTransactionsResponse:
	var path = "/helix/extensions/transactions?"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "extension_id=" + str(extension_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetExtensionTransactionsResponse.from_json(result);
{else}
	return response;


## Gets information about one or more channels.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-information
func get_channel_information(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChannelInformationResponse:
	var path = "/helix/channels?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChannelInformationResponse.from_json(result);
{else}
	return response;


## Updates a channel’s properties.
##
## https://dev.twitch.tv/docs/api/reference#modify-channel-information
func modify_channel_information(body: TwitchModifyChannelInformationBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/channels?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);


## Gets the broadcaster’s list editors.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-editors
func get_channel_editors(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChannelEditorsResponse:
	var path = "/helix/channels/editors?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChannelEditorsResponse.from_json(result);
{else}
	return response;


## Gets a list of broadcasters that the specified user follows. You can also use this endpoint to see whether a user follows a specific broadcaster.
##
## https://dev.twitch.tv/docs/api/reference#get-followed-channels
func get_followed_channels(user_id: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetFollowedChannelsResponse:
	var path = "/helix/channels/followed?"
	path += "user_id=" + str(user_id) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetFollowedChannelsResponse.from_json(result);
{else}
	return response;


## Gets a list of users that follow the specified broadcaster. You can also use this endpoint to see whether a specific user follows the broadcaster.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-followers
func get_channel_followers(user_id: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChannelFollowersResponse:
	var path = "/helix/channels/followers?"
	path += "user_id=" + str(user_id) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChannelFollowersResponse.from_json(result);
{else}
	return response;


## Creates a Custom Reward in the broadcaster’s channel.
##
## https://dev.twitch.tv/docs/api/reference#create-custom-rewards
func create_custom_rewards(body: TwitchCreateCustomRewardsBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchCreateCustomRewardsResponse:
	var path = "/helix/channel_points/custom_rewards?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCreateCustomRewardsResponse.from_json(result);
{else}
	return response;


## Deletes a custom reward that the broadcaster created.
##
## https://dev.twitch.tv/docs/api/reference#delete-custom-reward
func delete_custom_reward(id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/channel_points/custom_rewards?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "id=" + str(id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Gets a list of custom rewards that the specified broadcaster created.
##
## https://dev.twitch.tv/docs/api/reference#get-custom-reward
func get_custom_reward(id: Array[String], only_manageable_rewards: bool, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetCustomRewardResponse:
	var path = "/helix/channel_points/custom_rewards?"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "only_manageable_rewards=" + str(only_manageable_rewards) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetCustomRewardResponse.from_json(result);
{else}
	return response;


## Updates a custom reward.
##
## https://dev.twitch.tv/docs/api/reference#update-custom-reward
func update_custom_reward(id: String, body: TwitchUpdateCustomRewardBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchUpdateCustomRewardResponse:
	var path = "/helix/channel_points/custom_rewards?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "id=" + str(id) + "&"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateCustomRewardResponse.from_json(result);
{else}
	return response;


## Gets a list of redemptions for a custom reward.
##
## https://dev.twitch.tv/docs/api/reference#get-custom-reward-redemption
func get_custom_reward_redemption(reward_id: String, status: String, id: Array[String], sort: String, after: String, first: int, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetCustomRewardRedemptionResponse:
	var path = "/helix/channel_points/custom_rewards/redemptions?"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "reward_id=" + str(reward_id) + "&"
	path += "status=" + str(status) + "&"
	path += "sort=" + str(sort) + "&"
	path += "after=" + str(after) + "&"
	path += "first=" + str(first) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetCustomRewardRedemptionResponse.from_json(result);
{else}
	return response;


## Updates a redemption’s status.
##
## https://dev.twitch.tv/docs/api/reference#update-redemption-status
func update_redemption_status(id: Array[String], reward_id: String, body: TwitchUpdateRedemptionStatusBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchUpdateRedemptionStatusResponse:
	var path = "/helix/channel_points/custom_rewards/redemptions?"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "reward_id=" + str(reward_id) + "&"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateRedemptionStatusResponse.from_json(result);
{else}
	return response;


## Gets information about the broadcaster’s active charity campaign.
##
## https://dev.twitch.tv/docs/api/reference#get-charity-campaign
func get_charity_campaign(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetCharityCampaignResponse:
	var path = "/helix/charity/campaigns?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetCharityCampaignResponse.from_json(result);
{else}
	return response;


## Gets the list of donations that users have made to the broadcaster’s active charity campaign.
##
## https://dev.twitch.tv/docs/api/reference#get-charity-campaign-donations
func get_charity_campaign_donations(first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetCharityCampaignDonationsResponse:
	var path = "/helix/charity/donations?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetCharityCampaignDonationsResponse.from_json(result);
{else}
	return response;


## Gets the list of users that are connected to the broadcaster’s chat session.
##
## https://dev.twitch.tv/docs/api/reference#get-chatters
func get_chatters(moderator_id: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChattersResponse:
	var path = "/helix/chat/chatters?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChattersResponse.from_json(result);
{else}
	return response;


## Gets the broadcaster’s list of custom emotes.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-emotes
func get_channel_emotes(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChannelEmotesResponse:
	var path = "/helix/chat/emotes?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChannelEmotesResponse.from_json(result);
{else}
	return response;


## Gets all global emotes.
##
## https://dev.twitch.tv/docs/api/reference#get-global-emotes
func get_global_emotes() -> TwitchGetGlobalEmotesResponse:
	var path = "/helix/chat/emotes/global?"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetGlobalEmotesResponse.from_json(result);
{else}
	return response;


## Gets emotes for one or more specified emote sets.
##
## https://dev.twitch.tv/docs/api/reference#get-emote-sets
func get_emote_sets(emote_set_id: Array[String]) -> TwitchGetEmoteSetsResponse:
	var path = "/helix/chat/emotes/set?"
	for param in emote_set_id:
		path += "emote_set_id=" + str(param) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetEmoteSetsResponse.from_json(result);
{else}
	return response;


## Gets the broadcaster’s list of custom chat badges.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-chat-badges
func get_channel_chat_badges(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChannelChatBadgesResponse:
	var path = "/helix/chat/badges?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChannelChatBadgesResponse.from_json(result);
{else}
	return response;


## Gets Twitch’s list of chat badges.
##
## https://dev.twitch.tv/docs/api/reference#get-global-chat-badges
func get_global_chat_badges() -> TwitchGetGlobalChatBadgesResponse:
	var path = "/helix/chat/badges/global?"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetGlobalChatBadgesResponse.from_json(result);
{else}
	return response;


## Gets the broadcaster’s chat settings.
##
## https://dev.twitch.tv/docs/api/reference#get-chat-settings
func get_chat_settings(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChatSettingsResponse:
	var path = "/helix/chat/settings?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChatSettingsResponse.from_json(result);
{else}
	return response;


## Updates the broadcaster’s chat settings.
##
## https://dev.twitch.tv/docs/api/reference#update-chat-settings
func update_chat_settings(moderator_id: String, body: TwitchUpdateChatSettingsBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchUpdateChatSettingsResponse:
	var path = "/helix/chat/settings?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateChatSettingsResponse.from_json(result);
{else}
	return response;


## Sends an announcement to the broadcaster’s chat room.
##
## https://dev.twitch.tv/docs/api/reference#send-chat-announcement
func send_chat_announcement(moderator_id: String, body: TwitchSendChatAnnouncementBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/chat/announcements?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, body);


## Sends a Shoutout to the specified broadcaster.
##
## https://dev.twitch.tv/docs/api/reference#send-a-shoutout
func send_a_shoutout(from_broadcaster_id: String, to_broadcaster_id: String, moderator_id: String) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/chat/shoutouts?"
	path += "from_broadcaster_id=" + str(from_broadcaster_id) + "&"
	path += "to_broadcaster_id=" + str(to_broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");


## NEW Sends a message to the broadcaster’s chat room.
##
## https://dev.twitch.tv/docs/api/reference#send-chat-message
func send_chat_message(body: TwitchSendChatMessageBody) -> TwitchSendChatMessageResponse:
	var path = "/helix/chat/messages?"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchSendChatMessageResponse.from_json(result);
{else}
	return response;


## Gets the color used for the user’s name in chat.
##
## https://dev.twitch.tv/docs/api/reference#get-user-chat-color
func get_user_chat_color(user_id: Array[String]) -> TwitchGetUserChatColorResponse:
	var path = "/helix/chat/color?"
	for param in user_id:
		path += "user_id=" + str(param) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetUserChatColorResponse.from_json(result);
{else}
	return response;


## Updates the color used for the user’s name in chat.
##
## https://dev.twitch.tv/docs/api/reference#update-user-chat-color
func update_user_chat_color(user_id: String, color: String) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/chat/color?"
	path += "user_id=" + str(user_id) + "&"
	path += "color=" + str(color) + "&"
	var response = await request(path, HTTPClient.METHOD_PUT, "");


## Creates a clip from the broadcaster’s stream.
##
## https://dev.twitch.tv/docs/api/reference#create-clip
func create_clip(has_delay: bool, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/clips?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "has_delay=" + str(has_delay) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");


## Gets one or more video clips.
##
## https://dev.twitch.tv/docs/api/reference#get-clips
func get_clips(game_id: String, id: Array[String], started_at: Variant, ended_at: Variant, first: int, before: String, after: String, is_featured: bool, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetClipsResponse:
	var path = "/helix/clips?"
	path += "started_at=" + get_rfc_3339_date_format(started_at) + "&"
	path += "ended_at=" + get_rfc_3339_date_format(ended_at) + "&"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "game_id=" + str(game_id) + "&"
	path += "started_at=" + str(started_at) + "&"
	path += "ended_at=" + str(ended_at) + "&"
	path += "first=" + str(first) + "&"
	path += "before=" + str(before) + "&"
	path += "after=" + str(after) + "&"
	path += "is_featured=" + str(is_featured) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetClipsResponse.from_json(result);
{else}
	return response;


## NEW  Gets the conduits for a client ID.
##
## https://dev.twitch.tv/docs/api/reference#get-conduits
func get_conduits() -> TwitchGetConduitsResponse:
	var path = "/helix/eventsub/conduits?"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetConduitsResponse.from_json(result);
{else}
	return response;


## NEW Creates a new conduit.
##
## https://dev.twitch.tv/docs/api/reference#create-conduits
func create_conduits(body: TwitchCreateConduitsBody) -> TwitchCreateConduitsResponse:
	var path = "/helix/eventsub/conduits?"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCreateConduitsResponse.from_json(result);
{else}
	return response;


## NEW Updates a conduit’s shard count.
##
## https://dev.twitch.tv/docs/api/reference#update-conduits
func update_conduits(body: TwitchUpdateConduitsBody) -> TwitchUpdateConduitsResponse:
	var path = "/helix/eventsub/conduits?"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateConduitsResponse.from_json(result);
{else}
	return response;


## NEW Deletes a specified conduit.
##
## https://dev.twitch.tv/docs/api/reference#delete-conduit
func delete_conduit(id: String) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/eventsub/conduits?"
	path += "id=" + str(id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## NEW Gets a lists of all shards for a conduit.
##
## https://dev.twitch.tv/docs/api/reference#get-conduit-shards
func get_conduit_shards(conduit_id: String, status: String, after: String) -> TwitchGetConduitShardsResponse:
	var path = "/helix/eventsub/conduits/shards?"
	path += "conduit_id=" + str(conduit_id) + "&"
	path += "status=" + str(status) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetConduitShardsResponse.from_json(result);
{else}
	return response;


## NEW Updates shard(s) for a conduit.
##
## https://dev.twitch.tv/docs/api/reference#update-conduit-shards
func update_conduit_shards(body: TwitchUpdateConduitShardsBody) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/eventsub/conduits/shards?"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);


## Gets information about Twitch content classification labels.
##
## https://dev.twitch.tv/docs/api/reference#get-content-classification-labels
func get_content_classification_labels(locale: String) -> TwitchGetContentClassificationLabelsResponse:
	var path = "/helix/content_classification_labels?"
	path += "locale=" + str(locale) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetContentClassificationLabelsResponse.from_json(result);
{else}
	return response;


## Gets an organization’s list of entitlements that have been granted to a game, a user, or both.
##
## https://dev.twitch.tv/docs/api/reference#get-drops-entitlements
func get_drops_entitlements(id: Array[String], user_id: String, game_id: String, fulfillment_status: String, after: String, first: int) -> TwitchGetDropsEntitlementsResponse:
	var path = "/helix/entitlements/drops?"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "user_id=" + str(user_id) + "&"
	path += "game_id=" + str(game_id) + "&"
	path += "fulfillment_status=" + str(fulfillment_status) + "&"
	path += "after=" + str(after) + "&"
	path += "first=" + str(first) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetDropsEntitlementsResponse.from_json(result);
{else}
	return response;


## Updates the Drop entitlement’s fulfillment status.
##
## https://dev.twitch.tv/docs/api/reference#update-drops-entitlements
func update_drops_entitlements(body: TwitchUpdateDropsEntitlementsBody) -> TwitchUpdateDropsEntitlementsResponse:
	var path = "/helix/entitlements/drops?"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateDropsEntitlementsResponse.from_json(result);
{else}
	return response;


## Gets the specified configuration segment from the specified extension.
##
## https://dev.twitch.tv/docs/api/reference#get-extension-configuration-segment
func get_extension_configuration_segment(extension_id: String, segment: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetExtensionConfigurationSegmentResponse:
	var path = "/helix/extensions/configurations?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "extension_id=" + str(extension_id) + "&"
	path += "segment=" + str(segment) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetExtensionConfigurationSegmentResponse.from_json(result);
{else}
	return response;


## Updates a configuration segment.
##
## https://dev.twitch.tv/docs/api/reference#set-extension-configuration-segment
func set_extension_configuration_segment(body: TwitchSetExtensionConfigurationSegmentBody) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/extensions/configurations?"
	var response = await request(path, HTTPClient.METHOD_PUT, body);


## Updates the extension’s required_configuration string.
##
## https://dev.twitch.tv/docs/api/reference#set-extension-required-configuration
func set_extension_required_configuration(body: TwitchSetExtensionRequiredConfigurationBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/extensions/required_configuration?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_PUT, body);


## Sends a message to one or more viewers.
##
## https://dev.twitch.tv/docs/api/reference#send-extension-pubsub-message
func send_extension_pubsub_message(body: TwitchSendExtensionPubSubMessageBody) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/extensions/pubsub?"
	var response = await request(path, HTTPClient.METHOD_POST, body);


## Gets a list of broadcasters that are streaming live and have installed or activated the extension.
##
## https://dev.twitch.tv/docs/api/reference#get-extension-live-channels
func get_extension_live_channels(extension_id: String, first: int, after: String) -> TwitchGetExtensionLiveChannelsResponse:
	var path = "/helix/extensions/live?"
	path += "extension_id=" + str(extension_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetExtensionLiveChannelsResponse.from_json(result);
{else}
	return response;


## Gets an extension’s list of shared secrets.
##
## https://dev.twitch.tv/docs/api/reference#get-extension-secrets
func get_extension_secrets() -> TwitchGetExtensionSecretsResponse:
	var path = "/helix/extensions/jwt/secrets?"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetExtensionSecretsResponse.from_json(result);
{else}
	return response;


## Creates a shared secret used to sign and verify JWT tokens.
##
## https://dev.twitch.tv/docs/api/reference#create-extension-secret
func create_extension_secret(extension_id: String, delay: int) -> TwitchCreateExtensionSecretResponse:
	var path = "/helix/extensions/jwt/secrets?"
	path += "extension_id=" + str(extension_id) + "&"
	path += "delay=" + str(delay) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCreateExtensionSecretResponse.from_json(result);
{else}
	return response;


## Sends a message to the specified broadcaster’s chat room.
##
## https://dev.twitch.tv/docs/api/reference#send-extension-chat-message
func send_extension_chat_message(body: TwitchSendExtensionChatMessageBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/extensions/chat?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, body);


## Gets information about an extension.
##
## https://dev.twitch.tv/docs/api/reference#get-extensions
func get_extensions(extension_id: String, extension_version: String) -> TwitchGetExtensionsResponse:
	var path = "/helix/extensions?"
	path += "extension_id=" + str(extension_id) + "&"
	path += "extension_version=" + str(extension_version) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetExtensionsResponse.from_json(result);
{else}
	return response;


## Gets information about a released extension.
##
## https://dev.twitch.tv/docs/api/reference#get-released-extensions
func get_released_extensions(extension_id: String, extension_version: String) -> TwitchGetReleasedExtensionsResponse:
	var path = "/helix/extensions/released?"
	path += "extension_id=" + str(extension_id) + "&"
	path += "extension_version=" + str(extension_version) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetReleasedExtensionsResponse.from_json(result);
{else}
	return response;


## Gets the list of Bits products that belongs to the extension.
##
## https://dev.twitch.tv/docs/api/reference#get-extension-bits-products
func get_extension_bits_products(should_include_all: bool) -> TwitchGetExtensionBitsProductsResponse:
	var path = "/helix/bits/extensions?"
	path += "should_include_all=" + str(should_include_all) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetExtensionBitsProductsResponse.from_json(result);
{else}
	return response;


## Adds or updates a Bits product that the extension created.
##
## https://dev.twitch.tv/docs/api/reference#update-extension-bits-product
func update_extension_bits_product(body: TwitchUpdateExtensionBitsProductBody) -> TwitchUpdateExtensionBitsProductResponse:
	var path = "/helix/bits/extensions?"
	var response = await request(path, HTTPClient.METHOD_PUT, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateExtensionBitsProductResponse.from_json(result);
{else}
	return response;


## Creates an EventSub subscription.
##
## https://dev.twitch.tv/docs/api/reference#create-eventsub-subscription
func create_eventsub_subscription(body: TwitchCreateEventSubSubscriptionBody) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/eventsub/subscriptions?"
	var response = await request(path, HTTPClient.METHOD_POST, body);


## Deletes an EventSub subscription.
##
## https://dev.twitch.tv/docs/api/reference#delete-eventsub-subscription
func delete_eventsub_subscription(id: String) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/eventsub/subscriptions?"
	path += "id=" + str(id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Gets a list of EventSub subscriptions that the client in the access token created.
##
## https://dev.twitch.tv/docs/api/reference#get-eventsub-subscriptions
func get_eventsub_subscriptions(status: String, type: String, user_id: String, after: String) -> TwitchGetEventSubSubscriptionsResponse:
	var path = "/helix/eventsub/subscriptions?"
	path += "status=" + str(status) + "&"
	path += "type=" + str(type) + "&"
	path += "user_id=" + str(user_id) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetEventSubSubscriptionsResponse.from_json(result);
{else}
	return response;


## Gets information about all broadcasts on Twitch.
##
## https://dev.twitch.tv/docs/api/reference#get-top-games
func get_top_games(first: int, after: String, before: String) -> TwitchGetTopGamesResponse:
	var path = "/helix/games/top?"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	path += "before=" + str(before) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetTopGamesResponse.from_json(result);
{else}
	return response;


## Gets information about specified games.
##
## https://dev.twitch.tv/docs/api/reference#get-games
func get_games(id: Array[String], name: Array[String], igdb_id: Array[String]) -> TwitchGetGamesResponse:
	var path = "/helix/games?"
	for param in id:
		path += "id=" + str(param) + "&"
	for param in name:
		path += "name=" + str(param) + "&"
	for param in igdb_id:
		path += "igdb_id=" + str(param) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetGamesResponse.from_json(result);
{else}
	return response;


## Gets the broadcaster’s list of active goals.
##
## https://dev.twitch.tv/docs/api/reference#get-creator-goals
func get_creator_goals(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetCreatorGoalsResponse:
	var path = "/helix/goals?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetCreatorGoalsResponse.from_json(result);
{else}
	return response;


## BETA Gets the channel settings for configuration of the Guest Star feature for a particular host.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-guest-star-settings
func get_channel_guest_star_settings(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChannelGuestStarSettingsResponse:
	var path = "/helix/guest_star/channel_settings?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChannelGuestStarSettingsResponse.from_json(result);
{else}
	return response;


## BETA Mutates the channel settings for configuration of the Guest Star feature for a particular host.
##
## https://dev.twitch.tv/docs/api/reference#update-channel-guest-star-settings
func update_channel_guest_star_settings(body: TwitchUpdateChannelGuestStarSettingsBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/guest_star/channel_settings?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_PUT, body);


## BETA Gets information about an ongoing Guest Star session for a particular channel.
##
## https://dev.twitch.tv/docs/api/reference#get-guest-star-session
func get_guest_star_session(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetGuestStarSessionResponse:
	var path = "/helix/guest_star/session?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetGuestStarSessionResponse.from_json(result);
{else}
	return response;


## BETA Programmatically creates a Guest Star session on behalf of the broadcaster.
##
## https://dev.twitch.tv/docs/api/reference#create-guest-star-session
func create_guest_star_session(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchCreateGuestStarSessionResponse:
	var path = "/helix/guest_star/session?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCreateGuestStarSessionResponse.from_json(result);
{else}
	return response;


## BETA Programmatically ends a Guest Star session on behalf of the broadcaster.
##
## https://dev.twitch.tv/docs/api/reference#end-guest-star-session
func end_guest_star_session(session_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/guest_star/session?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "session_id=" + str(session_id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## BETA Provides the caller with a list of pending invites to a Guest Star session.
##
## https://dev.twitch.tv/docs/api/reference#get-guest-star-invites
func get_guest_star_invites(moderator_id: String, session_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetGuestStarInvitesResponse:
	var path = "/helix/guest_star/invites?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "session_id=" + str(session_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetGuestStarInvitesResponse.from_json(result);
{else}
	return response;


## BETA Sends an invite to a specified guest on behalf of the broadcaster for a Guest Star session in progress.
##
## https://dev.twitch.tv/docs/api/reference#send-guest-star-invite
func send_guest_star_invite(moderator_id: String, session_id: String, guest_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/guest_star/invites?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "session_id=" + str(session_id) + "&"
	path += "guest_id=" + str(guest_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");


## BETA Revokes a previously sent invite for a Guest Star session.
##
## https://dev.twitch.tv/docs/api/reference#delete-guest-star-invite
func delete_guest_star_invite(moderator_id: String, session_id: String, guest_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/guest_star/invites?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "session_id=" + str(session_id) + "&"
	path += "guest_id=" + str(guest_id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## BETA Allows a previously invited user to be assigned a slot within the active Guest Star session.
##
## https://dev.twitch.tv/docs/api/reference#assign-guest-star-slot
func assign_guest_star_slot(moderator_id: String, session_id: String, guest_id: String, slot_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/guest_star/slot?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "session_id=" + str(session_id) + "&"
	path += "guest_id=" + str(guest_id) + "&"
	path += "slot_id=" + str(slot_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");


## BETA Allows a user to update the assigned slot for a particular user within the active Guest Star session.
##
## https://dev.twitch.tv/docs/api/reference#update-guest-star-slot
func update_guest_star_slot(moderator_id: String, session_id: String, source_slot_id: String, destination_slot_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/guest_star/slot?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "session_id=" + str(session_id) + "&"
	path += "source_slot_id=" + str(source_slot_id) + "&"
	path += "destination_slot_id=" + str(destination_slot_id) + "&"
	var response = await request(path, HTTPClient.METHOD_PATCH, "");


## BETA Allows a caller to remove a slot assignment from a user participating in an active Guest Star session.
##
## https://dev.twitch.tv/docs/api/reference#delete-guest-star-slot
func delete_guest_star_slot(moderator_id: String, session_id: String, guest_id: String, slot_id: String, should_reinvite_guest: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/guest_star/slot?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "session_id=" + str(session_id) + "&"
	path += "guest_id=" + str(guest_id) + "&"
	path += "slot_id=" + str(slot_id) + "&"
	path += "should_reinvite_guest=" + str(should_reinvite_guest) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## BETA Allows a user to update slot settings for a particular guest within a Guest Star session.
##
## https://dev.twitch.tv/docs/api/reference#update-guest-star-slot-settings
func update_guest_star_slot_settings(moderator_id: String, session_id: String, slot_id: String, is_audio_enabled: bool, is_video_enabled: bool, is_live: bool, volume: int, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/guest_star/slot_settings?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "session_id=" + str(session_id) + "&"
	path += "slot_id=" + str(slot_id) + "&"
	path += "is_audio_enabled=" + str(is_audio_enabled) + "&"
	path += "is_video_enabled=" + str(is_video_enabled) + "&"
	path += "is_live=" + str(is_live) + "&"
	path += "volume=" + str(volume) + "&"
	var response = await request(path, HTTPClient.METHOD_PATCH, "");


## Gets information about the broadcaster’s current or most recent Hype Train event.
##
## https://dev.twitch.tv/docs/api/reference#get-hype-train-events
func get_hype_train_events(first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetHypeTrainEventsResponse:
	var path = "/helix/hypetrain/events?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetHypeTrainEventsResponse.from_json(result);
{else}
	return response;


## Checks whether AutoMod would flag the specified message for review.
##
## https://dev.twitch.tv/docs/api/reference#check-automod-status
func check_automod_status(body: TwitchCheckAutoModStatusBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchCheckAutoModStatusResponse:
	var path = "/helix/moderation/enforcements/status?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCheckAutoModStatusResponse.from_json(result);
{else}
	return response;


## Allow or deny the message that AutoMod flagged for review.
##
## https://dev.twitch.tv/docs/api/reference#manage-held-automod-messages
func manage_held_automod_messages(body: TwitchManageHeldAutoModMessagesBody) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/moderation/automod/message?"
	var response = await request(path, HTTPClient.METHOD_POST, body);


## Gets the broadcaster’s AutoMod settings.
##
## https://dev.twitch.tv/docs/api/reference#get-automod-settings
func get_automod_settings(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetAutoModSettingsResponse:
	var path = "/helix/moderation/automod/settings?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetAutoModSettingsResponse.from_json(result);
{else}
	return response;


## Updates the broadcaster’s AutoMod settings.
##
## https://dev.twitch.tv/docs/api/reference#update-automod-settings
func update_automod_settings(moderator_id: String, body: TwitchUpdateAutoModSettingsBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchUpdateAutoModSettingsResponse:
	var path = "/helix/moderation/automod/settings?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_PUT, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateAutoModSettingsResponse.from_json(result);
{else}
	return response;


## Gets all users that the broadcaster banned or put in a timeout.
##
## https://dev.twitch.tv/docs/api/reference#get-banned-users
func get_banned_users(user_id: Array[String], first: int, after: String, before: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetBannedUsersResponse:
	var path = "/helix/moderation/banned?"
	for param in user_id:
		path += "user_id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	path += "before=" + str(before) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetBannedUsersResponse.from_json(result);
{else}
	return response;


## Bans a user from participating in a broadcaster’s chat room or puts them in a timeout.
##
## https://dev.twitch.tv/docs/api/reference#ban-user
func ban_user(moderator_id: String, body: TwitchBanUserBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchBanUserResponse:
	var path = "/helix/moderation/bans?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchBanUserResponse.from_json(result);
{else}
	return response;


## Removes the ban or timeout that was placed on the specified user.
##
## https://dev.twitch.tv/docs/api/reference#unban-user
func unban_user(moderator_id: String, user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/moderation/bans?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "user_id=" + str(user_id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Gets the broadcaster’s list of non-private, blocked words or phrases.
##
## https://dev.twitch.tv/docs/api/reference#get-blocked-terms
func get_blocked_terms(moderator_id: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetBlockedTermsResponse:
	var path = "/helix/moderation/blocked_terms?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetBlockedTermsResponse.from_json(result);
{else}
	return response;


## Adds a word or phrase to the broadcaster’s list of blocked terms.
##
## https://dev.twitch.tv/docs/api/reference#add-blocked-term
func add_blocked_term(moderator_id: String, body: TwitchAddBlockedTermBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchAddBlockedTermResponse:
	var path = "/helix/moderation/blocked_terms?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchAddBlockedTermResponse.from_json(result);
{else}
	return response;


## Removes the word or phrase from the broadcaster’s list of blocked terms.
##
## https://dev.twitch.tv/docs/api/reference#remove-blocked-term
func remove_blocked_term(moderator_id: String, id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/moderation/blocked_terms?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "id=" + str(id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Removes a single chat message or all chat messages from the broadcaster’s chat room.
##
## https://dev.twitch.tv/docs/api/reference#delete-chat-messages
func delete_chat_messages(moderator_id: String, message_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/moderation/chat?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	path += "message_id=" + str(message_id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Gets a list of channels that the specified user has moderator privileges in.
##
## https://dev.twitch.tv/docs/api/reference#get-moderated-channels
func get_moderated_channels(user_id: String, after: String, first: int) -> TwitchGetModeratedChannelsResponse:
	var path = "/helix/moderation/channels?"
	path += "user_id=" + str(user_id) + "&"
	path += "after=" + str(after) + "&"
	path += "first=" + str(first) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetModeratedChannelsResponse.from_json(result);
{else}
	return response;


## Gets all users allowed to moderate the broadcaster’s chat room.
##
## https://dev.twitch.tv/docs/api/reference#get-moderators
func get_moderators(user_id: Array[String], first: String, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetModeratorsResponse:
	var path = "/helix/moderation/moderators?"
	for param in user_id:
		path += "user_id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetModeratorsResponse.from_json(result);
{else}
	return response;


## Adds a moderator to the broadcaster’s chat room.
##
## https://dev.twitch.tv/docs/api/reference#add-channel-moderator
func add_channel_moderator(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/moderation/moderators?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "user_id=" + str(user_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");


## Removes a moderator from the broadcaster’s chat room.
##
## https://dev.twitch.tv/docs/api/reference#remove-channel-moderator
func remove_channel_moderator(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/moderation/moderators?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "user_id=" + str(user_id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Gets a list of the broadcaster’s VIPs.
##
## https://dev.twitch.tv/docs/api/reference#get-vips
func get_vips(user_id: Array[String], first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetVIPsResponse:
	var path = "/helix/channels/vips?"
	for param in user_id:
		path += "user_id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetVIPsResponse.from_json(result);
{else}
	return response;


## Adds the specified user as a VIP in the broadcaster’s channel.
##
## https://dev.twitch.tv/docs/api/reference#add-channel-vip
func add_channel_vip(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/channels/vips?"
	path += "user_id=" + str(user_id) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");


## Removes the specified user as a VIP in the broadcaster’s channel.
##
## https://dev.twitch.tv/docs/api/reference#remove-channel-vip
func remove_channel_vip(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/channels/vips?"
	path += "user_id=" + str(user_id) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Activates or deactivates the broadcaster’s Shield Mode.
##
## https://dev.twitch.tv/docs/api/reference#update-shield-mode-status
func update_shield_mode_status(moderator_id: String, body: TwitchUpdateShieldModeStatusBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchUpdateShieldModeStatusResponse:
	var path = "/helix/moderation/shield_mode?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_PUT, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateShieldModeStatusResponse.from_json(result);
{else}
	return response;


## Gets the broadcaster’s Shield Mode activation status.
##
## https://dev.twitch.tv/docs/api/reference#get-shield-mode-status
func get_shield_mode_status(moderator_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetShieldModeStatusResponse:
	var path = "/helix/moderation/shield_mode?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "moderator_id=" + str(moderator_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetShieldModeStatusResponse.from_json(result);
{else}
	return response;


## Gets a list of polls that the broadcaster created.
##
## https://dev.twitch.tv/docs/api/reference#get-polls
func get_polls(id: Array[String], first: String, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetPollsResponse:
	var path = "/helix/polls?"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetPollsResponse.from_json(result);
{else}
	return response;


## Creates a poll that viewers in the broadcaster’s channel can vote on.
##
## https://dev.twitch.tv/docs/api/reference#create-poll
func create_poll(body: TwitchCreatePollBody) -> TwitchCreatePollResponse:
	var path = "/helix/polls?"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCreatePollResponse.from_json(result);
{else}
	return response;


## End an active poll.
##
## https://dev.twitch.tv/docs/api/reference#end-poll
func end_poll(body: TwitchEndPollBody) -> TwitchEndPollResponse:
	var path = "/helix/polls?"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchEndPollResponse.from_json(result);
{else}
	return response;


## Gets a list of Channel Points Predictions that the broadcaster created.
##
## https://dev.twitch.tv/docs/api/reference#get-predictions
func get_predictions(id: Array[String], first: String, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetPredictionsResponse:
	var path = "/helix/predictions?"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetPredictionsResponse.from_json(result);
{else}
	return response;


## Create a Channel Points Prediction.
##
## https://dev.twitch.tv/docs/api/reference#create-prediction
func create_prediction(body: TwitchCreatePredictionBody) -> TwitchCreatePredictionResponse:
	var path = "/helix/predictions?"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCreatePredictionResponse.from_json(result);
{else}
	return response;


## Locks, resolves, or cancels a Channel Points Prediction.
##
## https://dev.twitch.tv/docs/api/reference#end-prediction
func end_prediction(body: TwitchEndPredictionBody) -> TwitchEndPredictionResponse:
	var path = "/helix/predictions?"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchEndPredictionResponse.from_json(result);
{else}
	return response;


## Raid another channel by sending the broadcaster’s viewers to the targeted channel.
##
## https://dev.twitch.tv/docs/api/reference#start-a-raid
func start_a_raid(from_broadcaster_id: String, to_broadcaster_id: String) -> TwitchStartRaidResponse:
	var path = "/helix/raids?"
	path += "from_broadcaster_id=" + str(from_broadcaster_id) + "&"
	path += "to_broadcaster_id=" + str(to_broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchStartRaidResponse.from_json(result);
{else}
	return response;


## Cancel a pending raid.
##
## https://dev.twitch.tv/docs/api/reference#cancel-a-raid
func cancel_a_raid(broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/raids?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Gets the broadcaster’s streaming schedule.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-stream-schedule
func get_channel_stream_schedule(id: Array[String], start_time: Variant, utc_offset: String, first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChannelStreamScheduleResponse:
	var path = "/helix/schedule?"
	path += "start_time=" + get_rfc_3339_date_format(start_time) + "&"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "start_time=" + str(start_time) + "&"
	path += "utc_offset=" + str(utc_offset) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChannelStreamScheduleResponse.from_json(result);
{else}
	return response;


## Gets the broadcaster’s streaming schedule as an iCalendar.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-icalendar
func get_channel_icalendar(broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/schedule/icalendar?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");


## Updates the broadcaster’s schedule settings, such as scheduling a vacation.
##
## https://dev.twitch.tv/docs/api/reference#update-channel-stream-schedule
func update_channel_stream_schedule(is_vacation_enabled: bool, vacation_start_time: Variant, vacation_end_time: Variant, timezone: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/schedule/settings?"
	path += "vacation_start_time=" + get_rfc_3339_date_format(vacation_start_time) + "&"
	path += "vacation_end_time=" + get_rfc_3339_date_format(vacation_end_time) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "is_vacation_enabled=" + str(is_vacation_enabled) + "&"
	path += "vacation_start_time=" + str(vacation_start_time) + "&"
	path += "vacation_end_time=" + str(vacation_end_time) + "&"
	path += "timezone=" + str(timezone) + "&"
	var response = await request(path, HTTPClient.METHOD_PATCH, "");


## Adds a single or recurring broadcast to the broadcaster’s streaming schedule.
##
## https://dev.twitch.tv/docs/api/reference#create-channel-stream-schedule-segment
func create_channel_stream_schedule_segment(body: TwitchCreateChannelStreamScheduleSegmentBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchCreateChannelStreamScheduleSegmentResponse:
	var path = "/helix/schedule/segment?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCreateChannelStreamScheduleSegmentResponse.from_json(result);
{else}
	return response;


## Updates a scheduled broadcast segment.
##
## https://dev.twitch.tv/docs/api/reference#update-channel-stream-schedule-segment
func update_channel_stream_schedule_segment(id: String, body: TwitchUpdateChannelStreamScheduleSegmentBody, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchUpdateChannelStreamScheduleSegmentResponse:
	var path = "/helix/schedule/segment?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "id=" + str(id) + "&"
	var response = await request(path, HTTPClient.METHOD_PATCH, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateChannelStreamScheduleSegmentResponse.from_json(result);
{else}
	return response;


## Deletes a broadcast from the broadcaster’s streaming schedule.
##
## https://dev.twitch.tv/docs/api/reference#delete-channel-stream-schedule-segment
func delete_channel_stream_schedule_segment(id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/schedule/segment?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "id=" + str(id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Gets the games or categories that match the specified query.
##
## https://dev.twitch.tv/docs/api/reference#search-categories
func search_categories(query: String, first: int, after: String) -> TwitchSearchCategoriesResponse:
	var path = "/helix/search/categories?"
	path += "query=" + str(query) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchSearchCategoriesResponse.from_json(result);
{else}
	return response;


## Gets the channels that match the specified query and have streamed content within the past 6 months.
##
## https://dev.twitch.tv/docs/api/reference#search-channels
func search_channels(query: String, live_only: bool, first: int, after: String) -> TwitchSearchChannelsResponse:
	var path = "/helix/search/channels?"
	path += "query=" + str(query) + "&"
	path += "live_only=" + str(live_only) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchSearchChannelsResponse.from_json(result);
{else}
	return response;


## Gets the channel’s stream key.
##
## https://dev.twitch.tv/docs/api/reference#get-stream-key
func get_stream_key(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetStreamKeyResponse:
	var path = "/helix/streams/key?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetStreamKeyResponse.from_json(result);
{else}
	return response;


## Gets a list of all streams.
##
## https://dev.twitch.tv/docs/api/reference#get-streams
func get_streams(user_id: Array[String], user_login: Array[String], game_id: Array[String], type: String, language: Array[String], first: int, before: String, after: String) -> TwitchGetStreamsResponse:
	var path = "/helix/streams?"
	for param in user_id:
		path += "user_id=" + str(param) + "&"
	for param in user_login:
		path += "user_login=" + str(param) + "&"
	for param in game_id:
		path += "game_id=" + str(param) + "&"
	for param in language:
		path += "language=" + str(param) + "&"
	path += "type=" + str(type) + "&"
	path += "first=" + str(first) + "&"
	path += "before=" + str(before) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetStreamsResponse.from_json(result);
{else}
	return response;


## Gets the list of broadcasters that the user follows and that are streaming live.
##
## https://dev.twitch.tv/docs/api/reference#get-followed-streams
func get_followed_streams(user_id: String, first: int, after: String) -> TwitchGetFollowedStreamsResponse:
	var path = "/helix/streams/followed?"
	path += "user_id=" + str(user_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetFollowedStreamsResponse.from_json(result);
{else}
	return response;


## Adds a marker to a live stream.
##
## https://dev.twitch.tv/docs/api/reference#create-stream-marker
func create_stream_marker(body: TwitchCreateStreamMarkerBody) -> TwitchCreateStreamMarkerResponse:
	var path = "/helix/streams/markers?"
	var response = await request(path, HTTPClient.METHOD_POST, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCreateStreamMarkerResponse.from_json(result);
{else}
	return response;


## Gets a list of markers from the user’s most recent stream or from the specified VOD/video.
##
## https://dev.twitch.tv/docs/api/reference#get-stream-markers
func get_stream_markers(user_id: String, video_id: String, first: String, before: String, after: String) -> TwitchGetStreamMarkersResponse:
	var path = "/helix/streams/markers?"
	path += "user_id=" + str(user_id) + "&"
	path += "video_id=" + str(video_id) + "&"
	path += "first=" + str(first) + "&"
	path += "before=" + str(before) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetStreamMarkersResponse.from_json(result);
{else}
	return response;


## Gets a list of users that subscribe to the specified broadcaster.
##
## https://dev.twitch.tv/docs/api/reference#get-broadcaster-subscriptions
func get_broadcaster_subscriptions(user_id: Array[String], first: String, after: String, before: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetBroadcasterSubscriptionsResponse:
	var path = "/helix/subscriptions?"
	for param in user_id:
		path += "user_id=" + str(param) + "&"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	path += "before=" + str(before) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetBroadcasterSubscriptionsResponse.from_json(result);
{else}
	return response;


## Checks whether the user subscribes to the broadcaster’s channel.
##
## https://dev.twitch.tv/docs/api/reference#check-user-subscription
func check_user_subscription(user_id: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchCheckUserSubscriptionResponse:
	var path = "/helix/subscriptions/user?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "user_id=" + str(user_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchCheckUserSubscriptionResponse.from_json(result);
{else}
	return response;


## Gets the list of all stream tags that Twitch defines. You can also filter the list by one or more tag IDs.
##
## https://dev.twitch.tv/docs/api/reference#get-all-stream-tags
func get_all_stream_tags(tag_id: Array[String], first: int, after: String) -> TwitchGetAllStreamTagsResponse:
	var path = "/helix/tags/streams?"
	for param in tag_id:
		path += "tag_id=" + str(param) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetAllStreamTagsResponse.from_json(result);
{else}
	return response;


## Gets the list of stream tags that the broadcaster or Twitch added to their channel.
##
## https://dev.twitch.tv/docs/api/reference#get-stream-tags
func get_stream_tags(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetStreamTagsResponse:
	var path = "/helix/streams/tags?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetStreamTagsResponse.from_json(result);
{else}
	return response;


## Gets the list of Twitch teams that the broadcaster is a member of.
##
## https://dev.twitch.tv/docs/api/reference#get-channel-teams
func get_channel_teams(broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetChannelTeamsResponse:
	var path = "/helix/teams/channel?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetChannelTeamsResponse.from_json(result);
{else}
	return response;


## Gets information about the specified Twitch team.
##
## https://dev.twitch.tv/docs/api/reference#get-teams
func get_teams(name: String, id: String) -> TwitchGetTeamsResponse:
	var path = "/helix/teams?"
	path += "name=" + str(name) + "&"
	path += "id=" + str(id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetTeamsResponse.from_json(result);
{else}
	return response;


## Gets information about one or more users.
##
## https://dev.twitch.tv/docs/api/reference#get-users
func get_users(id: Array[String], login: Array[String]) -> TwitchGetUsersResponse:
	var path = "/helix/users?"
	for param in id:
		path += "id=" + str(param) + "&"
	for param in login:
		path += "login=" + str(param) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetUsersResponse.from_json(result);
{else}
	return response;


## Updates the user’s information.
##
## https://dev.twitch.tv/docs/api/reference#update-user
func update_user(description: String) -> TwitchUpdateUserResponse:
	var path = "/helix/users?"
	path += "description=" + str(description) + "&"
	var response = await request(path, HTTPClient.METHOD_PUT, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateUserResponse.from_json(result);
{else}
	return response;


## Gets the list of users that the broadcaster has blocked.
##
## https://dev.twitch.tv/docs/api/reference#get-user-block-list
func get_user_block_list(first: int, after: String, broadcaster_id: String = TwitchSetting.broadcaster_id) -> TwitchGetUserBlockListResponse:
	var path = "/helix/users/blocks?"
	path += "broadcaster_id=" + str(broadcaster_id) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetUserBlockListResponse.from_json(result);
{else}
	return response;


## Blocks the specified user from interacting with or having contact with the broadcaster.
##
## https://dev.twitch.tv/docs/api/reference#block-user
func block_user(target_user_id: String, source_context: String, reason: String) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/users/blocks?"
	path += "target_user_id=" + str(target_user_id) + "&"
	path += "source_context=" + str(source_context) + "&"
	path += "reason=" + str(reason) + "&"
	var response = await request(path, HTTPClient.METHOD_PUT, "");


## Removes the user from the broadcaster’s list of blocked users.
##
## https://dev.twitch.tv/docs/api/reference#unblock-user
func unblock_user(target_user_id: String) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/users/blocks?"
	path += "target_user_id=" + str(target_user_id) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");


## Gets a list of all extensions (both active and inactive) that the broadcaster has installed.
##
## https://dev.twitch.tv/docs/api/reference#get-user-extensions
func get_user_extensions() -> TwitchGetUserExtensionsResponse:
	var path = "/helix/users/extensions/list?"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetUserExtensionsResponse.from_json(result);
{else}
	return response;


## Gets the active extensions that the broadcaster has installed for each configuration.
##
## https://dev.twitch.tv/docs/api/reference#get-user-active-extensions
func get_user_active_extensions(user_id: String) -> TwitchGetUserActiveExtensionsResponse:
	var path = "/helix/users/extensions?"
	path += "user_id=" + str(user_id) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetUserActiveExtensionsResponse.from_json(result);
{else}
	return response;


## Updates an installed extension’s information.
##
## https://dev.twitch.tv/docs/api/reference#update-user-extensions
func update_user_extensions(body: TwitchUpdateUserExtensionsBody) -> TwitchUpdateUserExtensionsResponse:
	var path = "/helix/users/extensions?"
	var response = await request(path, HTTPClient.METHOD_PUT, body);

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchUpdateUserExtensionsResponse.from_json(result);
{else}
	return response;


## Gets information about one or more published videos.
##
## https://dev.twitch.tv/docs/api/reference#get-videos
func get_videos(id: Array[String], user_id: String, game_id: String, language: String, period: String, sort: String, type: String, first: String, after: String, before: String) -> TwitchGetVideosResponse:
	var path = "/helix/videos?"
	for param in id:
		path += "id=" + str(param) + "&"
	path += "user_id=" + str(user_id) + "&"
	path += "game_id=" + str(game_id) + "&"
	path += "language=" + str(language) + "&"
	path += "period=" + str(period) + "&"
	path += "sort=" + str(sort) + "&"
	path += "type=" + str(type) + "&"
	path += "first=" + str(first) + "&"
	path += "after=" + str(after) + "&"
	path += "before=" + str(before) + "&"
	var response = await request(path, HTTPClient.METHOD_GET, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchGetVideosResponse.from_json(result);
{else}
	return response;


## Deletes one or more videos.
##
## https://dev.twitch.tv/docs/api/reference#delete-videos
func delete_videos(id: Array[String]) -> TwitchDeleteVideosResponse:
	var path = "/helix/videos?"
	for param in id:
		path += "id=" + str(param) + "&"
	var response = await request(path, HTTPClient.METHOD_DELETE, "");

	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return TwitchDeleteVideosResponse.from_json(result);
{else}
	return response;


## Sends a whisper message to the specified user.
##
## https://dev.twitch.tv/docs/api/reference#send-whisper
func send_whisper(from_user_id: String, to_user_id: String, body: TwitchSendWhisperBody) -> BufferedHTTPClient.ResponseData:
	var path = "/helix/whispers?"
	path += "from_user_id=" + str(from_user_id) + "&"
	path += "to_user_id=" + str(to_user_id) + "&"
	var response = await request(path, HTTPClient.METHOD_POST, body);



## Converts unix timestamp to RFC 3339 (example: 2021-10-27T00:00:00Z) when passed a string uses as is
static func get_rfc_3339_date_format(time: Variant) -> String:
	if typeof(time) == TYPE_INT:
		var date_time = Time.get_datetime_dict_from_unix_time(time);
		return "%s-%02d-%02dT%02d:%02d:%02dZ" % [date_time['year'], date_time['month'], date_time['day'], date_time['hour'], date_time['minute'], date_time['second']];
	return str(time);