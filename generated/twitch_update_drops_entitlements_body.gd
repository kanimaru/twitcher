@tool
extends RefCounted

class_name TwitchUpdateDropsEntitlementsBody

## A list of IDs that identify the entitlements to update. You may specify a maximum of 100 IDs.
var entitlement_ids: Array[String];
## The fulfillment status to set the entitlements to. Possible values are:      * CLAIMED — The user claimed the benefit. * FULFILLED — The developer granted the benefit that the user claimed.
var fulfillment_status: String;

static func from_json(d: Dictionary) -> TwitchUpdateDropsEntitlementsBody:
	var result = TwitchUpdateDropsEntitlementsBody.new();

	for value in d["entitlement_ids"]:
		result.entitlement_ids.append(value);
{elif property.is_typed_array}
	for value in d["entitlement_ids"]:
		result.entitlement_ids.append(.from_json(value));
{elif property.is_sub_class}
	result.entitlement_ids = Array[String].from_json(d["entitlement_ids"]);
{else}
	result.entitlement_ids = d["entitlement_ids"];


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

