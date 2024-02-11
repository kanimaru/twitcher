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
var reward: Reward;
## The text that the user entered at the prompt when they redeemed the reward; otherwise, an empty string if user input was not required.
var user_input: String;
## The state of the redemption. Possible values are:      * CANCELED * FULFILLED * UNFULFILLED
var status: String;
## The date and time of when the reward was redeemed, in RFC3339 format.
var redeemed_at: Variant;

static func from_json(d: Dictionary) -> TwitchCustomRewardRedemption:
	var result = TwitchCustomRewardRedemption.new();
	if d.has("broadcaster_id") && d["broadcaster_id"] != null:
		result.broadcaster_id = d["broadcaster_id"];
	if d.has("broadcaster_login") && d["broadcaster_login"] != null:
		result.broadcaster_login = d["broadcaster_login"];
	if d.has("broadcaster_name") && d["broadcaster_name"] != null:
		result.broadcaster_name = d["broadcaster_name"];
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("user_id") && d["user_id"] != null:
		result.user_id = d["user_id"];
	if d.has("user_name") && d["user_name"] != null:
		result.user_name = d["user_name"];
	if d.has("user_login") && d["user_login"] != null:
		result.user_login = d["user_login"];
	if d.has("reward") && d["reward"] != null:
		result.reward = Reward.from_json(d["reward"]);
	if d.has("user_input") && d["user_input"] != null:
		result.user_input = d["user_input"];
	if d.has("status") && d["status"] != null:
		result.status = d["status"];
	if d.has("redeemed_at") && d["redeemed_at"] != null:
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
	if reward != null:
		d["reward"] = reward.to_dict();
	d["user_input"] = user_input;
	d["status"] = status;
	d["redeemed_at"] = redeemed_at;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that describes the reward that the user redeemed.
class Reward extends RefCounted:
	## The ID that uniquely identifies the reward.
	var id: String;
	## The reward’s title.
	var title: String;
	## The prompt displayed to the viewer if user input is required.
	var prompt: String;
	## The reward’s cost, in Channel Points.
	var cost: int;

	static func from_json(d: Dictionary) -> Reward:
		var result = Reward.new();
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
