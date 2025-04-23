@icon("res://addons/twitcher/assets/media-loader-icon.svg")
@tool
extends Twitcher

## Will load badges, icons and profile images
class_name TwitchMediaLoader

static var _log: TwitchLogger  = TwitchLogger.new("TwitchMediaLoader")

static var instance: TwitchMediaLoader

## Called when an emoji was succesfully loaded
signal emoji_loaded(definition: TwitchEmoteDefinition)

const FALLBACK_TEXTURE = preload("res://addons/twitcher/assets/fallback_texture.tres")
const FALLBACK_PROFILE = preload("res://addons/twitcher/assets/no_profile.png")

@export var api: TwitchAPI
@export var image_transformer: TwitchImageTransformer = TwitchImageTransformer.new(): 
	set(val):
		image_transformer = val
		update_configuration_warnings()
@export var fallback_texture: Texture2D = FALLBACK_TEXTURE
@export var fallback_profile: Texture2D = FALLBACK_PROFILE
@export var image_cdn_host: String = "https://static-cdn.jtvnw.net"
## Will preload the whole badge and emote cache also to editor time (use it when you make a Editor Plugin with Twitch Support)
@export var load_cache_in_editor: bool

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
var _cached_cheermotes: Dictionary[String, TwitchCheermote] = {}

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
	if api == null: api = TwitchAPI.instance


func _enter_tree() -> void:
	if instance == null: instance = self
	
	
func _exit_tree() -> void:
	if instance == self: instance = null
	

## Loading all images from the directory into the memory cache
func _load_cache() -> void:
	if Engine.is_editor_hint() || load_cache_in_editor:
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
			_log.i("Preload global emotes")
			response = await api.get_global_emotes()
		else:
			_log.i("Preload channel(%s) emotes" % channel_id)
			response = await api.get_channel_emotes(channel_id)
		_cached_emotes[channel_id] = _map_emotes(response)


## Returns requested emotes.
## Key: EmoteID as String | Value: SpriteFrames
func get_emotes(emote_ids : Array[String]) -> Dictionary[String, SpriteFrames]:
	_log.i("Get emotes: %s" % emote_ids)
	var requests: Array[TwitchEmoteDefinition] = []
	for id: String in emote_ids:
		requests.append(TwitchEmoteDefinition.new(id))
	var emotes: Dictionary[TwitchEmoteDefinition, SpriteFrames] = await get_emotes_by_definition(requests)
	var result: Dictionary[String, SpriteFrames] = {}
	# Remap the emotes to string value easier for processing
	for requested_emote: TwitchEmoteDefinition in requests:
		result[requested_emote.id] = emotes[requested_emote]
	return result


## Returns requested emotes.
## Key: TwitchEmoteDefinition | Value: SpriteFrames
func get_emotes_by_definition(emote_definitions : Array[TwitchEmoteDefinition]) -> Dictionary[TwitchEmoteDefinition, SpriteFrames]:
	var response: Dictionary[TwitchEmoteDefinition, SpriteFrames] = {}
	var requests: Dictionary[TwitchEmoteDefinition, BufferedHTTPClient.RequestData] = {}

	for emote_definition: TwitchEmoteDefinition in emote_definitions:
		var original_file_cache_path: String = _get_emote_cache_path(emote_definition)
		var spriteframe_path: String = _get_emote_cache_path_spriteframe(emote_definition)
		if ResourceLoader.has_cached(spriteframe_path):
			_log.d("Use cached emote %s" % emote_definition)
			response[emote_definition] = ResourceLoader.load(spriteframe_path)
			continue

		if not image_transformer.is_supporting_animation():
			emote_definition.type_static()

		if _requests_in_progress.has(original_file_cache_path): continue
		_requests_in_progress.append(original_file_cache_path)
		_log.d("Request emote %s" % emote_definition)
		var request : BufferedHTTPClient.RequestData = _load_emote(emote_definition)
		requests[emote_definition] = request

	for emote_definition : TwitchEmoteDefinition in requests:
		var original_file_cache_path : String = _get_emote_cache_path(emote_definition)
		var spriteframe_path : String = _get_emote_cache_path_spriteframe(emote_definition)		
		var request : BufferedHTTPClient.RequestData = requests[emote_definition]
		var sprite_frames : SpriteFrames = await _convert_response(request, original_file_cache_path, spriteframe_path)
		response[emote_definition] = sprite_frames
		_cached_images.append(sprite_frames)
		_requests_in_progress.erase(original_file_cache_path)
		emoji_loaded.emit(emote_definition)
		
	for emote_definition: TwitchEmoteDefinition in emote_definitions:
		if not response.has(emote_definition):
			var cache : String = _get_emote_cache_path_spriteframe(emote_definition)
			response[emote_definition] = ResourceLoader.load(cache)
	
	return response


