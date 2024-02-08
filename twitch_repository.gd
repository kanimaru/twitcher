extends RefCounted

## Interaction with the REST API.
## Remark: Reson why this methods aren't into the generated TwitchRestApi to
## leverage the editor with autocompletion etc.
class_name TwitchRepository

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

#region Rewards
const STATUS_FULLFILLED: StringName = &"FULFILLED";
const STATUS_CANCELED: StringName = &"CANCELED";

func get_custom_rewards() -> Dictionary:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "broadcaster_id=%s" % [broadcaster_id]
	var response = await request("/helix/channel_points/custom_rewards?%s" % [params], HTTPClient.METHOD_GET, "", "application/x-www-form-urlencoded");
	return JSON.parse_string(response.response_data.get_string_from_utf8());

func add_custom_reward(body: TwitchCreateRewardDto) -> Dictionary:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "broadcaster_id=%s" % [broadcaster_id]

	var response = await request("/helix/channel_points/custom_rewards?%s" % [params], HTTPClient.METHOD_POST, body);
	return JSON.parse_string(response.response_data.get_string_from_utf8());

func modify_custom_reward(id: String, body: TwitchModifyRewardDto) -> void:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "broadcaster_id=%s&id=%s" % [broadcaster_id, id];
	await request("/helix/channel_points/custom_rewards?%s" % [params], HTTPClient.METHOD_PATCH, body);

func remove_custom_reward(id: String) -> void:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "broadcaster_id=%s&id=%s" % [broadcaster_id, id]
	await request("/helix/channel_points/custom_rewards?%s" % [params], HTTPClient.METHOD_DELETE, "", "application/x-www-form-urlencoded");

func update_redemtion(redemption_id: String, reward_id: String, status: String) -> void:
	var broadcaster_id = TwitchSetting.broadcaster_id;
	var params = "id=%s&broadcaster_id=%s&reward_id=%s" % [redemption_id, broadcaster_id, reward_id];
	await request("/helix/channel_points/custom_rewards/redemptions?%s" % [params], HTTPClient.METHOD_PATCH, {
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
