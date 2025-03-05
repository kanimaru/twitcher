@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/User
class_name TwitchUser
	
## An ID that identifies the user.
var id: String:
	set(val): 
		id = val
		track_data(&"id", val)

## The user's login name.
var login: String:
	set(val): 
		login = val
		track_data(&"login", val)

## The user's display name.
var display_name: String:
	set(val): 
		display_name = val
		track_data(&"display_name", val)

## The type of user. Possible values are:  
##   
## * admin — Twitch administrator
## * global\_mod
## * staff — Twitch staff
## * "" — Normal user
var type: String:
	set(val): 
		type = val
		track_data(&"type", val)

## The type of broadcaster. Possible values are:  
##   
## * affiliate — An [affiliate broadcaster](https://help.twitch.tv/s/article/joining-the-affiliate-program)
## * partner — A [partner broadcaster](https://help.twitch.tv/s/article/partner-program-overview)
## * "" — A normal broadcaster
var broadcaster_type: String:
	set(val): 
		broadcaster_type = val
		track_data(&"broadcaster_type", val)

## The user's description of their channel.
var description: String:
	set(val): 
		description = val
		track_data(&"description", val)

## A URL to the user's profile image.
var profile_image_url: String:
	set(val): 
		profile_image_url = val
		track_data(&"profile_image_url", val)

## A URL to the user's offline image.
var offline_image_url: String:
	set(val): 
		offline_image_url = val
		track_data(&"offline_image_url", val)

## The number of times the user's channel has been viewed.  
##   
## **NOTE**: This field has been deprecated (see [Get Users API endpoint – "view\_count" deprecation](https://discuss.dev.twitch.tv/t/get-users-api-endpoint-view-count-deprecation/37777)). Any data in this field is not valid and should not be used.
var view_count: int:
	set(val): 
		view_count = val
		track_data(&"view_count", val)

## The user's verified email address. The object includes this field only if the user access token includes the **user:read:email** scope.  
##   
## If the request contains more than one user, only the user associated with the access token that provided consent will include an email address — the email address for all other users will be empty.
var email: String:
	set(val): 
		email = val
		track_data(&"email", val)

## The UTC date and time that the user's account was created. The timestamp is in RFC3339 format.
var created_at: Variant:
	set(val): 
		created_at = val
		track_data(&"created_at", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_id: String, _login: String, _display_name: String, _type: String, _broadcaster_type: String, _description: String, _profile_image_url: String, _offline_image_url: String, _view_count: int, _created_at: Variant) -> TwitchUser:
	var twitch_user: TwitchUser = TwitchUser.new()
	twitch_user.id = _id
	twitch_user.login = _login
	twitch_user.display_name = _display_name
	twitch_user.type = _type
	twitch_user.broadcaster_type = _broadcaster_type
	twitch_user.description = _description
	twitch_user.profile_image_url = _profile_image_url
	twitch_user.offline_image_url = _offline_image_url
	twitch_user.view_count = _view_count
	twitch_user.created_at = _created_at
	return twitch_user


static func from_json(d: Dictionary) -> TwitchUser:
	var result: TwitchUser = TwitchUser.new()
	if d.get("id", null) != null:
		result.id = d["id"]
	if d.get("login", null) != null:
		result.login = d["login"]
	if d.get("display_name", null) != null:
		result.display_name = d["display_name"]
	if d.get("type", null) != null:
		result.type = d["type"]
	if d.get("broadcaster_type", null) != null:
		result.broadcaster_type = d["broadcaster_type"]
	if d.get("description", null) != null:
		result.description = d["description"]
	if d.get("profile_image_url", null) != null:
		result.profile_image_url = d["profile_image_url"]
	if d.get("offline_image_url", null) != null:
		result.offline_image_url = d["offline_image_url"]
	if d.get("view_count", null) != null:
		result.view_count = d["view_count"]
	if d.get("email", null) != null:
		result.email = d["email"]
	if d.get("created_at", null) != null:
		result.created_at = d["created_at"]
	return result
