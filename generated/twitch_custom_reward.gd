@tool
extends RefCounted

class_name TwitchCustomReward

## The ID that uniquely identifies the broadcaster.
var broadcaster_id: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The ID that uniquely identifies this custom reward.
var id: String;
## The title of the reward.
var title: String;
## The prompt shown to the viewer when they redeem the reward if user input is required. See the `is_user_input_required` field.
var prompt: String;
## The cost of the reward in Channel Points.
var cost: int;
## A set of custom images for the reward. This field is **null** if the broadcaster didn’t upload images.
var image: CustomRewardImage;
## A set of default images for the reward.
var default_image: CustomRewardDefaultImage;
## The background color to use for the reward. The color is in Hex format (for example, #00E5CB).
var background_color: String;
## A Boolean value that determines whether the reward is enabled. Is **true** if enabled; otherwise, **false**. Disabled rewards aren’t shown to the user.
var is_enabled: bool;
## A Boolean value that determines whether the user must enter information when they redeem the reward. Is **true** if the user is prompted.
var is_user_input_required: bool;
## The settings used to determine whether to apply a maximum to the number of redemptions allowed per live stream.
var max_per_stream_setting: CustomRewardMaxPerStreamSetting;
## The settings used to determine whether to apply a maximum to the number of redemptions allowed per user per live stream.
var max_per_user_per_stream_setting: CustomRewardMaxPerUserPerStreamSetting;
## The settings used to determine whether to apply a cooldown period between redemptions and the length of the cooldown.
var global_cooldown_setting: CustomRewardGlobalCooldownSetting;
## A Boolean value that determines whether the reward is currently paused. Is **true** if the reward is paused. Viewers can’t redeem paused rewards.
var is_paused: bool;
## A Boolean value that determines whether the reward is currently in stock. Is **true** if the reward is in stock. Viewers can’t redeem out of stock rewards.
var is_in_stock: bool;
## A Boolean value that determines whether redemptions should be set to FULFILLED status immediately when a reward is redeemed. If **false**, status is set to UNFULFILLED and follows the normal request queue process.
var should_redemptions_skip_request_queue: bool;
## The number of redemptions redeemed during the current live stream. The number counts against the `max_per_stream_setting` limit. This field is **null** if the broadcaster’s stream isn’t live or _max\_per\_stream\_setting_ isn’t enabled.
var redemptions_redeemed_current_stream: int;
## The timestamp of when the cooldown period expires. Is **null** if the reward isn’t in a cooldown state. See the `global_cooldown_setting` field.
var cooldown_expires_at: Variant;

static func from_json(d: Dictionary) -> TwitchCustomReward:
	var result = TwitchCustomReward.new();




















	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};








	d["image"] = image.to_dict();
{else}
	d["image"] = image;


	d["default_image"] = default_image.to_dict();
{else}
	d["default_image"] = default_image;





	d["max_per_stream_setting"] = max_per_stream_setting.to_dict();
{else}
	d["max_per_stream_setting"] = max_per_stream_setting;


	d["max_per_user_per_stream_setting"] = max_per_user_per_stream_setting.to_dict();
{else}
	d["max_per_user_per_stream_setting"] = max_per_user_per_stream_setting;


	d["global_cooldown_setting"] = global_cooldown_setting.to_dict();
{else}
	d["global_cooldown_setting"] = global_cooldown_setting;






	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## A set of custom images for the reward. This field is **null** if the broadcaster didn’t upload images.
class CustomRewardImage extends RefCounted:
	## The URL to a small version of the image.
	var url_1x: String;
	## The URL to a medium version of the image.
	var url_2x: String;
	## The URL to a large version of the image.
	var url_4x: String;

	static func from_json(d: Dictionary) -> CustomRewardImage:
		var result = CustomRewardImage.new();
		result.url_1x = d["url_1x"];
		result.url_2x = d["url_2x"];
		result.url_4x = d["url_4x"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["url_1x"] = url_1x;
		d["url_2x"] = url_2x;
		d["url_4x"] = url_4x;
		return d;

## A set of default images for the reward.
class CustomRewardDefaultImage extends RefCounted:
	## The URL to a small version of the image.
	var url_1x: String;
	## The URL to a medium version of the image.
	var url_2x: String;
	## The URL to a large version of the image.
	var url_4x: String;

	static func from_json(d: Dictionary) -> CustomRewardDefaultImage:
		var result = CustomRewardDefaultImage.new();
		result.url_1x = d["url_1x"];
		result.url_2x = d["url_2x"];
		result.url_4x = d["url_4x"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["url_1x"] = url_1x;
		d["url_2x"] = url_2x;
		d["url_4x"] = url_4x;
		return d;

## The settings used to determine whether to apply a maximum to the number of redemptions allowed per live stream.
class CustomRewardMaxPerStreamSetting extends RefCounted:
	## A Boolean value that determines whether the reward applies a limit on the number of redemptions allowed per live stream. Is **true** if the reward applies a limit.
	var is_enabled: bool;
	## The maximum number of redemptions allowed per live stream.
	var max_per_stream: int;

	static func from_json(d: Dictionary) -> CustomRewardMaxPerStreamSetting:
		var result = CustomRewardMaxPerStreamSetting.new();
		result.is_enabled = d["is_enabled"];
		result.max_per_stream = d["max_per_stream"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["is_enabled"] = is_enabled;
		d["max_per_stream"] = max_per_stream;
		return d;

## The settings used to determine whether to apply a maximum to the number of redemptions allowed per user per live stream.
class CustomRewardMaxPerUserPerStreamSetting extends RefCounted:
	## A Boolean value that determines whether the reward applies a limit on the number of redemptions allowed per user per live stream. Is **true** if the reward applies a limit.
	var is_enabled: bool;
	## The maximum number of redemptions allowed per user per live stream.
	var max_per_user_per_stream: int;

	static func from_json(d: Dictionary) -> CustomRewardMaxPerUserPerStreamSetting:
		var result = CustomRewardMaxPerUserPerStreamSetting.new();
		result.is_enabled = d["is_enabled"];
		result.max_per_user_per_stream = d["max_per_user_per_stream"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["is_enabled"] = is_enabled;
		d["max_per_user_per_stream"] = max_per_user_per_stream;
		return d;

## The settings used to determine whether to apply a cooldown period between redemptions and the length of the cooldown.
class CustomRewardGlobalCooldownSetting extends RefCounted:
	## A Boolean value that determines whether to apply a cooldown period. Is **true** if a cooldown period is enabled.
	var is_enabled: bool;
	## The cooldown period, in seconds.
	var global_cooldown_seconds: int;

	static func from_json(d: Dictionary) -> CustomRewardGlobalCooldownSetting:
		var result = CustomRewardGlobalCooldownSetting.new();
		result.is_enabled = d["is_enabled"];
		result.global_cooldown_seconds = d["global_cooldown_seconds"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["is_enabled"] = is_enabled;
		d["global_cooldown_seconds"] = global_cooldown_seconds;
		return d;

