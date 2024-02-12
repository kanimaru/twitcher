extends RefCounted

class_name TwitchCheerRepository

signal ready;

class CheerData extends RefCounted:
	var prefix: String;
	var tiers: Array[CheerTier];
	var type: String;
	var order: int;
	var last_updated: String;
	var is_charitable: bool;

	func _init(json: Dictionary) -> void:
		prefix = json['prefix'];
		tiers = load_tiers(json['tiers']);

		type = json['type'];
		order = json['order'];
		last_updated = json['last_updated'];
		is_charitable = json['is_charitable'];

	func load_tiers(tiers_json: Array) -> Array[CheerTier]:
		var result : Array[CheerTier] = [];
		for tier in tiers_json:
			var cheer_tier = CheerTier.new(tier);
			cheer_tier.parent = self;
			result.append(cheer_tier);
		return result;

class CheerTier:
	var parent: CheerData;
	var min_bits: int;
	var id: String;
	var color: String;
	var images: Dictionary;
	var can_cheer: bool;
	var show_in_bits_card: bool;

	func _init(json: Dictionary) -> void:
		min_bits = json['min_bits'];
		id = json['id'];
		color = json['color'];
		images = json['images'];
		can_cheer = json['can_cheer'];
		show_in_bits_card = json['show_in_bits_card'];

	func get_id(theme: String, type: String, scale: String) -> String:
		return "/" + "/".join([ parent.prefix, id, theme, type, scale ]);

var HOST_PARSER = RegEx.create_from_string("(https://.*?)/");
var fallback_texture: Texture2D
var data: Array[CheerData];
var is_ready: bool;
var _cache: Dictionary;

func _init(api: TwitchRestAPI) -> void:
	fallback_texture = TwitchSetting.fallback_texture2d;
	var cheer_emote_response: TwitchGetCheermotesResponse = await api.get_cheermotes();
	#for d in cheer_emote_response.data: TODO
	#	data.append(CheerData.new(d));
	is_ready = true;
	ready.emit();

func wait_is_ready(): if !is_ready: await ready;

func get_cheer_tier(cheer: String) -> CheerTier:
	for cheer_data: CheerData in data:
		if cheer.begins_with(cheer_data.prefix):
			var number := int(cheer.trim_prefix(cheer_data.prefix));
			return find_cheer_tier(number, cheer_data);
	return null;

func find_cheer_tier(number: int, cheer_data: CheerData) -> CheerTier:
	var current_tier: CheerTier = cheer_data.tiers[0];
	for tier: CheerTier in cheer_data.tiers:
		if tier.min_bits < number && current_tier.min_bits < tier.min_bits:
			current_tier = tier;
	return current_tier;

## Return value is a dictionary of CheerTier x SpriteFrames
func get_cheermotes(cheer_tiers: Array[CheerTier], theme: String, type: String, scale: String) -> Dictionary:
	var response: Dictionary = {};
	var requests: Dictionary = {};
	for tier in cheer_tiers:
		var id = tier.get_id(theme, type, scale);
		if ResourceLoader.has_cached(id): response[tier] = ResourceLoader.load(id);
		else: requests[tier] = _load_cheermote(tier, theme, type, scale);

	for tier in requests:
		var id = tier.get_id(theme, type, scale);
		var request = requests[tier];
		var sprite_frames = await _wait_for_cheeremote(request, id);
		response[tier] = sprite_frames;
	return response;

func is_cheermote_prefix_existing(prefix: String) -> bool:
	for cheer_data in data:
		if cheer_data.prefix == prefix:
			return true;

	return false;


func _load_cheermote(cheer_tier: CheerTier, theme: String, type: String, scale: String) -> BufferedHTTPClient.RequestData:
	var img_path = cheer_tier.images[theme][type][scale] as String;
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
	var response = await client.wait_for_request(request);
	var sprite_frames = await TwitchSetting.image_transformer.dump_and_convert("user://cheermotes/%s" % cheer_id, response.response_data) as SpriteFrames;
	sprite_frames.take_over_path(cheer_id);
	_cache[cheer_id] = sprite_frames;
	return sprite_frames;
