extends RefCounted

## Definition to load or specify one specific badge
class_name TwitchBadgeDefinition

var badge_set: String
var badge_id: String
var scale: int
var channel: String

var _cache_id: String # This is maybe a bad idea, but solves the issue when the badge won't get found in cache and then it changes the channel to global during loading and so also the cache id

func scale_1() -> TwitchBadgeDefinition: scale = 1; return self;
func scale_2() -> TwitchBadgeDefinition: scale = 2; return self;
func scale_4() -> TwitchBadgeDefinition: scale = 4; return self;


func _init(set_id: String, id: String, badge_scale: int, badge_channel: String) -> void:
	badge_set = set_id
	badge_id = id
	assert(badge_scale == 1 || badge_scale == 2 || badge_scale == 4)
	scale = badge_scale
	channel = badge_channel
	_cache_id = "_".join([
		channel,
		badge_set,
		badge_id,
		scale
	])


func _to_string() -> String:
	return "Badge[%s/%s/%s]" % [channel, badge_set, badge_id]

func get_cache_id() -> String:
	return _cache_id
