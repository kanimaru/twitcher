@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/BroadcasterSubscription
class_name TwitchBroadcasterSubscription
	
## An ID that identifies the broadcaster.
var broadcaster_id: String:
	set(val): 
		broadcaster_id = val
		track_data(&"broadcaster_id", val)

## The broadcaster’s login name.
var broadcaster_login: String:
	set(val): 
		broadcaster_login = val
		track_data(&"broadcaster_login", val)

## The broadcaster’s display name.
var broadcaster_name: String:
	set(val): 
		broadcaster_name = val
		track_data(&"broadcaster_name", val)

## The ID of the user that gifted the subscription to the user. Is an empty string if `is_gift` is **false**.
var gifter_id: String:
	set(val): 
		gifter_id = val
		track_data(&"gifter_id", val)

## The gifter’s login name. Is an empty string if `is_gift` is **false**.
var gifter_login: String:
	set(val): 
		gifter_login = val
		track_data(&"gifter_login", val)

## The gifter’s display name. Is an empty string if `is_gift` is **false**.
var gifter_name: String:
	set(val): 
		gifter_name = val
		track_data(&"gifter_name", val)

## A Boolean value that determines whether the subscription is a gift subscription. Is **true** if the subscription was gifted.
var is_gift: bool:
	set(val): 
		is_gift = val
		track_data(&"is_gift", val)

## The name of the subscription.
var plan_name: String:
	set(val): 
		plan_name = val
		track_data(&"plan_name", val)

## The type of subscription. Possible values are:  
##   
## * 1000 — Tier 1
## * 2000 — Tier 2
## * 3000 — Tier 3
var tier: String:
	set(val): 
		tier = val
		track_data(&"tier", val)

## An ID that identifies the subscribing user.
var user_id: String:
	set(val): 
		user_id = val
		track_data(&"user_id", val)

## The user’s display name.
var user_name: String:
	set(val): 
		user_name = val
		track_data(&"user_name", val)

## The user’s login name.
var user_login: String:
	set(val): 
		user_login = val
		track_data(&"user_login", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_broadcaster_id: String, _broadcaster_login: String, _broadcaster_name: String, _gifter_id: String, _gifter_login: String, _gifter_name: String, _is_gift: bool, _plan_name: String, _tier: String, _user_id: String, _user_name: String, _user_login: String) -> TwitchBroadcasterSubscription:
	var twitch_broadcaster_subscription: TwitchBroadcasterSubscription = TwitchBroadcasterSubscription.new()
	twitch_broadcaster_subscription.broadcaster_id = _broadcaster_id
	twitch_broadcaster_subscription.broadcaster_login = _broadcaster_login
	twitch_broadcaster_subscription.broadcaster_name = _broadcaster_name
	twitch_broadcaster_subscription.gifter_id = _gifter_id
	twitch_broadcaster_subscription.gifter_login = _gifter_login
	twitch_broadcaster_subscription.gifter_name = _gifter_name
	twitch_broadcaster_subscription.is_gift = _is_gift
	twitch_broadcaster_subscription.plan_name = _plan_name
	twitch_broadcaster_subscription.tier = _tier
	twitch_broadcaster_subscription.user_id = _user_id
	twitch_broadcaster_subscription.user_name = _user_name
	twitch_broadcaster_subscription.user_login = _user_login
	return twitch_broadcaster_subscription


static func from_json(d: Dictionary) -> TwitchBroadcasterSubscription:
	var result: TwitchBroadcasterSubscription = TwitchBroadcasterSubscription.new()
	if d.get("broadcaster_id", null) != null:
		result.broadcaster_id = d["broadcaster_id"]
	if d.get("broadcaster_login", null) != null:
		result.broadcaster_login = d["broadcaster_login"]
	if d.get("broadcaster_name", null) != null:
		result.broadcaster_name = d["broadcaster_name"]
	if d.get("gifter_id", null) != null:
		result.gifter_id = d["gifter_id"]
	if d.get("gifter_login", null) != null:
		result.gifter_login = d["gifter_login"]
	if d.get("gifter_name", null) != null:
		result.gifter_name = d["gifter_name"]
	if d.get("is_gift", null) != null:
		result.is_gift = d["is_gift"]
	if d.get("plan_name", null) != null:
		result.plan_name = d["plan_name"]
	if d.get("tier", null) != null:
		result.tier = d["tier"]
	if d.get("user_id", null) != null:
		result.user_id = d["user_id"]
	if d.get("user_name", null) != null:
		result.user_name = d["user_name"]
	if d.get("user_login", null) != null:
		result.user_login = d["user_login"]
	return result
