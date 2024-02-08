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
	result.broadcaster_id = d["broadcaster_id"];
	result.broadcaster_login = d["broadcaster_login"];
	result.broadcaster_name = d["broadcaster_name"];
	result.gifter_id = d["gifter_id"];
	result.gifter_login = d["gifter_login"];
	result.gifter_name = d["gifter_name"];
	result.is_gift = d["is_gift"];
	result.plan_name = d["plan_name"];
	result.tier = d["tier"];
	result.user_id = d["user_id"];
	result.user_name = d["user_name"];
	result.user_login = d["user_login"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["broadcaster_id"] = broadcaster_id;
	d["broadcaster_login"] = broadcaster_login;
	d["broadcaster_name"] = broadcaster_name;
	d["gifter_id"] = gifter_id;
	d["gifter_login"] = gifter_login;
	d["gifter_name"] = gifter_name;
	d["is_gift"] = is_gift;
	d["plan_name"] = plan_name;
	d["tier"] = tier;
	d["user_id"] = user_id;
	d["user_name"] = user_name;
	d["user_login"] = user_login;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

