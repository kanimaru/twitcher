extends RefCounted

class_name TwitchRepository

## Maximal tries to reauthrorize before giving up the request.
const MAX_AUTH_ERRORS = 3;

var client: BufferedHTTPClient;
var auth: TwitchAuth;

func _init(twitch_auth: TwitchAuth) -> void:
	client = BufferedHTTPClient.new(TwitchSetting.api_host);
	auth = twitch_auth;

func _request(path: String, method: int, body: Variant = "", content_type: String = "application/json", error_count: int = 0) -> BufferedHTTPClient.ResponseData:
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
			return await _request(path, method, body, content_type, error_count + 1);
		else:
			# Give up the request after trying multiple times and
			# return an empty response with correct error code
			var empty_response = client.empty_response(request);
			empty_response.response_code = response.client.get_response_code();
			return empty_response;
	return response;

func update_chanel_info(broadcaster_id: String, game_id: String, title: String):
	_request("/helix/channels?broadcaster_id=%s" % [broadcaster_id], HTTPClient.METHOD_PATCH, {
		"game_id": game_id,
		"title": title,
	});

func get_emotes(broadcaster_id: String):
	var response = await _request("/helix/chat/emotes?broadcaster_id=%s" % [broadcaster_id], HTTPClient.METHOD_GET, {});
	return JSON.parse_string(response.response_data.get_string_from_utf8());

func get_global_emotes():
	var response = await _request("/helix/chat/emotes/global", HTTPClient.METHOD_GET, {});
	var result = JSON.parse_string(response.response_data.get_string_from_utf8());
	return result;

func get_badges(broadcaster_id: String):
	var response = await _request("/helix/chat/badges?broadcaster_id=%s" % [broadcaster_id], HTTPClient.METHOD_GET, {});
	return JSON.parse_string(response.response_data.get_string_from_utf8());

func get_global_badges() -> Dictionary:
	var response = await _request("/helix/chat/badges/global", HTTPClient.METHOD_GET, {});
	var result = response.response_data.get_string_from_utf8()
	return JSON.parse_string(result);

func get_cheermotes(broadcaster_id: String) -> Dictionary:
	var response = await _request("/helix/bits/cheermotes?broadcaster_id=%s" % [broadcaster_id], HTTPClient.METHOD_GET, {});
	var result = response.response_data.get_string_from_utf8();
	return JSON.parse_string(result);

func announcement(broadcaster_id: String, message: String, color: TwitchAnnouncementColor):
	var args = "broadcaster_id=%s&moderator_id=%s" % [broadcaster_id, broadcaster_id]
	_request("/helix/chat/announcements?%s" % args, HTTPClient.METHOD_POST, {
		"message": message,
		"color": color.value
	})

func shoutout(to_broadcaster_id: String) -> void:
	var from := TwitchSetting.broadcaster_id;
	var params = "from_broadcaster_id=%s&to_broadcaster_id=%s&moderator_id=%s" % [from, to_broadcaster_id, from];
	_request("/helix/chat/shoutouts?%s" % params, HTTPClient.METHOD_POST, {});

func get_users(names : Array[String], ids : Array[String]) -> Dictionary:
	if (names.is_empty() && ids.is_empty()): return {}
	var params = ""
	for name in names: params += "login=%s&" % name
	for id in ids: params += "id=%s&" % id
	params = params.substr(0, -1);
	var response = await(_request("/helix/users?%s" % params, HTTPClient.METHOD_GET, ""))
	return JSON.parse_string(response.response_data.get_string_from_utf8());

func start_raid(to_broadcaster_id: String) -> void:
	var from := TwitchSetting.broadcaster_id;
	_request("/helix/chat/raids", HTTPClient.METHOD_POST, {
		"from_broadcaster_id": from,
		"to_broadcaster_id": to_broadcaster_id
	});

## Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
## which API versions are available and which conditions are required.
func subscribe_event(event_name : String, version : String, conditions : Dictionary, session_id: String):
	var data : Dictionary = {}
	data["type"] = event_name
	data["version"] = version
	data["condition"] = conditions
	data["transport"] = {
		"method":"websocket",
		"session_id": session_id
	}
	var response := await _request("/helix/eventsub/subscriptions", HTTPClient.METHOD_POST, data);

	if not str(response.response_code).begins_with("2"):
		print("REST: Subscription failed for event '%s'. Error %s: %s" % [event_name, response.response_code, response.response_data.get_string_from_utf8()])
		return
	elif (response.response_data.is_empty()):
		return
	print("REST: Now listening to '%s' events." % event_name)

#region Rewards
const STATUS_FULLFILLED: StringName = &"FULFILLED";
const STATUS_CANCELED: StringName = &"CANCELED";

func get_custom_rewards() -> Dictionary:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "broadcaster_id=%s" % [broadcaster_id]
	var response = await _request("/helix/channel_points/custom_rewards?%s" % [params], HTTPClient.METHOD_GET, "", "application/x-www-form-urlencoded");
	return JSON.parse_string(response.response_data.get_string_from_utf8());

func add_custom_reward(body: TwitchCreateRewardDto) -> Dictionary:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "broadcaster_id=%s" % [broadcaster_id]

	var response = await _request("/helix/channel_points/custom_rewards?%s" % [params], HTTPClient.METHOD_POST, body);
	return JSON.parse_string(response.response_data.get_string_from_utf8());

func modify_custom_reward(id: String, body: TwitchModifyRewardDto) -> void:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "broadcaster_id=%s&id=%s" % [broadcaster_id, id];
	await _request("/helix/channel_points/custom_rewards?%s" % [params], HTTPClient.METHOD_PATCH, body);

func remove_custom_reward(id: String) -> void:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "broadcaster_id=%s&id=%s" % [broadcaster_id, id]
	await _request("/helix/channel_points/custom_rewards?%s" % [params], HTTPClient.METHOD_DELETE, "", "application/x-www-form-urlencoded");

func update_redemtion(redemption_id: String, reward_id: String, status: String) -> void:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "id=%s&broadcaster_id=%s&reward_id=%s" % [redemption_id, broadcaster_id, reward_id];
	await _request("/helix/channel_points/custom_rewards/redemptions?%s" % [params], HTTPClient.METHOD_PATCH, {
		"status": status
	});
#endregion

## Load user image
func load_image(user: TwitchUser) -> Texture:
	if user == null: return TwitchSetting.fallback_profile;
	if(ResourceLoader.has_cached(user.profile_image_url)):
		return ResourceLoader.load(user.profile_image_url);
	var client : BufferedHTTPClient = HttpClientManager.get_client(TwitchSetting.twitch_image_cdn_host);
	var request := client.request(user.profile_image_url, HTTPClient.METHOD_GET, BufferedHTTPClient.HEADERS, "")
	var response_data := await client.wait_for_request(request);
	var texture : ImageTexture = ImageTexture.new();
	var response = response_data.response_data;
	if !response.is_empty():
		var img := Image.new();
		var content_type = HttpUtil.get_header(response_data.client.get_response_headers(), "Content-Type")
		var no_match = false;
		match content_type:
			"image/png": img.load_png_from_buffer(response);
			"image/jpeg": img.load_jpg_from_buffer(response);
			_: no_match = true;
		if no_match: return TwitchSetting.fallback_profile;
		else: texture.set_image(img);
	else:
		texture.set_image(TwitchSetting.fallback_profile.get_image());
	texture.take_over_path(user.profile_image_url);
	return texture;

func get_clips() -> void:
	pass
