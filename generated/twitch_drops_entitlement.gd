@tool
extends RefCounted

class_name TwitchDropsEntitlement

## An ID that identifies the entitlement.
var id: String;
## An ID that identifies the benefit (reward).
var benefit_id: String;
## The UTC date and time (in RFC3339 format) of when the entitlement was granted.
var timestamp: Variant;
## An ID that identifies the user who was granted the entitlement.
var user_id: String;
## An ID that identifies the game the user was playing when the reward was entitled.
var game_id: String;
## The entitlement’s fulfillment status. Possible values are:       * CLAIMED * FULFILLED
var fulfillment_status: String;
## The UTC date and time (in RFC3339 format) of when the entitlement was last updated.
var last_updated: Variant;

static func from_json(d: Dictionary) -> TwitchDropsEntitlement:
	var result = TwitchDropsEntitlement.new();







	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};







	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

