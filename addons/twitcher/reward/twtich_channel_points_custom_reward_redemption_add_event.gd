class_name TwitchChannelPointsCustomRewardRedemptionAddEvent
extends RefCounted


const STATUS: PackedStringArray = [ "unknown", "unfulfilled", "fulfilled", "canceled"]

## The redemption identifier.
var id: String

## The requested broadcaster ID.
var broadcaster_user_id: String

## The requested broadcaster login.
var broadcaster_user_login: String

## The requested broadcaster display name.
var broadcaster_user_name: String

## User ID of the user that redeemed the reward.
var user_id: String

## Login of the user that redeemed the reward.
var user_login: String

## Display name of the user that redeemed the reward.
var user_name: String

## The user input provided. Empty string if not provided.
var user_input: String

## Defaults to "unfulfilled". Possible values are "unknown", "unfulfilled", "fulfilled", and "canceled".
var status: TwitchRedemption.Status

## Basic information about the reward that was redeemed.
var reward: Reward

## RFC3339 timestamp of when the reward was redeemed.
var redeemed_at: String


class Reward extends RefCounted:
	## The reward identifier.
	var id: String
	## The reward name.
	var title: String
	## The reward cost.
	var cost: int
	## The reward description.
	var prompt: String
	
	static func from_json(d: Dictionary) -> Reward:
		var reward: Reward = Reward.new()
		
		reward.id = d.get("id", "")
		reward.title = d.get("title", "")
		reward.cost = d.get("cost", 0)
		reward.prompt = d.get("prompt", "")
		
		return reward


## Creates a new Redemption object from a dictionary.
static func from_json(d: Dictionary) -> TwitchChannelPointsCustomRewardRedemptionAddEvent:
	var redemption: TwitchChannelPointsCustomRewardRedemptionAddEvent = TwitchChannelPointsCustomRewardRedemptionAddEvent.new()
	
	redemption.id = d.get("id", "")
	redemption.broadcaster_user_id = d.get("broadcaster_user_id", "")
	redemption.broadcaster_user_login = d.get("broadcaster_user_login", "")
	redemption.broadcaster_user_name = d.get("broadcaster_user_name", "")
	redemption.user_id = d.get("user_id", "")
	redemption.user_login = d.get("user_login", "")
	redemption.user_name = d.get("user_name", "")
	redemption.user_input = d.get("user_input", "")
	redemption.status = TwitchRedemption.Status[d.get("status", "unfulfilled").to_upper()]
	redemption.redeemed_at = d.get("redeemed_at", "")
	redemption.reward = Reward.from_json(d.get("reward", {}))
	
	return redemption
