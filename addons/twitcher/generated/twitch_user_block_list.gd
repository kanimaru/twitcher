@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/UserBlockList
class_name TwitchUserBlockList
	
## An ID that identifies the blocked user.
@export var user_id: String:
	set(val): 
		user_id = val
		track_data(&"user_id", val)

## The blocked user’s login name.
@export var user_login: String:
	set(val): 
		user_login = val
		track_data(&"user_login", val)

## The blocked user’s display name.
@export var display_name: String:
	set(val): 
		display_name = val
		track_data(&"display_name", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_user_id: String, _user_login: String, _display_name: String) -> TwitchUserBlockList:
	var twitch_user_block_list: TwitchUserBlockList = TwitchUserBlockList.new()
	twitch_user_block_list.user_id = _user_id
	twitch_user_block_list.user_login = _user_login
	twitch_user_block_list.display_name = _display_name
	return twitch_user_block_list


static func from_json(d: Dictionary) -> TwitchUserBlockList:
	var result: TwitchUserBlockList = TwitchUserBlockList.new()
	if d.get("user_id", null) != null:
		result.user_id = d["user_id"]
	if d.get("user_login", null) != null:
		result.user_login = d["user_login"]
	if d.get("display_name", null) != null:
		result.display_name = d["display_name"]
	return result
