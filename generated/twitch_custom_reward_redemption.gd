@tool
extends RefCounted

class_name TwitchCustomRewardRedemption

## The ID that uniquely identifies the broadcaster.
var broadcaster_id: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The ID that uniquely identifies this redemption..
var id: String;
## The ID of the user that redeemed the reward.
var user_id: String;
## The user’s display name.
var user_name: String;
## The user’s login name.
var user_login: String;
## An object that describes the reward that the user redeemed.
var reward: CustomRewardRedemptionReward;
## The text that the user entered at the prompt when they redeemed the reward; otherwise, an empty string if user input was not required.
var user_input: String;
## The state of the redemption. Possible values are:      * CANCELED * FULFILLED * UNFULFILLED
var status: String;
## The date and time of when the reward was redeemed, in RFC3339 format.
var redeemed_at: Variant;

static func from_json(d: Dictionary) -> TwitchCustomRewardRedemption:
	var result = TwitchCustomRewardRedemption.new();
	result.broadcaster_id = d["broadcaster_id"];
	result.broadcaster_login = d["broadcaster_login"];
	result.broadcaster_name = d["broadcaster_name"];
	result.id = d["id"];
	result.user_id = d["user_id"];
	result.user_name = d["user_name"];
	result.user_login = d["user_login"];

	result.reward = CustomRewardRedemptionReward.from_json(d["reward"]);

	result.user_input = d["user_input"];
	result.status = d["status"];
	result.redeemed_at = d["redeemed_at"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["broadcaster_id"] = broadcaster_id;
	d["broadcaster_login"] = broadcaster_login;
	d["broadcaster_name"] = broadcaster_name;
	d["id"] = id;
	d["user_id"] = user_id;
	d["user_name"] = user_name;
	d["user_login"] = user_login;

	d["reward"] = reward.to_dict();

	d["user_input"] = user_input;
	d["status"] = status;
	d["redeemed_at"] = redeemed_at;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that describes the reward that the user redeemed.
class CustomRewardRedemptionReward extends RefCounted:
	## The ID that uniquely identifies the reward.
	var id: String;
	## The reward’s title.
	var title: String;
	## The prompt displayed to the viewer if user input is required.
	var prompt: String;
	## The reward’s cost, in Channel Points.
	var cost: int;

	static func from_json(d: Dictionary) -> CustomRewardRedemptionReward:
		var result = CustomRewardRedemptionReward.new();
		result.id = d["id"];
		result.title = d["title"];
		result.prompt = d["prompt"];
		result.cost = d["cost"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["id"] = id;
		d["title"] = title;
		d["prompt"] = prompt;
		d["cost"] = cost;
		return d;

