extends RefCounted

## Will load badges, icons and profile images
class_name TwitchIconLoader

## Will be sent when the emotes and badges got preloaded
signal preload_done;

## Called when an emoji was succesfully loaded
signal emoji_loaded(definition: TwitchEmoteDefinition);

const ALLOW_EMPTY = true;
const MAX_SPLITS = 1;

var api: TwitchRestAPI;

## All requests that are currently in progress
var requests_in_progress : Array[StringName];
## Badge definition for global and the channel.
var cached_badges : Dictionary = {};
## Emote definition for global and the channel.
var cached_emotes : Dictionary = {};

## All cached emotes with emote_id as key and spriteframes as value.
## Is needed that the garbage collector isn't deleting our cache.
var _cached_images : Array[SpriteFrames] = [];

var static_image_transformer = TwitchImageTransformer.new();

func _init(twitch_api : TwitchRestAPI) -> void:
	api = twitch_api;

func do_preload():
	var broadcaster_id = TwitchSetting.broadcaster_id;
	await preload_emotes();
	await preload_emotes(broadcaster_id);
	await preload_badges();
	await preload_badges(broadcaster_id);
	preload_done.emit();

	_fireup_cache();

## Loading all images from the directory into the memory cache
func _fireup_cache() -> void:
	_cache_directory(TwitchSetting.cache_emote);
	_cache_directory(TwitchSetting.cache_badge);

func _cache_directory(path: String):
	DirAccess.make_dir_recursive_absolute(path);
	var files = DirAccess.get_files_at(path);
	for file in files:
		if file.ends_with(".res"):
			var res_path = path.path_join(file);
			var sprite_frames: SpriteFrames = ResourceLoader.load(res_path, "SpriteFrames");
			sprite_frames.take_over_path(res_path.trim_suffix(".res"))
			_cached_images.append(sprite_frames);

#region Emotes

func preload_emotes(channel_id: String = "global") -> void:
	if (!cached_emotes.has(channel_id)):
		var response;
		if channel_id == "global":
			response = await api.get_global_emotes();
		else:
			response = await api.get_channel_emotes(channel_id);
		cached_emotes[channel_id] = _map_emotes(response);

## Returns requested emotes.
## Key: EmoteID as String ; Value: SpriteFrames
func get_emotes(emote_ids : Array[String]) -> Dictionary:
	var requests: Array[TwitchEmoteDefinition] = []
	for id in emote_ids:
		requests.append(TwitchEmoteDefinition.new(id));
	var emotes = await get_emotes_by_definition(requests);
	var result = {};
	# Remap the emotes to string value easier for processing
	for requested_emote in requests:
		result[requested_emote.id] = emotes[requested_emote];
	return result;

## Returns requested emotes.
## Key: TwitchEmoteDefinition ; Value: SpriteFrames
func get_emotes_by_definition(emote_definitions : Array[TwitchEmoteDefinition]) -> Dictionary:
	var response: Dictionary = {};
	var requests: Dictionary = {};

	for emote_definition: TwitchEmoteDefinition in emote_definitions:
		var cache_path: String = emote_definition.get_cache_path();
		var spriteframe_path: String = emote_definition.get_cache_path_spriteframe();
		if ResourceLoader.has_cached(spriteframe_path):
			response[emote_definition] = ResourceLoader.load(spriteframe_path);
			continue;

		if not TwitchSetting.image_transformer.is_supporting_animation():
			emote_definition.type_static();

		if requests_in_progress.has(cache_path): continue;
		requests_in_progress.append(cache_path);
		var request : BufferedHTTPClient.RequestData = _load_emote(emote_definition);
		requests[emote_definition] = request;

	for emote_definition: TwitchEmoteDefinition in requests:
		var cache_path: String = emote_definition.get_cache_path();
		var spriteframe_path: String = emote_definition.get_cache_path_spriteframe();
		var request = requests[emote_definition];
		var sprite_frames = await _convert_response(request, cache_path, spriteframe_path);
		response[emote_definition] = sprite_frames;
		_cached_images.append(sprite_frames);
		requests_in_progress.erase(cache_path);
		emoji_loaded.emit(emote_definition);

	for emote_definition: TwitchEmoteDefinition in emote_definitions:
		if not response.has(emote_definition):
			var cache = emote_definition.get_cache_path_spriteframe();
			response[emote_definition] = ResourceLoader.load(cache);

	return response;

func _load_emote(emote_definition : TwitchEmoteDefinition) -> BufferedHTTPClient.RequestData:
	var request_path = "/emoticons/v2/%s/%s/%s/%1.1f" % [emote_definition.id, emote_definition._type, emote_definition._theme, emote_definition._scale];
	var client = HttpClientManager.get_client(TwitchSetting.twitch_image_cdn_host);
	return client.request(request_path, HTTPClient.METHOD_GET, BufferedHTTPClient.HEADERS, "");

func _map_emotes(result: Variant) -> Dictionary:
	var mappings : Dictionary = {};
	var emotes : Array = result.get("data");
	if emotes == null:
		return mappings;
	for emote in emotes:
		mappings[emote.get("id")] = emote;
	return mappings;

