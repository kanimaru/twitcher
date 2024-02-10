@tool
extends RefCounted

class_name TwitchHypeTrainEvent

## An ID that identifies this event.
var id: String;
## The type of event. The string is in the form, hypetrain.{event\_name}. The request returns only progress event types (i.e., hypetrain.progression).
var event_type: String;
## The UTC date and time (in RFC3339 format) that the event occurred.
var event_timestamp: Variant;
## The version number of the definition of the event’s data. For example, the value is 1 if the data in `event_data` uses the first definition of the event’s data.
var version: String;
## The event’s data.
var event_data: HypeTrainEventEventData;

static func from_json(d: Dictionary) -> TwitchHypeTrainEvent:
	var result = TwitchHypeTrainEvent.new();





	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};





	d["event_data"] = event_data.to_dict();
{else}
	d["event_data"] = event_data;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The event’s data.
class HypeTrainEventEventData extends RefCounted:
	## The ID of the broadcaster that’s running the Hype Train.
	var broadcaster_id: String;
	## The UTC date and time (in RFC3339 format) that another Hype Train can start.
	var cooldown_end_time: Variant;
	## The UTC date and time (in RFC3339 format) that the Hype Train ends.
	var expires_at: Variant;
	## The value needed to reach the next level.
	var goal: int;
	## An ID that identifies this Hype Train.
	var id: String;
	## The most recent contribution towards the Hype Train’s goal.
	var last_contribution: Dictionary;
	## The highest level that the Hype Train reached (the levels are 1 through 5).
	var level: int;
	## The UTC date and time (in RFC3339 format) that this Hype Train started.
	var started_at: Variant;
	## The top contributors for each contribution type. For example, the top contributor using BITS (by aggregate) and the top contributor using SUBS (by count).
	var top_contributions: Array;
	## The current total amount raised.
	var total: int;

	static func from_json(d: Dictionary) -> HypeTrainEventEventData:
		var result = HypeTrainEventEventData.new();
		result.broadcaster_id = d["broadcaster_id"];
		result.cooldown_end_time = d["cooldown_end_time"];
		result.expires_at = d["expires_at"];
		result.goal = d["goal"];
		result.id = d["id"];
		result.last_contribution = d["last_contribution"];
		result.level = d["level"];
		result.started_at = d["started_at"];
		result.top_contributions = d["top_contributions"];
		result.total = d["total"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["broadcaster_id"] = broadcaster_id;
		d["cooldown_end_time"] = cooldown_end_time;
		d["expires_at"] = expires_at;
		d["goal"] = goal;
		d["id"] = id;
		d["last_contribution"] = last_contribution;
		d["level"] = level;
		d["started_at"] = started_at;
		d["top_contributions"] = top_contributions;
		d["total"] = total;
		return d;