## Returns the path where the raw emoji should be cached
func _get_emote_cache_path(emote_definition: TwitchEmoteDefinition) -> String:
	var file_name : String = emote_definition.get_file_name()
	return cache_emote.path_join(file_name)


## Returns the path where the converted spriteframe should be cached
func _get_emote_cache_path_spriteframe(emote_definition: TwitchEmoteDefinition) -> String:
	var file_name : String = emote_definition.get_file_name() + ".res"
	return cache_emote.path_join(file_name)


func _load_emote(emote_definition : TwitchEmoteDefinition) -> BufferedHTTPClient.RequestData:
	var request_path : String = "/emoticons/v2/%s/%s/%s/%1.1f" % [emote_definition.id, emote_definition._type, emote_definition._theme, emote_definition._scale]
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
		var response: Variant # TwitchGetGlobalChatBadges.Response | TwitchGetChannelChatBadges.Response
		if channel_id == "global":
			_log.i("Preload global badges")
			response = await(api.get_global_chat_badges())
		else:
			_log.i("Preload channel(%s) badges" % channel_id)
			response = await(api.get_channel_chat_badges(channel_id))
		_cached_badges[channel_id] = _cache_badges(response)


## Returns the requested badge either from cache or loads from web. Scale can be 1, 2 or 4.
## Key: TwitchBadgeDefinition | Value: SpriteFrames
func get_badges(badges: Array[TwitchBadgeDefinition]) -> Dictionary[TwitchBadgeDefinition, SpriteFrames]:
	var response: Dictionary[TwitchBadgeDefinition, SpriteFrames] = {}
	var requests: Dictionary[TwitchBadgeDefinition, BufferedHTTPClient.RequestData] = {}

	for badge_definition : TwitchBadgeDefinition in badges:
		var cache_id : String = badge_definition.get_cache_id()
		var badge_path : String = cache_badge.path_join(cache_id)
		if ResourceLoader.has_cached(badge_path):
			_log.d("Use cached badge %s" % badge_definition)
			response[badge_definition] = ResourceLoader.load(badge_path)
		else:
			_log.d("Request badge %s" % badge_definition)
			var request : BufferedHTTPClient.RequestData = await _load_badge(badge_definition)
			requests[badge_definition] = request

	for badge_definition : TwitchBadgeDefinition in requests:
		var request = requests[badge_definition]
		var id : String = badge_definition.get_cache_id()
		var cache_path : String = cache_badge.path_join(id)
		var spriteframe_path : String = cache_badge.path_join(id) + ".res"
		var sprite_frames : SpriteFrames = await _convert_response(request, cache_path, spriteframe_path)
		response[badge_definition] = sprite_frames
		_cached_images.append(sprite_frames)

	return response


func _load_badge(badge_definition: TwitchBadgeDefinition) -> BufferedHTTPClient.RequestData:
	var channel_id : String = badge_definition.channel
	var badge_set : String = badge_definition.badge_set
	var badge_id : String = badge_definition.badge_id
	var scale : int = badge_definition.scale

	var is_global_chanel : bool = channel_id == "global"
	if not _cached_badges.has(channel_id):
		await preload_badges(channel_id)
	var channel_has_badge : bool = _cached_badges[channel_id].has(badge_set) && _cached_badges[channel_id][badge_set]["versions"].has(badge_id)
	if not is_global_chanel and not channel_has_badge:
		badge_definition.channel = "global"
		return await _load_badge(badge_definition)

	var request_path : String = _cached_badges[channel_id][badge_set]["versions"][badge_id]["image_url_%sx" % scale]
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


