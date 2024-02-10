@tool
extends RefCounted

class_name TwitchDropsEntitlementUpdated

## A string that indicates whether the status of the entitlements in the `ids` field were successfully updated. Possible values are:      * INVALID\_ID — The entitlement IDs in the `ids` field are not valid. * NOT\_FOUND — The entitlement IDs in the `ids` field were not found. * SUCCESS — The status of the entitlements in the `ids` field were successfully updated. * UNAUTHORIZED — The user or organization identified by the user access token is not authorized to update the entitlements. * UPDATE\_FAILED — The update failed. These are considered transient errors and the request should be retried later.
var status: String;
## The list of entitlements that the status in the `status` field applies to.
var ids: Array[String];

static func from_json(d: Dictionary) -> TwitchDropsEntitlementUpdated:
	var result = TwitchDropsEntitlementUpdated.new();


	for value in d["ids"]:
		result.ids.append(value);
{elif property.is_typed_array}
	for value in d["ids"]:
		result.ids.append(.from_json(value));
{elif property.is_sub_class}
	result.ids = Array[String].from_json(d["ids"]);
{else}
	result.ids = d["ids"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

