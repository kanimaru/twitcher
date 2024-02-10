@tool
extends RefCounted

class_name TwitchBroadcasterSubscription

## An ID that identifies the broadcaster.
var broadcaster_id: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The ID of the user that gifted the subscription to the user. Is an empty string if `is_gift` is **false**.
var gifter_id: String;
## The gifter’s login name. Is an empty string if `is_gift` is **false**.
var gifter_login: String;
## The gifter’s display name. Is an empty string if `is_gift` is **false**.
var gifter_name: String;
## A Boolean value that determines whether the subscription is a gift subscription. Is **true** if the subscription was gifted.
var is_gift: bool;
## The name of the subscription.
var plan_name: String;
## The type of subscription. Possible values are:      * 1000 — Tier 1 * 2000 — Tier 2 * 3000 — Tier 3
var tier: String;
## An ID that identifies the subscribing user.
var user_id: String;
## The user’s display name.
var user_name: String;
## The user’s login name.
var user_login: String;

static func from_json(d: Dictionary) -> TwitchBroadcasterSubscription:
	var result = TwitchBroadcasterSubscription.new();












	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};












	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