func get_cached_badges(channel_id: String) -> Dictionary:
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
	_log.i("Preload cheermotes")
	var cheermote_response: TwitchGetCheermotes.Response = await api.get_cheermotes(null)
	for data: TwitchCheermote in cheermote_response.data:
		_log.d("- found %s" % data.prefix)
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
	for cheertier: TwitchCheermote.Tiers in cheermote.tiers:
		if cheertier.id == cheermote_definition.tier:
			var sprite_frames: SpriteFrames = await _get_cheermote_sprite_frames(cheertier, cheermote_definition)
			return CheerResult.new(cheermote, cheertier, sprite_frames)
	return null


## Finds the tier depending on the given number
func find_cheer_tier(number: int, cheer_data: TwitchCheermote) -> TwitchCheermote.Tiers:
	var current_tier: TwitchCheermote.Tiers = cheer_data.tiers[0]
	for tier: TwitchCheermote.Tiers in cheer_data.tiers:
		if tier.min_bits < number && current_tier.min_bits < tier.min_bits:
			current_tier = tier
	return current_tier


## Returns spriteframes mapped by tier for a cheermote
## Key: TwitchCheermote.Tiers | Value: SpriteFrames
func get_cheermotes(cheermote_definition: TwitchCheermoteDefinition) -> Dictionary[TwitchCheermote.Tiers, SpriteFrames]:
	await preload_cheemote()
	var response : Dictionary[TwitchCheermote.Tiers, SpriteFrames] = {}
	var requests : Dictionary[TwitchCheermote.Tiers, BufferedHTTPClient.RequestData] = {}
	var cheer : TwitchCheermote = _cached_cheermotes[cheermote_definition.prefix]
	for tier : TwitchCheermote.Tiers in cheer.tiers:
		var id = cheermote_definition.get_id()
		if ResourceLoader.has_cached(id): 
			_log.d("Use cached cheer %s" % cheermote_definition)
			response[tier] = ResourceLoader.load(id)
		if not image_transformer.is_supporting_animation():
			cheermote_definition.type_static()
		else: 
			_log.d("Request cheer %s" % cheermote_definition)
			requests[tier] = _request_cheermote(tier, cheermote_definition)

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
		var request : BufferedHTTPClient.RequestData = _request_cheermote(tier, cheermote_definition)
		if request == null:
			var frames : SpriteFrames = SpriteFrames.new()
			frames.add_frame("default", fallback_texture)
			return frames
		return await _wait_for_cheeremote(request, id)


func _wait_for_cheeremote(request: BufferedHTTPClient.RequestData, cheer_id: String) -> SpriteFrames:
	var response : BufferedHTTPClient.ResponseData = await _client.wait_for_request(request)
	var cache_path : String = cache_cheermote.path_join(cheer_id)
	var sprite_frames : SpriteFrames = await image_transformer.convert_image(
		cache_path,
		response.response_data,
		cache_path + ".res") as SpriteFrames
	sprite_frames.take_over_path(cheer_id)
	_cached_images.append(sprite_frames)
	return sprite_frames


func _request_cheermote(cheer_tier: TwitchCheermote.Tiers, cheermote: TwitchCheermoteDefinition) -> BufferedHTTPClient.RequestData:
	var img_path : String = cheer_tier.images[cheermote.theme][cheermote.type][cheermote.scale]
	var host_result : RegExMatch = _host_parser.search(img_path)
	if host_result == null: return null
	var host : String = host_result.get_string(1)
	return _client.request(img_path, HTTPClient.METHOD_GET, {}, "")
	

#endregion

#region Utilities

func _get_configuration_warnings() -> PackedStringArray:
	if image_transformer == null || not image_transformer.is_supported():
		return ["Image transformer is misconfigured"]
	return []


func load_image(url: String) -> Image:
	var request : BufferedHTTPClient.RequestData = _client.request(url, HTTPClient.METHOD_GET, {}, "")
	var response : BufferedHTTPClient.ResponseData = await _client.wait_for_request(request)
	var temp_file : FileAccess = FileAccess.create_temp(FileAccess.ModeFlags.WRITE_READ, "image_", url.get_extension(), true)
	temp_file.store_buffer(response.response_data)
	temp_file.flush()
	var image : Image = Image.load_from_file(temp_file.get_path())
	return image


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
		return await image_transformer.convert_image(cache_path, response_data, spriteframe_path) as SpriteFrames
	else:
		return await static_image_transformer.convert_image(cache_path, response_data, spriteframe_path) as SpriteFrames

#endregion
