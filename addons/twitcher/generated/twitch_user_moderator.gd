@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/UserModerator
class_name TwitchUserModerator
	
## The ID of the user that has permission to moderate the broadcaster’s channel.
var user_id: String:
	set(val): 
		user_id = val
		track_data(&"user_id", val)

## The user’s login name.
var user_login: String:
	set(val): 
		user_login = val
		track_data(&"user_login", val)

## The user’s display name.
var user_name: String:
	set(val): 
		user_name = val
		track_data(&"user_name", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_user_id: String, _user_login: String, _user_name: String) -> TwitchUserModerator:
	var twitch_user_moderator: TwitchUserModerator = TwitchUserModerator.new()
	twitch_user_moderator.user_id = _user_id
	twitch_user_moderator.user_login = _user_login
	twitch_user_moderator.user_name = _user_name
	return twitch_user_moderator


static func from_json(d: Dictionary) -> TwitchUserModerator:
	var result: TwitchUserModerator = TwitchUserModerator.new()
	if d.get("user_id", null) != null:
		result.user_id = d["user_id"]
	if d.get("user_login", null) != null:
		result.user_login = d["user_login"]
	if d.get("user_name", null) != null:
		result.user_name = d["user_name"]
	return result
