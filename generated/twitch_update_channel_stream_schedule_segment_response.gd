@tool
extends RefCounted

class_name TwitchUpdateChannelStreamScheduleSegmentResponse

## The broadcaster’s streaming scheduled.
var data: UpdateChannelStreamScheduleSegmentResponseData;

static func from_json(d: Dictionary) -> TwitchUpdateChannelStreamScheduleSegmentResponse:
	var result = TwitchUpdateChannelStreamScheduleSegmentResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	d["data"] = data.to_dict();
{else}
	d["data"] = data;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The broadcaster’s streaming scheduled.
class UpdateChannelStreamScheduleSegmentResponseData extends RefCounted:
	## A list that contains the single broadcast segment that you updated.
	var segments: Array[TwitchChannelStreamScheduleSegment];
	## The ID of the broadcaster that owns the broadcast schedule.
	var broadcaster_id: String;
	## The broadcaster’s display name.
	var broadcaster_name: String;
	## The broadcaster’s login name.
	var broadcaster_login: String;
	## The dates when the broadcaster is on vacation and not streaming. Is set to **null** if vacation mode is not enabled.
	var vacation: Dictionary;

	static func from_json(d: Dictionary) -> UpdateChannelStreamScheduleSegmentResponseData:
		var result = UpdateChannelStreamScheduleSegmentResponseData.new();
		result.segments = d["segments"];
		result.broadcaster_id = d["broadcaster_id"];
		result.broadcaster_name = d["broadcaster_name"];
		result.broadcaster_login = d["broadcaster_login"];
		result.vacation = d["vacation"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["segments"] = segments;
		d["broadcaster_id"] = broadcaster_id;
		d["broadcaster_name"] = broadcaster_name;
		d["broadcaster_login"] = broadcaster_login;
		d["vacation"] = vacation;
		return d;

