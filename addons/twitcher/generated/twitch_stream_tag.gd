@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/StreamTag
class_name TwitchStreamTag
	
## An ID that identifies this tag.
@export var tag_id: String:
	set(val): 
		tag_id = val
		track_data(&"tag_id", val)

## A Boolean value that determines whether the tag is an automatic tag. An automatic tag is one that Twitch adds to the stream. Broadcasters may not add automatic tags to their channel. The value is **true** if the tag is an automatic tag; otherwise, **false**.
@export var is_auto: bool:
	set(val): 
		is_auto = val
		track_data(&"is_auto", val)

## A dictionary that contains the localized names of the tag. The key is in the form, <locale>-<coutry/region>. For example, en-us. The value is the localized name.
@export var localization_names: Dictionary:
	set(val): 
		localization_names = val
		track_data(&"localization_names", val)

## A dictionary that contains the localized descriptions of the tag. The key is in the form, <locale>-<coutry/region>. For example, en-us. The value is the localized description.
@export var localization_descriptions: Dictionary:
	set(val): 
		localization_descriptions = val
		track_data(&"localization_descriptions", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_tag_id: String, _is_auto: bool, _localization_names: Dictionary, _localization_descriptions: Dictionary) -> TwitchStreamTag:
	var twitch_stream_tag: TwitchStreamTag = TwitchStreamTag.new()
	twitch_stream_tag.tag_id = _tag_id
	twitch_stream_tag.is_auto = _is_auto
	twitch_stream_tag.localization_names = _localization_names
	twitch_stream_tag.localization_descriptions = _localization_descriptions
	return twitch_stream_tag


static func from_json(d: Dictionary) -> TwitchStreamTag:
	var result: TwitchStreamTag = TwitchStreamTag.new()
	if d.get("tag_id", null) != null:
		result.tag_id = d["tag_id"]
	if d.get("is_auto", null) != null:
		result.is_auto = d["is_auto"]
	if d.get("localization_names", null) != null:
		result.localization_names = d["localization_names"]
	if d.get("localization_descriptions", null) != null:
		result.localization_descriptions = d["localization_descriptions"]
	return result
