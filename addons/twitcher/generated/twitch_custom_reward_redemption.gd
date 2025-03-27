@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/CustomRewardRedemption
class_name TwitchCustomRewardRedemption
	
## The ID that uniquely identifies the broadcaster.
@export var broadcaster_id: String:
	set(val): 
		broadcaster_id = val
		track_data(&"broadcaster_id", val)

## The broadcaster’s login name.
@export var broadcaster_login: String:
	set(val): 
		broadcaster_login = val
		track_data(&"broadcaster_login", val)

## The broadcaster’s display name.
@export var broadcaster_name: String:
	set(val): 
		broadcaster_name = val
		track_data(&"broadcaster_name", val)

## The ID that uniquely identifies this redemption..
@export var id: String:
	set(val): 
		id = val
		track_data(&"id", val)

## The ID of the user that redeemed the reward.
@export var user_id: String:
	set(val): 
		user_id = val
		track_data(&"user_id", val)

## The user’s display name.
@export var user_name: String:
	set(val): 
		user_name = val
		track_data(&"user_name", val)

## The user’s login name.
@export var user_login: String:
	set(val): 
		user_login = val
		track_data(&"user_login", val)

## An object that describes the reward that the user redeemed.
@export var reward: Reward:
	set(val): 
		reward = val
		track_data(&"reward", val)

## The text that the user entered at the prompt when they redeemed the reward; otherwise, an empty string if user input was not required.
@export var user_input: String:
	set(val): 
		user_input = val
		track_data(&"user_input", val)

## The state of the redemption. Possible values are:  
##   
## * CANCELED
## * FULFILLED
## * UNFULFILLED
@export var status: String:
	set(val): 
		status = val
		track_data(&"status", val)

## The date and time of when the reward was redeemed, in RFC3339 format.
@export var redeemed_at: String:
	set(val): 
		redeemed_at = val
		track_data(&"redeemed_at", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_broadcaster_id: String, _broadcaster_login: String, _broadcaster_name: String, _id: String, _user_id: String, _user_name: String, _user_login: String, _reward: Reward, _user_input: String, _status: String, _redeemed_at: String) -> TwitchCustomRewardRedemption:
	var twitch_custom_reward_redemption: TwitchCustomRewardRedemption = TwitchCustomRewardRedemption.new()
	twitch_custom_reward_redemption.broadcaster_id = _broadcaster_id
	twitch_custom_reward_redemption.broadcaster_login = _broadcaster_login
	twitch_custom_reward_redemption.broadcaster_name = _broadcaster_name
	twitch_custom_reward_redemption.id = _id
	twitch_custom_reward_redemption.user_id = _user_id
	twitch_custom_reward_redemption.user_name = _user_name
	twitch_custom_reward_redemption.user_login = _user_login
	twitch_custom_reward_redemption.reward = _reward
	twitch_custom_reward_redemption.user_input = _user_input
	twitch_custom_reward_redemption.status = _status
	twitch_custom_reward_redemption.redeemed_at = _redeemed_at
	return twitch_custom_reward_redemption


static func from_json(d: Dictionary) -> TwitchCustomRewardRedemption:
	var result: TwitchCustomRewardRedemption = TwitchCustomRewardRedemption.new()
	if d.get("broadcaster_id", null) != null:
		result.broadcaster_id = d["broadcaster_id"]
	if d.get("broadcaster_login", null) != null:
		result.broadcaster_login = d["broadcaster_login"]
	if d.get("broadcaster_name", null) != null:
		result.broadcaster_name = d["broadcaster_name"]
	if d.get("id", null) != null:
		result.id = d["id"]
	if d.get("user_id", null) != null:
		result.user_id = d["user_id"]
	if d.get("user_name", null) != null:
		result.user_name = d["user_name"]
	if d.get("user_login", null) != null:
		result.user_login = d["user_login"]
	if d.get("reward", null) != null:
		result.reward = Reward.from_json(d["reward"])
	if d.get("user_input", null) != null:
		result.user_input = d["user_input"]
	if d.get("status", null) != null:
		result.status = d["status"]
	if d.get("redeemed_at", null) != null:
		result.redeemed_at = d["redeemed_at"]
	return result



## An object that describes the reward that the user redeemed.
## #/components/schemas/CustomRewardRedemption/Reward
class Reward extends TwitchData:

	## The ID that uniquely identifies the reward.
	@export var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The reward’s title.
	@export var title: String:
		set(val): 
			title = val
			track_data(&"title", val)
	
	## The prompt displayed to the viewer if user input is required.
	@export var prompt: String:
		set(val): 
			prompt = val
			track_data(&"prompt", val)
	
	## The reward’s cost, in Channel Points.
	@export var cost: int:
		set(val): 
			cost = val
			track_data(&"cost", val)
	
	
	
	## Constructor with all required fields.
	static func create(_id: String, _title: String, _prompt: String, _cost: int) -> Reward:
		var reward: Reward = Reward.new()
		reward.id = _id
		reward.title = _title
		reward.prompt = _prompt
		reward.cost = _cost
		return reward
	
	
	static func from_json(d: Dictionary) -> Reward:
		var result: Reward = Reward.new()
		if d.get("id", null) != null:
			result.id = d["id"]
		if d.get("title", null) != null:
			result.title = d["title"]
		if d.get("prompt", null) != null:
			result.prompt = d["prompt"]
		if d.get("cost", null) != null:
			result.cost = d["cost"]
		return result
	