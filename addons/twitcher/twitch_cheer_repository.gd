@tool
extends Node

class_name TwitchCheerRepository

const FALLBACK_TEXTURE = preload("res://addons/twitcher/assets/fallback_texture.tres")

enum Themes {
	DARK = 0,
	LIGHT = 1
}

const themes: Array[String] = [
	"dark",
	"light"
]


enum Types {
	ANIMATED = 0,
	STATIC = 1
}

const types_property: Array[String] = [
	"animated_format",
	"static_format"
]

const types_path: Array[String] = [
	"animated",
	"static"
]

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
signal preload_done

class CheerResult extends RefCounted:
	var cheermote: TwitchCheermote
	var tier: TwitchCheermote.Tiers
	var spriteframes: SpriteFrames
	func _init(cheer: TwitchCheermote, t: TwitchCheermote.Tiers, sprites: SpriteFrames):
		cheermote = cheer
		tier = t
		spriteframes = sprites

@export var http_client_manager: HttpClientManager
@export var api: TwitchRestAPI
@export var _fallback_texture: Texture2D = FALLBACK_TEXTURE

var _HOST_PARSER = RegEx.create_from_string("(https://.*?)/")

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_EVENT_SUB)
# Key: String Cheer Prefix | Value: TwitchCheermote
var cheermotes: Dictionary
var _is_preloaded: bool
var _cache: Dictionary

## Propergated call from twitch service
func do_setup() -> void:
	await preload_cheemote()
	log.i("Cheer setup")


## Use this to ensure that the cheermotes got preloaded.
func wait_preloaded() -> void: if !_is_preloaded: await preload_done


func preload_cheemote() -> void:
	if _is_preloaded: return

	var cheermote_response: TwitchGetCheermotesResponse = await api.get_cheermotes()
	for data: TwitchCheermote in cheermote_response.data:
		cheermotes[data.prefix] = data
	_is_preloaded = true
	preload_done.emit()




## Resolves a cheer tier emote for a specific cheer.
## Can be null when not found.
func get_cheer_tier(prefix: String, tier: String, theme: Themes = Themes.DARK, type: Types = Types.ANIMATED, scale: Scales = Scales._1) -> CheerResult:
	await preload_cheemote()
	var cheermote : TwitchCheermote = cheermotes[prefix]
	for cheertier in cheermote.tiers:
		if cheertier.id == tier:
			var sprite_frames = await _get_sprite_frames(cheermote, cheertier, theme, type, scale)
			return CheerResult.new(cheermote, cheertier, sprite_frames)
	return null


func find_cheer_tier(number: int, cheer_data: TwitchCheermote) -> TwitchCheermote.Tiers:
	var current_tier: TwitchCheermote.Tiers = cheer_data.tiers[0]
	for tier: TwitchCheermote.Tiers in cheer_data.tiers:
		if tier.min_bits < number && current_tier.min_bits < tier.min_bits:
			current_tier = tier
	return current_tier


func _get_sprite_frames(cheermote: TwitchCheermote, tier: TwitchCheermote.Tiers, theme: Themes, type: Types, scale: Scales) -> SpriteFrames:
	var id = _get_id(cheermote, tier, theme, type, scale)
	if ResourceLoader.has_cached(id):
		return ResourceLoader.load(id)
	else:
		var request = _request_cheermote(tier, theme, type, scale)
		return await _wait_for_cheeremote(request, id)


## Return specified cheermote data in form of:
## Key: TwitchCheermote.Tiers  Value: SpriteFrames
func get_cheermotes(cheermote: TwitchCheermote, theme: Themes, type: Types, scale: Scales) -> Dictionary:
	await preload_cheemote()
	var response: Dictionary = {}
	var requests: Dictionary = {}
	for tier: TwitchCheermote.Tiers in cheermote.tiers:
		var id = _get_id(cheermote, tier, theme, type, scale)
		if ResourceLoader.has_cached(id): response[tier] = ResourceLoader.load(id)
		if not TwitchSetting.image_transformer.is_supporting_animation():
			type = Types.STATIC
		else: requests[tier] = _request_cheermote(tier, theme, type, scale)

	for tier: TwitchCheermote.Tiers in requests:
		var id = _get_id(cheermote, tier, theme, type, scale)
		var request = requests[tier]
		var sprite_frames = await _wait_for_cheeremote(request, id)
		response[tier] = sprite_frames
	return response


func _request_cheermote(cheer_tier: TwitchCheermote.Tiers, theme: Themes, type: Types, scale: Scales) -> BufferedHTTPClient.RequestData:
	var used_theme = themes[theme]
	var used_type = types_property[type]
	var used_scale = scales_property[scale]
	var img_path = cheer_tier.images[used_theme][used_type][used_scale] as String
	var host_result : RegExMatch = _HOST_PARSER.search(img_path)
	if host_result == null:
		var frames = SpriteFrames.new()
		frames.add_frame("default", _fallback_texture)
		return frames

	var host = host_result.get_string(1)
	var request_path = img_path.trim_prefix(host)
	var client = http_client_manager.get_client(host)
	var request = client.request(request_path, HTTPClient.METHOD_GET, {}, "")
	return request


func _wait_for_cheeremote(request: BufferedHTTPClient.RequestData, cheer_id: String) -> SpriteFrames:
	var client = request.client
	var image_transformer = TwitchSetting.image_transformer
	var response = await client.wait_for_request(request)
	var cache_path = TwitchSetting.cache_cheermote.path_join(cheer_id)
	var sprite_frames = await TwitchSetting.image_transformer.convert_image(
		cache_path,
		response.response_data,
		cache_path + ".res") as SpriteFrames
	sprite_frames.take_over_path(cheer_id)
	_cache[cheer_id] = sprite_frames
	return sprite_frames


func _get_id(cheermote: TwitchCheermote, tier: TwitchCheermote.Tiers, theme: Themes, type: Types, scale: Scales) -> String:
	return "/" + "/".join([ cheermote.prefix, tier.id, themes[theme], types_path[type], scales_path[scale] ])
