@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/ExtensionLiveChannel
class_name TwitchExtensionLiveChannel
	
## The ID of the broadcaster that is streaming live and has installed or activated the extension.
@export var broadcaster_id: String:
	set(val): 
		broadcaster_id = val
		track_data(&"broadcaster_id", val)

## The broadcaster’s display name.
@export var broadcaster_name: String:
	set(val): 
		broadcaster_name = val
		track_data(&"broadcaster_name", val)

## The name of the category or game being streamed.
@export var game_name: String:
	set(val): 
		game_name = val
		track_data(&"game_name", val)

## The ID of the category or game being streamed.
@export var game_id: String:
	set(val): 
		game_id = val
		track_data(&"game_id", val)

## The title of the broadcaster’s stream. May be an empty string if not specified.
@export var title: String:
	set(val): 
		title = val
		track_data(&"title", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_broadcaster_id: String, _broadcaster_name: String, _game_name: String, _game_id: String, _title: String) -> TwitchExtensionLiveChannel:
	var twitch_extension_live_channel: TwitchExtensionLiveChannel = TwitchExtensionLiveChannel.new()
	twitch_extension_live_channel.broadcaster_id = _broadcaster_id
	twitch_extension_live_channel.broadcaster_name = _broadcaster_name
	twitch_extension_live_channel.game_name = _game_name
	twitch_extension_live_channel.game_id = _game_id
	twitch_extension_live_channel.title = _title
	return twitch_extension_live_channel


static func from_json(d: Dictionary) -> TwitchExtensionLiveChannel:
	var result: TwitchExtensionLiveChannel = TwitchExtensionLiveChannel.new()
	if d.get("broadcaster_id", null) != null:
		result.broadcaster_id = d["broadcaster_id"]
	if d.get("broadcaster_name", null) != null:
		result.broadcaster_name = d["broadcaster_name"]
	if d.get("game_name", null) != null:
		result.game_name = d["game_name"]
	if d.get("game_id", null) != null:
		result.game_id = d["game_id"]
	if d.get("title", null) != null:
		result.title = d["title"]
	return result
