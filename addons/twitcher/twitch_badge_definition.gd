extends RefCounted

## Definition to load or specify one specific badge
class_name TwitchBadgeDefinition

var badge_set: String
var badge_id: String
var scale: int
var channel: String

func scale_1() -> TwitchBadgeDefinition: scale = 1; return self;
func scale_2() -> TwitchBadgeDefinition: scale = 2; return self;
func scale_4() -> TwitchBadgeDefinition: scale = 4; return self;

func _init(set_id: String, id: String, badge_scale: int, badge_channel: String) -> void:
	badge_set = set_id
	badge_id = id
	assert(badge_scale == 1 || badge_scale == 2 || badge_scale == 4)
	scale = badge_scale
	channel = badge_channel

func get_cache_id() -> String:
	return "_".join([
		channel,
		badge_set,
		badge_id,
		scale
	])
