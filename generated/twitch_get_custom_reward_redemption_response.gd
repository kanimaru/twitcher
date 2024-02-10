@tool
extends RefCounted

class_name TwitchGetCustomRewardRedemptionResponse

## The list of redemptions for the specified reward. The list is empty if there are no redemptions that match the redemption criteria.
var data: Array[TwitchCustomRewardRedemption];

static func from_json(d: Dictionary) -> TwitchGetCustomRewardRedemptionResponse:
	var result = TwitchGetCustomRewardRedemptionResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

