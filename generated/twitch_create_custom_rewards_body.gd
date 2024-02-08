@tool
extends RefCounted

class_name TwitchCreateCustomRewardsBody

## The custom reward’s title. The title may contain a maximum of 45 characters and it must be unique amongst all of the broadcaster’s custom rewards.
var title: String;
## The cost of the reward, in Channel Points. The minimum is 1 point.
var cost: int;
## The prompt shown to the viewer when they redeem the reward. Specify a prompt if `is_user_input_required` is **true**. The prompt is limited to a maximum of 200 characters.
var prompt: String;
## A Boolean value that determines whether the reward is enabled. Viewers see only enabled rewards. The default is **true**.
var is_enabled: bool;
## The background color to use for the reward. Specify the color using Hex format (for example, #9147FF).
var background_color: String;
## A Boolean value that determines whether the user needs to enter information when redeeming the reward. See the `prompt` field. The default is **false**.
var is_user_input_required: bool;
## A Boolean value that determines whether to limit the maximum number of redemptions allowed per live stream (see the `max_per_stream` field). The default is **false**.
var is_max_per_stream_enabled: bool;
## The maximum number of redemptions allowed per live stream. Applied only if `is_max_per_stream_enabled` is **true**. The minimum value is 1.
var max_per_stream: int;
## A Boolean value that determines whether to limit the maximum number of redemptions allowed per user per stream (see the `max_per_user_per_stream` field). The default is **false**.
var is_max_per_user_per_stream_enabled: bool;
## The maximum number of redemptions allowed per user per stream. Applied only if `is_max_per_user_per_stream_enabled` is **true**. The minimum value is 1.
var max_per_user_per_stream: int;
## A Boolean value that determines whether to apply a cooldown period between redemptions (see the `global_cooldown_seconds` field for the duration of the cooldown period). The default is **false**.
var is_global_cooldown_enabled: bool;
## The cooldown period, in seconds. Applied only if the `is_global_cooldown_enabled` field is **true**. The minimum value is 1; however, the minimum value is 60 for it to be shown in the Twitch UX.
var global_cooldown_seconds: int;
## A Boolean value that determines whether redemptions should be set to FULFILLED status immediately when a reward is redeemed. If **false**, status is set to UNFULFILLED and follows the normal request queue process. The default is **false**.
var should_redemptions_skip_request_queue: bool;

static func from_json(d: Dictionary) -> TwitchCreateCustomRewardsBody:
	var result = TwitchCreateCustomRewardsBody.new();
	result.title = d["title"];
	result.cost = d["cost"];
	result.prompt = d["prompt"];
	result.is_enabled = d["is_enabled"];
	result.background_color = d["background_color"];
	result.is_user_input_required = d["is_user_input_required"];
	result.is_max_per_stream_enabled = d["is_max_per_stream_enabled"];
	result.max_per_stream = d["max_per_stream"];
	result.is_max_per_user_per_stream_enabled = d["is_max_per_user_per_stream_enabled"];
	result.max_per_user_per_stream = d["max_per_user_per_stream"];
	result.is_global_cooldown_enabled = d["is_global_cooldown_enabled"];
	result.global_cooldown_seconds = d["global_cooldown_seconds"];
	result.should_redemptions_skip_request_queue = d["should_redemptions_skip_request_queue"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["title"] = title;
	d["cost"] = cost;
	d["prompt"] = prompt;
	d["is_enabled"] = is_enabled;
	d["background_color"] = background_color;
	d["is_user_input_required"] = is_user_input_required;
	d["is_max_per_stream_enabled"] = is_max_per_stream_enabled;
	d["max_per_stream"] = max_per_stream;
	d["is_max_per_user_per_stream_enabled"] = is_max_per_user_per_stream_enabled;
	d["max_per_user_per_stream"] = max_per_user_per_stream;
	d["is_global_cooldown_enabled"] = is_global_cooldown_enabled;
	d["global_cooldown_seconds"] = global_cooldown_seconds;
	d["should_redemptions_skip_request_queue"] = should_redemptions_skip_request_queue;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

