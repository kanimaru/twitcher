@tool
extends Node

## Will load badges, icons and profile images
class_name TwitchMediaLoader

var _image_transformers: Dictionary = {
	"NativeImageTransformer": NativeImageTransformer,
	"MagicImageTransformer": MagicImageTransformer,
	"TwitchImageTransformer": TwitchImageTransformer,
}

## Called when an emoji was succesfully loaded
signal emoji_loaded(definition: TwitchEmoteDefinition)

const FALLBACK_TEXTURE = preload("res://addons/twitcher/assets/fallback_texture.tres")
const FALLBACK_PROFILE = preload("res://addons/twitcher/assets/no_profile.png")

@export var api: TwitchAPI
@export_enum("NativeImageTransformer", "MagicImageTransformer", "TwitchImageTransformer") var image_transformer: String = "TwitchImageTransformer":
	set = update_image_transformer
@export var image_magic_path: String = "":
	set = update_image_magic_path
@export var fallback_texture: Texture2D = FALLBACK_TEXTURE
@export var fallback_profile: Texture2D = FALLBACK_PROFILE
@export var image_cdn_host: String = "https://static-cdn.jtvnw.net"

@export_global_dir var cache_emote: String = "user://emotes"
@export_global_dir var cache_badge: String = "user://badges"
@export_global_dir var cache_cheermote: String = "user://cheermote"

## All requests that are currently in progress
var _requests_in_progress : Array[StringName]
## Badge definition for global and the channel.
var _cached_badges : Dictionary = {}
## Emote definition for global and the channel.
var _cached_emotes : Dictionary = {}
## Key: String Cheer Prefix | Value: TwitchCheermote
var _cached_cheermotes: Dictionary = {}
var image_transformer_implementation: TwitchImageTransformer

## All cached emotes, badges, cheermotes
## Is needed that the garbage collector isn't deleting our cache.
var _cached_images : Array[SpriteFrames] = []
var _host_parser = RegEx.create_from_string("(https://.*?)/")
var static_image_transformer = TwitchImageTransformer.new()
var _client: BufferedHTTPClient

func _ready() -> void:
	_client = BufferedHTTPClient.new()
	_client.name = "TwitchMediaLoaderClient"
	add_child(_client)
	_load_cache()


## Loading all images from the directory into the memory cache
func _load_cache() -> void:
	_cache_directory(cache_emote)
	_cache_directory(cache_badge)


func _cache_directory(path: String):
	DirAccess.make_dir_recursive_absolute(path)
	var files = DirAccess.get_files_at(path)
	for file in files:
		if file.ends_with(".res"):
			var res_path = path.path_join(file)
			var sprite_frames: SpriteFrames = ResourceLoader.load(res_path, "SpriteFrames")
			var spriteframe_path = res_path.trim_suffix(".res")
			sprite_frames.take_over_path(spriteframe_path)
			_cached_images.append(sprite_frames)

#region Emotes

func preload_emotes(channel_id: String = "global") -> void:
	if (!_cached_emotes.has(channel_id)):
		var response
		if channel_id == "global":
			response = await api.get_global_emotes()
		else:
			response = await api.get_channel_emotes(channel_id)
		_cached_emotes[channel_id] = _map_emotes(response)


## Returns requested emotes.
## Key: EmoteID as String | Value: SpriteFrames
func get_emotes(emote_ids : Array[String]) -> Dictionary:
	var requests: Array[TwitchEmoteDefinition] = []
	for id in emote_ids:
		requests.append(TwitchEmoteDefinition.new(id))
	var emotes = await get_emotes_by_definition(requests)
	var result = {}
	# Remap the emotes to string value easier for processing
	for requested_emote in requests:
		result[requested_emote.id] = emotes[requested_emote]
	return result


