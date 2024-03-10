extends RefCounted

class_name TwitchCheerRepository

enum Themes {
	DARK = 0,
	LIGHT = 1
}

const themes: Array[String] = [
	"dark",
	"light"
];


enum Types {
	ANIMATED = 0,
	STATIC = 1
}

const types_property: Array[String] = [
	"animated_format",
	"static_format"
];

const types_path: Array[String] = [
	"animated",
	"static"
];

enum Scales {
	_1 = 0,
	_2 = 1,
	_3 = 2,
	_4 = 3,
	_1_5 = 4
}

const scales_property: Array[String] = [
	"_1", "_2", "_3", "_4", "_1_5"
]

const scales_path: Array[String] = [
	"1", "2", "3", "4", "1.5"
]

## When the data for cheermotes are loaded.
signal ready;

class CheerResult extends RefCounted:
	var number: int;
	var cheermote: TwitchCheermote;
	var tier: TwitchCheermote.Tiers;
	var spriteframes: SpriteFrames;
	func _init(num: int, cheer: TwitchCheermote, t: TwitchCheermote.Tiers, sprites: SpriteFrames):
		number = num;
		cheermote = cheer;
		tier = t;
		spriteframes = sprites;

var HOST_PARSER = RegEx.create_from_string("(https://.*?)/");
var fallback_texture: Texture2D
var data: Array[TwitchCheermote];
var is_ready: bool;
var _cache: Dictionary;
var api: TwitchRestAPI;

func _init(twitch_rest_api: TwitchRestAPI) -> void:
	api = twitch_rest_api;
	fallback_texture = TwitchSetting.fallback_texture2d;
	_preload_cheemote();

func _preload_cheemote():
	var cheer_emote_response: TwitchGetCheermotesResponse = await api.get_cheermotes();
	data = cheer_emote_response.data
	is_ready = true;
	ready.emit();

## Use this to ensure that the cheermotes got preloaded.
func wait_is_ready(): if !is_ready: await ready;

## Resolves a cheer tier emote for a specific cheer example: Cheer100
## Can be null when not found.
func get_cheer_tier(cheer: String, theme: Themes = Themes.DARK, type: Types = Types.ANIMATED, scale: Scales = Scales._1) -> CheerResult:
	for cheermote: TwitchCheermote in data:
		if cheer.begins_with(cheermote.prefix):
			var number := int(cheer.trim_prefix(cheermote.prefix));
			var tier = _find_cheer_tier(number, cheermote);
			var sprite_frames = await _get_sprite_frames(cheermote, tier, theme, type, scale)
			return CheerResult.new(number, cheermote, tier, sprite_frames);
	return null;

func _find_cheer_tier(number: int, cheer_data: TwitchCheermote) -> TwitchCheermote.Tiers:
	var current_tier: TwitchCheermote.Tiers = cheer_data.tiers[0];
	for tier: TwitchCheermote.Tiers in cheer_data.tiers:
		if tier.min_bits < number && current_tier.min_bits < tier.min_bits:
			current_tier = tier;
	return current_tier;

func _get_sprite_frames(cheermote: TwitchCheermote, tier: TwitchCheermote.Tiers, theme: Themes, type: Types, scale: Scales) -> SpriteFrames:
	var id = _get_id(cheermote, tier, theme, type, scale);
	if ResourceLoader.has_cached(id):
		return ResourceLoader.load(id);
	else:
		var request = _request_cheermote(tier, theme, type, scale);
		return await _wait_for_cheeremote(request, id);

## Return specified cheermote data in form of:
## Key: TwitchCheermote.Tiers ; Value: SpriteFrames
func get_cheermotes(cheermote: TwitchCheermote, theme: Themes, type: Types, scale: Scales) -> Dictionary:
	var response: Dictionary = {};
	var requests: Dictionary = {};
	for tier: TwitchCheermote.Tiers in cheermote.tiers:
		var id = _get_id(cheermote, tier, theme, type, scale);
		if ResourceLoader.has_cached(id): response[tier] = ResourceLoader.load(id);
		if not TwitchSetting.image_transformer.is_supporting_animation():
			type = Types.STATIC;
		else: requests[tier] = _request_cheermote(tier, theme, type, scale);

	for tier: TwitchCheermote.Tiers in requests:
		var id = _get_id(cheermote, tier, theme, type, scale);
		var request = requests[tier];
		var sprite_frames = await _wait_for_cheeremote(request, id);
		response[tier] = sprite_frames;
	return response;

## Checks if the prefix is existing
func is_cheermote_prefix_existing(prefix: String) -> bool:
	for cheer_data in data:
		if cheer_data.prefix == prefix:
			return true;
	return false;

func _request_cheermote(cheer_tier: TwitchCheermote.Tiers, theme: Themes, type: Types, scale: Scales) -> BufferedHTTPClient.RequestData:
	var used_theme = themes[theme];
	var used_type = types_property[type];
	var used_scale = scales_property[scale];
	var img_path = cheer_tier.images[used_theme][used_type][used_scale] as String;
	var host_result : RegExMatch = HOST_PARSER.search(img_path);
	if host_result == null:
		var frames = SpriteFrames.new()
		frames.add_frame("default", fallback_texture);
		return frames;

	var host = host_result.get_string(1);
	var request_path = img_path.trim_prefix(host);
	var client = HttpClientManager.get_client(host);
	var request = client.request(request_path, HTTPClient.METHOD_GET, {}, "");
	return request;

func _wait_for_cheeremote(request: BufferedHTTPClient.RequestData, cheer_id: String) -> SpriteFrames:
	var client = request.client;
	var image_transformer = TwitchSetting.image_transformer;
	var response = await client.wait_for_request(request);
	var cache_path = TwitchSetting.cache_cheermote.path_join(cheer_id);
	var sprite_frames = await TwitchSetting.image_transformer.convert_image(
		cache_path,
		response.response_data,
		cache_path + ".res") as SpriteFrames;
	sprite_frames.take_over_path(cheer_id);
	_cache[cheer_id] = sprite_frames;
	return sprite_frames;

func _get_id(cheermote: TwitchCheermote, tier: TwitchCheermote.Tiers, theme: Themes, type: Types, scale: Scales) -> String:
	return "/" + "/".join([ cheermote.prefix, tier.id, themes[theme], types_path[type], scales_path[scale] ]);
