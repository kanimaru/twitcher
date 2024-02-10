@tool
extends RefCounted

class_name TwitchUpdateDropsEntitlementsResponse

## A list that indicates which entitlements were successfully updated and those that weren’t.
var data: Array[TwitchDropsEntitlementUpdated];

static func from_json(d: Dictionary) -> TwitchUpdateDropsEntitlementsResponse:
	var result = TwitchUpdateDropsEntitlementsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