func get_cached_emotes(channel_id) -> Dictionary:
	if not cached_emotes.has(channel_id):
		await preload_emotes(channel_id);
	return cached_emotes[channel_id];

#endregion

#region Badges

class BadgeData extends RefCounted:
	var badge_set: String;
	var badge_id: String;
	var scale: int;
	var channel: String;

	## badge_composite example: "subscriber/6;"
	func _init(badge_composite: String, badge_scale: int, badge_channel: String) -> void:
		var badge_data : PackedStringArray = badge_composite.split("/", ALLOW_EMPTY, MAX_SPLITS);
		badge_set = badge_data[0];
		badge_id = badge_data[1];
		assert(badge_scale == 1 || badge_scale == 2 || badge_scale == 4)
		scale = badge_scale;
		channel = badge_channel;

	func get_cache_id() -> String:
		return "_".join([
			channel,
			badge_set,
			badge_id,
			scale
		]);

func preload_badges(channel_id: String = "global") -> void:
	if not cached_badges.has(channel_id):
		var response;
		if channel_id == "global":
			response = await(api.get_global_chat_badges());
		else:
			response = await(api.get_channel_chat_badges(channel_id));
		cached_badges[channel_id] = _cache_badges(response);

## Returns the requested badge either from cache or loads from web. Scale can be 1, 2 or 4.
## Key: Badge Composite ; Value: SpriteFrames
func get_badges(badge_composites : Array[String], channel_id : String = "global", scale : int = 1) -> Dictionary:
	var response: Dictionary = {};
	var requests: Dictionary = {};

	for badge_composite in badge_composites:
		var badge_data : BadgeData = BadgeData.new(badge_composite, scale, channel_id);
		var cache_id : String = badge_data.get_cache_id();
		var badge_path : String = TwitchSetting.cache_badge.path_join(cache_id);
		if ResourceLoader.has_cached(badge_path):
			response[badge_composite] = ResourceLoader.load(badge_path);
		else:
			var request = await _load_badge(badge_data);
			requests[badge_composite] = request;

	for badge_composite in requests:
		var badge_data: BadgeData = BadgeData.new(badge_composite, scale, channel_id);
		var request = requests[badge_composite];
		var id : String = badge_data.get_cache_id();
		var cache_path : String = TwitchSetting.cache_badge.path_join(id);
		var spriteframe_path : String = TwitchSetting.cache_badge.path_join(id) + ".res";
		var sprite_frames = await _convert_response(request, cache_path, spriteframe_path);
		response[badge_composite] = sprite_frames;
		_cached_images.append(sprite_frames);

	return response;

func _load_badge(badge_data: BadgeData) -> BufferedHTTPClient.RequestData:
	var channel_id = badge_data.channel;
	var badge_set = badge_data.badge_set;
	var badge_id = badge_data.badge_id;
	var scale = badge_data.scale;

	var is_global_chanel = channel_id == "global";
	if not cached_badges.has(channel_id):
		await preload_badges(channel_id);
	var channel_has_badge = cached_badges[channel_id].has(badge_set) && cached_badges[channel_id][badge_set]["versions"].has(badge_id);
	if (!is_global_chanel && !channel_has_badge):
		badge_data.channel = "global";
		return await _load_badge(badge_data);

	var base_url = TwitchSetting.twitch_image_cdn_host;
	var request_path = cached_badges[channel_id][badge_set]["versions"][badge_id]["image_url_%sx" % scale].trim_prefix(base_url);
	var client = HttpClientManager.get_client(base_url);
	return client.request(request_path, HTTPClient.METHOD_GET, BufferedHTTPClient.HEADERS, "");

## Maps the badges into a dict of category / versions / badge_id
func _cache_badges(result: Variant) -> Dictionary:
	var mappings : Dictionary = {};
	var badges : Array = result["data"];
	for badge in badges:
		if not mappings.has(badge["set_id"]):
			mappings[badge["set_id"]] = {
				"set_id": badge["set_id"],
				"versions" : {}
			};
		for version in badge["versions"]:
			mappings[badge["set_id"]]["versions"][version["id"]] = version;
	return mappings;

func get_cached_badges(channel_id) -> Dictionary:
	if(!cached_badges.has(channel_id)):
		await preload_badges(channel_id);
	return cached_badges[channel_id];
#endregion

#region Utilities

const GIF_HEADER: PackedByteArray = [71, 73, 70];

func _convert_response(request: BufferedHTTPClient.RequestData, cache_path: String, spriteframe_path: String) -> SpriteFrames:
	var client = request.client as BufferedHTTPClient;
	var response = await client.wait_for_request(request);
	var image_transformer = TwitchSetting.image_transformer;
	var response_data = response.response_data as PackedByteArray;
	var file_head = response_data.slice(0, 3);
	# REMARK: don't use content-type... twitch doesn't check and sends PNGs with GIF content type.
	if file_head == GIF_HEADER:
		return await image_transformer.convert_image(cache_path, response_data, spriteframe_path) as SpriteFrames;
	else:
		return await static_image_transformer.convert_image(cache_path, response_data, spriteframe_path) as SpriteFrames;

#endregion
