@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/ExtensionAnalytics
class_name TwitchExtensionAnalytics
	
## An ID that identifies the extension that the report was generated for.
@export var extension_id: String:
	set(val): 
		extension_id = val
		track_data(&"extension_id", val)

## The URL that you use to download the report. The URL is valid for 5 minutes.
@export var URL: String:
	set(val): 
		URL = val
		track_data(&"URL", val)

## The type of report.
@export var type: String:
	set(val): 
		type = val
		track_data(&"type", val)

## The reporting window’s start and end dates, in RFC3339 format.
@export var date_range: DateRange:
	set(val): 
		date_range = val
		track_data(&"date_range", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_extension_id: String, _URL: String, _type: String, _date_range: DateRange) -> TwitchExtensionAnalytics:
	var twitch_extension_analytics: TwitchExtensionAnalytics = TwitchExtensionAnalytics.new()
	twitch_extension_analytics.extension_id = _extension_id
	twitch_extension_analytics.URL = _URL
	twitch_extension_analytics.type = _type
	twitch_extension_analytics.date_range = _date_range
	return twitch_extension_analytics


static func from_json(d: Dictionary) -> TwitchExtensionAnalytics:
	var result: TwitchExtensionAnalytics = TwitchExtensionAnalytics.new()
	if d.get("extension_id", null) != null:
		result.extension_id = d["extension_id"]
	if d.get("URL", null) != null:
		result.URL = d["URL"]
	if d.get("type", null) != null:
		result.type = d["type"]
	if d.get("date_range", null) != null:
		result.date_range = DateRange.from_json(d["date_range"])
	return result



## The reporting window’s start and end dates, in RFC3339 format.
## #/components/schemas/ExtensionAnalytics/DateRange
class DateRange extends TwitchData:

	## The reporting window’s start date.
	@export var started_at: String:
		set(val): 
			started_at = val
			track_data(&"started_at", val)
	
	## The reporting window’s end date.
	@export var ended_at: String:
		set(val): 
			ended_at = val
			track_data(&"ended_at", val)
	
	
	
	## Constructor with all required fields.
	static func create(_started_at: String, _ended_at: String) -> DateRange:
		var date_range: DateRange = DateRange.new()
		date_range.started_at = _started_at
		date_range.ended_at = _ended_at
		return date_range
	
	
	static func from_json(d: Dictionary) -> DateRange:
		var result: DateRange = DateRange.new()
		if d.get("started_at", null) != null:
			result.started_at = d["started_at"]
		if d.get("ended_at", null) != null:
			result.ended_at = d["ended_at"]
		return result
	