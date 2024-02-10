@tool
extends RefCounted

class_name TwitchUserSubscription

## An ID that identifies the broadcaster.
var broadcaster_id: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The ID of the user that gifted the subscription. The object includes this field only if `is_gift` is **true**.
var gifter_id: String;
## The gifter’s login name. The object includes this field only if `is_gift` is **true**.
var gifter_login: String;
## The gifter’s display name. The object includes this field only if `is_gift` is **true**.
var gifter_name: String;
## A Boolean value that determines whether the subscription is a gift subscription. Is **true** if the subscription was gifted.
var is_gift: bool;
## The type of subscription. Possible values are:      * 1000 — Tier 1 * 2000 — Tier 2 * 3000 — Tier 3
var tier: String;

static func from_json(d: Dictionary) -> TwitchUserSubscription:
	var result = TwitchUserSubscription.new();








	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};








	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

