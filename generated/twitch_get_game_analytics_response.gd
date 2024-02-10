@tool
extends RefCounted

class_name TwitchGetGameAnalyticsResponse

## A list of reports. The reports are returned in no particular order; however, the data within each report is in ascending order by date (newest first). The report contains one row of data per day of the reporting window; the report contains rows for only those days that the game was used. A report is available only if the game was broadcast for at least 5 hours over the reporting period. The array is empty if there are no reports.
var data: Array[TwitchGameAnalytics];
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: GetGameAnalyticsResponsePagination;

static func from_json(d: Dictionary) -> TwitchGetGameAnalyticsResponse:
	var result = TwitchGetGameAnalyticsResponse.new();


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	d["pagination"] = pagination.to_dict();
{else}
	d["pagination"] = pagination;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class GetGameAnalyticsResponsePagination extends RefCounted:
	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ query parameter.
	var cursor: String;

	static func from_json(d: Dictionary) -> GetGameAnalyticsResponsePagination:
		var result = GetGameAnalyticsResponsePagination.new();
		result.cursor = d["cursor"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["cursor"] = cursor;
		return d;

