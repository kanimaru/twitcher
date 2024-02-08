@tool
extends RefCounted

class_name TwitchGameAnalytics

## An ID that identifies the game that the report was generated for.
var game_id: String;
## The URL that you use to download the report. The URL is valid for 5 minutes.
var URL: String;
## The type of report.
var type: String;
## The reporting window’s start and end dates, in RFC3339 format.
var date_range: GameAnalyticsDateRange;

static func from_json(d: Dictionary) -> TwitchGameAnalytics:
	var result = TwitchGameAnalytics.new();
	result.game_id = d["game_id"];
	result.URL = d["URL"];
	result.type = d["type"];

	result.date_range = GameAnalyticsDateRange.from_json(d["date_range"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["game_id"] = game_id;
	d["URL"] = URL;
	d["type"] = type;

	d["date_range"] = date_range.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The reporting window’s start and end dates, in RFC3339 format.
class GameAnalyticsDateRange extends RefCounted:
	## The reporting window’s start date.
	var started_at: Variant;
	## The reporting window’s end date.
	var ended_at: Variant;

	static func from_json(d: Dictionary) -> GameAnalyticsDateRange:
		var result = GameAnalyticsDateRange.new();
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

