@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/ChannelStreamScheduleSegment
class_name TwitchChannelStreamScheduleSegment
	
## An ID that identifies this broadcast segment.
@export var id: String:
	set(val): 
		id = val
		track_data(&"id", val)

## The UTC date and time (in RFC3339 format) of when the broadcast starts.
@export var start_time: String:
	set(val): 
		start_time = val
		track_data(&"start_time", val)

## The UTC date and time (in RFC3339 format) of when the broadcast ends.
@export var end_time: String:
	set(val): 
		end_time = val
		track_data(&"end_time", val)

## The broadcast segment’s title.
@export var title: String:
	set(val): 
		title = val
		track_data(&"title", val)

## Indicates whether the broadcaster canceled this segment of a recurring broadcast. If the broadcaster canceled this segment, this field is set to the same value that’s in the `end_time` field; otherwise, it’s set to **null**.
@export var canceled_until: String:
	set(val): 
		canceled_until = val
		track_data(&"canceled_until", val)

## The type of content that the broadcaster plans to stream or **null** if not specified.
@export var category: Category:
	set(val): 
		category = val
		track_data(&"category", val)

## A Boolean value that determines whether the broadcast is part of a recurring series that streams at the same time each week or is a one-time broadcast. Is **true** if the broadcast is part of a recurring series.
@export var is_recurring: bool:
	set(val): 
		is_recurring = val
		track_data(&"is_recurring", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_id: String, _start_time: String, _end_time: String, _title: String, _canceled_until: String, _category: Category, _is_recurring: bool) -> TwitchChannelStreamScheduleSegment:
	var twitch_channel_stream_schedule_segment: TwitchChannelStreamScheduleSegment = TwitchChannelStreamScheduleSegment.new()
	twitch_channel_stream_schedule_segment.id = _id
	twitch_channel_stream_schedule_segment.start_time = _start_time
	twitch_channel_stream_schedule_segment.end_time = _end_time
	twitch_channel_stream_schedule_segment.title = _title
	twitch_channel_stream_schedule_segment.canceled_until = _canceled_until
	twitch_channel_stream_schedule_segment.category = _category
	twitch_channel_stream_schedule_segment.is_recurring = _is_recurring
	return twitch_channel_stream_schedule_segment


static func from_json(d: Dictionary) -> TwitchChannelStreamScheduleSegment:
	var result: TwitchChannelStreamScheduleSegment = TwitchChannelStreamScheduleSegment.new()
	if d.get("id", null) != null:
		result.id = d["id"]
	if d.get("start_time", null) != null:
		result.start_time = d["start_time"]
	if d.get("end_time", null) != null:
		result.end_time = d["end_time"]
	if d.get("title", null) != null:
		result.title = d["title"]
	if d.get("canceled_until", null) != null:
		result.canceled_until = d["canceled_until"]
	if d.get("category", null) != null:
		result.category = Category.from_json(d["category"])
	if d.get("is_recurring", null) != null:
		result.is_recurring = d["is_recurring"]
	return result



## The type of content that the broadcaster plans to stream or **null** if not specified.
## #/components/schemas/ChannelStreamScheduleSegment/Category
class Category extends TwitchData:

	## An ID that identifies the category that best represents the content that the broadcaster plans to stream. For example, the game’s ID if the broadcaster will play a game or the Just Chatting ID if the broadcaster will host a talk show.
	@export var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The name of the category. For example, the game’s title if the broadcaster will play a game or Just Chatting if the broadcaster will host a talk show.
	@export var name: String:
		set(val): 
			name = val
			track_data(&"name", val)
	
	
	
	## Constructor with all required fields.
	static func create(_id: String, _name: String) -> Category:
		var category: Category = Category.new()
		category.id = _id
		category.name = _name
		return category
	
	
	static func from_json(d: Dictionary) -> Category:
		var result: Category = Category.new()
		if d.get("id", null) != null:
			result.id = d["id"]
		if d.get("name", null) != null:
			result.name = d["name"]
		return result
	