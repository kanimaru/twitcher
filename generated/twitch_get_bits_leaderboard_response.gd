@tool
extends RefCounted

class_name TwitchGetBitsLeaderboardResponse

## A list of leaderboard leaders. The leaders are returned in rank order by how much they’ve cheered. The array is empty if nobody has cheered bits.
var data: Array[TwitchBitsLeaderboard];
## The reporting window’s start and end dates, in RFC3339 format. The dates are calculated by using the _started\_at_ and _period_ query parameters. If you don’t specify the _started\_at_ query parameter, the fields contain empty strings.
var date_range: GetBitsLeaderboardResponseDateRange;
## The number of ranked users in `data`. This is the value in the _count_ query parameter or the total number of entries on the leaderboard, whichever is less.
var total: int;

static func from_json(d: Dictionary) -> TwitchGetBitsLeaderboardResponse:
	var result = TwitchGetBitsLeaderboardResponse.new();
	result.data = d["data"];

	result.date_range = GetBitsLeaderboardResponseDateRange.from_json(d["date_range"]);

	result.total = d["total"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;

	d["date_range"] = date_range.to_dict();

	d["total"] = total;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The reporting window’s start and end dates, in RFC3339 format. The dates are calculated by using the _started\_at_ and _period_ query parameters. If you don’t specify the _started\_at_ query parameter, the fields contain empty strings.
class GetBitsLeaderboardResponseDateRange extends RefCounted:
	## The reporting window’s start date.
	var started_at: Variant;
	## The reporting window’s end date.
	var ended_at: Variant;

	static func from_json(d: Dictionary) -> GetBitsLeaderboardResponseDateRange:
		var result = GetBitsLeaderboardResponseDateRange.new();
		result.started_at = d["started_at"];
		result.ended_at = d["ended_at"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["started_at"] = started_at;
		d["ended_at"] = ended_at;
		return d;

