@tool
extends RefCounted

class_name TwitchUpdateRedemptionStatusBody

## The status to set the redemption to. Possible values are:      * CANCELED * FULFILLED    Setting the status to CANCELED refunds the user’s channel points.
var status: String;

static func from_json(d: Dictionary) -> TwitchUpdateRedemptionStatusBody:
	var result = TwitchUpdateRedemptionStatusBody.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