## Returns requested emotes.
## Key: TwitchEmoteDefinition | Value: SpriteFrames
func get_emotes_by_definition(emote_definitions : Array[TwitchEmoteDefinition]) -> Dictionary:
	var response: Dictionary = {}
	var requests: Dictionary = {}

	for emote_definition: TwitchEmoteDefinition in emote_definitions:
		var cache_path: String = _get_emote_cache_path(emote_definition)
		var spriteframe_path: String = _get_emote_cache_path_spriteframe(emote_definition)
		print("Loaded: ", spriteframe_path)
		if ResourceLoader.has_cached(cache_path):
			response[emote_definition] = ResourceLoader.load(spriteframe_path)
			continue

		if not image_transformer_implementation.is_supporting_animation():
			emote_definition.type_static()

		if _requests_in_progress.has(cache_path): continue
		_requests_in_progress.append(cache_path)
		var request : BufferedHTTPClient.RequestData = _load_emote(emote_definition)
		requests[emote_definition] = request

	for emote_definition: TwitchEmoteDefinition in requests:
		var cache_path: String = _get_emote_cache_path(emote_definition)
		var spriteframe_path: String = _get_emote_cache_path_spriteframe(emote_definition)
		var request = requests[emote_definition]
		var sprite_frames = await _convert_response(request, cache_path, spriteframe_path)
		response[emote_definition] = sprite_frames
		_cached_images.append(sprite_frames)
		_requests_in_progress.erase(cache_path)
		emoji_loaded.emit(emote_definition)

	for emote_definition: TwitchEmoteDefinition in emote_definitions:
		if not response.has(emote_definition):
			var cache = _get_emote_cache_path_spriteframe(emote_definition)
			response[emote_definition] = ResourceLoader.load(cache)

	return response


## Returns the path where the raw emoji should be cached
func _get_emote_cache_path(emote_definition: TwitchEmoteDefinition) -> String:
	var file_name = emote_definition.get_file_name()
	return cache_emote.path_join(file_name)


## Returns the path where the converted spriteframe should be cached
func _get_emote_cache_path_spriteframe(emote_definition: TwitchEmoteDefinition) -> String:
	var file_name = emote_definition.get_file_name() + ".res"
	return cache_emote.path_join(file_name)


func _load_emote(emote_definition : TwitchEmoteDefinition) -> BufferedHTTPClient.RequestData:
	var request_path = "/emoticons/v2/%s/%s/%s/%1.1f" % [emote_definition.id, emote_definition._type, emote_definition._theme, emote_definition._scale]
	return _client.request(image_cdn_host + request_path, HTTPClient.METHOD_GET, {}, "")


func _map_emotes(result: Variant) -> Dictionary:
	var mappings : Dictionary = {}
	var emotes : Array = result.get("data")
	if emotes == null:
		return mappings
	for emote in emotes:
		mappings[emote.get("id")] = emote
	return mappings


func get_cached_emotes(channel_id) -> Dictionary:
	if not _cached_emotes.has(channel_id):
		await preload_emotes(channel_id)
	return _cached_emotes[channel_id]

#endregion

#region Badges

func preload_badges(channel_id: String = "global") -> void:
	if not _cached_badges.has(channel_id):
		var response
		if channel_id == "global":
			response = await(api.get_global_chat_badges())
		else:
			response = await(api.get_channel_chat_badges(channel_id))
		_cached_badges[channel_id] = _cache_badges(response)


## Returns the requested badge either from cache or loads from web. Scale can be 1, 2 or 4.
## Key: TwitchBadgeDefinition | Value: SpriteFrames
func get_badges(badges: Array[TwitchBadgeDefinition]) -> Dictionary:
	var response: Dictionary = {}
	var requests: Dictionary = {}

	for badge_definition in badges:
		var cache_id : String = badge_definition.get_cache_id()
		var badge_path : String = cache_badge.path_join(cache_id)
		if ResourceLoader.has_cached(badge_path):
			response[badge_definition] = ResourceLoader.load(badge_path)
		else:
			var request = await _load_badge(badge_definition)
			requests[badge_definition] = request

	for badge_definition in requests:
		var request = requests[badge_definition]
		var id : String = badge_definition.get_cache_id()
		var cache_path : String = cache_badge.path_join(id)
		var spriteframe_path : String = cache_badge.path_join(id) + ".res"
		var sprite_frames = await _convert_response(request, cache_path, spriteframe_path)
		response[badge_definition] = sprite_frames
		_cached_images.append(sprite_frames)

	return response


