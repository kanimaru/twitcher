@tool
extends RefCounted

class_name TwitchGetChannelStreamScheduleResponse

## The broadcaster’s streaming schedule.
var data: GetChannelStreamScheduleResponseData;

static func from_json(d: Dictionary) -> TwitchGetChannelStreamScheduleResponse:
	var result = TwitchGetChannelStreamScheduleResponse.new();

	result.data = GetChannelStreamScheduleResponseData.from_json(d["data"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	d["data"] = data.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The broadcaster’s streaming schedule.
class GetChannelStreamScheduleResponseData extends RefCounted:
	## The list of broadcasts in the broadcaster’s streaming schedule.
	var segments: Array[TwitchChannelStreamScheduleSegment];
	## The ID of the broadcaster that owns the broadcast schedule.
	var broadcaster_id: String;
	## The broadcaster’s display name.
	var broadcaster_name: String;
	## The broadcaster’s login name.
	var broadcaster_login: String;
	## The dates when the broadcaster is on vacation and not streaming. Is set to **null** if vacation mode is not enabled.
	var vacation: Dictionary;
	## The information used to page through a list of results. The object is empty if there are no more pages left to page through. [Read more](https://dev.twitch.tv/docs/api/guide#pagination).
	var pagination: Dictionary;

	static func from_json(d: Dictionary) -> GetChannelStreamScheduleResponseData:
		var result = GetChannelStreamScheduleResponseData.new();
		result.segments = d["segments"];
		result.broadcaster_id = d["broadcaster_id"];
		result.broadcaster_name = d["broadcaster_name"];
		result.broadcaster_login = d["broadcaster_login"];
		result.vacation = d["vacation"];
		result.pagination = d["pagination"];
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
		d["pagination"] = pagination;
		return d;

