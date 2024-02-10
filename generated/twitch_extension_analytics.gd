@tool
extends RefCounted

class_name TwitchExtensionAnalytics

## An ID that identifies the extension that the report was generated for.
var extension_id: String;
## The URL that you use to download the report. The URL is valid for 5 minutes.
var URL: String;
## The type of report.
var type: String;
## The reporting window’s start and end dates, in RFC3339 format.
var date_range: ExtensionAnalyticsDateRange;

static func from_json(d: Dictionary) -> TwitchExtensionAnalytics:
	var result = TwitchExtensionAnalytics.new();




	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};




	d["date_range"] = date_range.to_dict();
{else}
	d["date_range"] = date_range;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The reporting window’s start and end dates, in RFC3339 format.
class ExtensionAnalyticsDateRange extends RefCounted:
	## The reporting window’s start date.
	var started_at: Variant;
	## The reporting window’s end date.
	var ended_at: Variant;

	static func from_json(d: Dictionary) -> ExtensionAnalyticsDateRange:
		var result = ExtensionAnalyticsDateRange.new();
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