func _load_badge(badge_definition: TwitchBadgeDefinition) -> BufferedHTTPClient.RequestData:
	var channel_id = badge_definition.channel
	var badge_set = badge_definition.badge_set
	var badge_id = badge_definition.badge_id
	var scale = badge_definition.scale

	var is_global_chanel = channel_id == "global"
	if not _cached_badges.has(channel_id):
		await preload_badges(channel_id)
	var channel_has_badge = _cached_badges[channel_id].has(badge_set) && _cached_badges[channel_id][badge_set]["versions"].has(badge_id)
	if not is_global_chanel and not channel_has_badge:
		badge_definition.channel = "global"
		return await _load_badge(badge_definition)

	var request_path = _cached_badges[channel_id][badge_set]["versions"][badge_id]["image_url_%sx" % scale]
	return _client.request(request_path, HTTPClient.METHOD_GET, {}, "")


## Maps the badges into a dict of category / versions / badge_id
func _cache_badges(result: Variant) -> Dictionary:
	var mappings : Dictionary = {}
	var badges : Array = result["data"]
	for badge in badges:
		if not mappings.has(badge["set_id"]):
			mappings[badge["set_id"]] = {
				"set_id": badge["set_id"],
				"versions" : {}
			}
		for version in badge["versions"]:
			mappings[badge["set_id"]]["versions"][version["id"]] = version
	return mappings


func get_cached_badges(channel_id) -> Dictionary:
	if(!_cached_badges.has(channel_id)):
		await preload_badges(channel_id)
	return _cached_badges[channel_id]
#endregion

#region Cheermote

class CheerResult extends RefCounted:
	var cheermote: TwitchCheermote
	var tier: TwitchCheermote.Tiers
	var spriteframes: SpriteFrames
	func _init(cheer: TwitchCheermote, t: TwitchCheermote.Tiers, sprites: SpriteFrames):
		cheermote = cheer
		tier = t
		spriteframes = sprites


func preload_cheemote() -> void:
	if not _cached_cheermotes.is_empty(): return
	var cheermote_response: TwitchGetCheermotesResponse = await api.get_cheermotes()
	for data: TwitchCheermote in cheermote_response.data:
		_cached_cheermotes[data.prefix] = data


func all_cheermotes() -> Array[TwitchCheermote]:
	var cheermotes: Array[TwitchCheermote] = []
	cheermotes.assign(_cached_cheermotes.values())
	return cheermotes

## Resolves a info with spriteframes for a specific cheer definition contains also spriteframes for the given tier.
## Can be null when not found.
func get_cheer_info(cheermote_definition: TwitchCheermoteDefinition) -> CheerResult:
	await preload_cheemote()
	var cheermote : TwitchCheermote = _cached_cheermotes[cheermote_definition.prefix]
	for cheertier in cheermote.tiers:
		if cheertier.id == cheermote_definition.tier:
			var sprite_frames = await _get_cheermote_sprite_frames(cheertier, cheermote_definition)
			return CheerResult.new(cheermote, cheertier, sprite_frames)
	return null


func find_cheer_tier(number: int, cheer_data: TwitchCheermote) -> TwitchCheermote.Tiers:
	var current_tier: TwitchCheermote.Tiers = cheer_data.tiers[0]
	for tier: TwitchCheermote.Tiers in cheer_data.tiers:
		if tier.min_bits < number && current_tier.min_bits < tier.min_bits:
			current_tier = tier
	return current_tier


## Returns spriteframes mapped by tier for a cheermote
## Key: TwitchCheermote.Tiers | Value: SpriteFrames
func get_cheermotes(cheermote_definition: TwitchCheermoteDefinition) -> Dictionary:
	await preload_cheemote()
	var response: Dictionary = {}
	var requests: Dictionary = {}
	var cheer = _cached_cheermotes[cheermote_definition.prefix]
	for tier: TwitchCheermote.Tiers in cheer.tiers:
		var id = cheermote_definition.get_id()
		if ResourceLoader.has_cached(id): response[tier] = ResourceLoader.load(id)
		if not image_transformer_implementation.is_supporting_animation():
			cheermote_definition.type_static()
		else: requests[tier] = _request_cheermote(tier, cheermote_definition)

	for tier: TwitchCheermote.Tiers in requests:
		var id = cheermote_definition.get_id()
		var request = requests[tier]
		var sprite_frames = await _wait_for_cheeremote(request, id)
		response[tier] = sprite_frames
	return response


