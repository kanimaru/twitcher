@tool
extends RefCounted

class_name TwitchUpdateChannelStreamScheduleSegmentBody

## The date and time that the broadcast segment starts. Specify the date and time in RFC3339 format (for example, 2022-08-02T06:00:00Z).      **NOTE**: Only partners and affiliates may update a broadcast’s start time and only for non-recurring segments.
var start_time: Variant;
## The length of time, in minutes, that the broadcast is scheduled to run. The duration must be in the range 30 through 1380 (23 hours).
var duration: String;
## The ID of the category that best represents the broadcast’s content. To get the category ID, use the [Search Categories](https://dev.twitch.tv/docs/api/reference#search-categories) endpoint.
var category_id: String;
## The broadcast’s title. The title may contain a maximum of 140 characters.
var title: String;
## A Boolean value that indicates whether the broadcast is canceled. Set to **true** to cancel the segment.      **NOTE**: For recurring segments, the API cancels the first segment after the current UTC date and time and not the specified segment (unless the specified segment is the next segment after the current UTC date and time).
var is_canceled: bool;
## The time zone where the broadcast takes place. Specify the time zone using [IANA time zone database](https://www.iana.org/time-zones) format (for example, America/New\_York).
var timezone: String;

static func from_json(d: Dictionary) -> TwitchUpdateChannelStreamScheduleSegmentBody:
	var result = TwitchUpdateChannelStreamScheduleSegmentBody.new();






	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};






	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

