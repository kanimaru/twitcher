@tool
extends RefCounted

class_name TwitchCheckUserSubscriptionResponse

## A list that contains a single object with information about the user’s subscription.
var data: Array[TwitchUserSubscription];

static func from_json(d: Dictionary) -> TwitchCheckUserSubscriptionResponse:
	var result = TwitchCheckUserSubscriptionResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