func _get_cheermote_sprite_frames(tier: TwitchCheermote.Tiers, cheermote_definition: TwitchCheermoteDefinition) -> SpriteFrames:
	var id = cheermote_definition.get_id()
	if ResourceLoader.has_cached(id):
		return ResourceLoader.load(id)
	else:
		var request = _request_cheermote(tier, cheermote_definition)
		if request == null:
			var frames := SpriteFrames.new()
			frames.add_frame("default", fallback_texture)
			return frames
		return await _wait_for_cheeremote(request, id)


func _wait_for_cheeremote(request: BufferedHTTPClient.RequestData, cheer_id: String) -> SpriteFrames:
	var response = await _client.wait_for_request(request)
	var cache_path = cache_cheermote.path_join(cheer_id)
	var sprite_frames = await image_transformer_implementation.convert_image(
		cache_path,
		response.response_data,
		cache_path + ".res") as SpriteFrames
	sprite_frames.take_over_path(cheer_id)
	_cached_images.append(sprite_frames)
	return sprite_frames


func _request_cheermote(cheer_tier: TwitchCheermote.Tiers, cheermote: TwitchCheermoteDefinition) -> BufferedHTTPClient.RequestData:
	var img_path = cheer_tier.images[cheermote.theme][cheermote.type][cheermote.scale] as String
	var host_result : RegExMatch = _host_parser.search(img_path)
	if host_result == null: return null
	var host = host_result.get_string(1)
	var request = _client.request(img_path, HTTPClient.METHOD_GET, {}, "")
	return request

#endregion

#region Utilities

func _get_configuration_warnings() -> PackedStringArray:
	if not image_transformer_implementation.is_supported():
		return ["Image transformer is misconfigured"]
	return []


func update_image_transformer(transformer_name: String) -> void:
	if transformer_name == "" || transformer_name == null:
		image_transformer = "TwitchImageTransformer"
		image_transformer_implementation = TwitchImageTransformer.new()
	else:
		image_transformer = transformer_name
		image_transformer_implementation = _image_transformers[transformer_name].new()
		update_image_magic_path(image_magic_path)
		if "fallback_texture" in image_transformer_implementation:
			image_transformer_implementation.fallback_texture = fallback_texture
	update_configuration_warnings()
	notify_property_list_changed()


func update_image_magic_path(path: String) -> void:
	image_magic_path = path
	if image_transformer_implementation is MagicImageTransformer:
		image_transformer_implementation.imagemagic_path = path
	update_configuration_warnings()


## Get the image of an user
func load_profile_image(user: TwitchUser) -> ImageTexture:
	if user == null: return fallback_profile
	if ResourceLoader.has_cached(user.profile_image_url):
		return ResourceLoader.load(user.profile_image_url)
	var request := _client.request(user.profile_image_url, HTTPClient.METHOD_GET, {}, "")
	var response_data := await _client.wait_for_request(request)
	var texture : ImageTexture = ImageTexture.new()
	var response := response_data.response_data
	if not response.is_empty():
		var img := Image.new()
		var content_type = response_data.response_header["Content-Type"]

		match content_type:
			"image/png": img.load_png_from_buffer(response)
			"image/jpeg": img.load_jpg_from_buffer(response)
			_: return fallback_profile
		texture.set_image(img)
	else:
		# Don't use `texture = fallback_profile` as texture cause the path will be taken over
		# for caching purpose!
		texture.set_image(fallback_profile.get_image())
	texture.take_over_path(user.profile_image_url)
	return texture


const GIF_HEADER: PackedByteArray = [71, 73, 70]
func _convert_response(request: BufferedHTTPClient.RequestData, cache_path: String, spriteframe_path: String) -> SpriteFrames:
	var response = await _client.wait_for_request(request)
	var response_data = response.response_data as PackedByteArray
	var file_head = response_data.slice(0, 3)
	# REMARK: don't use content-type... twitch doesn't check and sends PNGs with GIF content type.
	if file_head == GIF_HEADER:
		return await image_transformer_implementation.convert_image(cache_path, response_data, spriteframe_path) as SpriteFrames
	else:
		return await static_image_transformer.convert_image(cache_path, response_data, spriteframe_path) as SpriteFrames

#endregion
