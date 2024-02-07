extends RefCounted

class_name TwitchModifyRewardDto
var d: Dictionary;

var title: String:
	set(val): d["title"] = val;
var prompt: String:
	set(val): d["prompt"] = val;
var cost: int:
	set(val): d["cost"] = val;
var background_color: 	String:
	set(val): d["background_color"] = val;
var is_enabled: bool:
	set(val): d["is_enabled"] = val;
var is_user_input_required: bool:
	set(val): d["is_user_input_required"] = val;
var is_max_per_stream_enabled: 	bool:
	set(val): d["is_max_per_stream_enabled"] = val;
var max_per_stream: int:
	set(val): d["max_per_stream"] = val;
var is_max_per_user_per_stream_enabled: bool:
	set(val): d["is_max_per_user_per_stream_enabled"] = val;
var max_per_user_per_stream: int:
	set(val): d["max_per_user_per_stream"] = val;
var is_global_cooldown_enabled: bool:
	set(val): d["is_global_cooldown_enabled"] = val;
var global_cooldown_seconds: int:
	set(val): d["global_cooldown_seconds"] = val;
var is_paused: bool:
	set(val): d["is_paused"] = val;
var should_redemptions_skip_request_queue: bool:
	set(val): d["should_redemptions_skip_request_queue"] = val;

func to_json() -> String:
	return JSON.stringify(d);
