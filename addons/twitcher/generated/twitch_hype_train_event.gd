@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchHypeTrainEvent

## An ID that identifies this event.
var id: String:
	set(val):
		id = val
		changed_data["id"] = id
## The type of event. The string is in the form, hypetrain.{event\_name}. The request returns only progress event types (i.e., hypetrain.progression).
var event_type: String:
	set(val):
		event_type = val
		changed_data["event_type"] = event_type
## The UTC date and time (in RFC3339 format) that the event occurred.
var event_timestamp: Variant:
	set(val):
		event_timestamp = val
		changed_data["event_timestamp"] = event_timestamp
## The version number of the definition of the event’s data. For example, the value is 1 if the data in `event_data` uses the first definition of the event’s data.
var version: String:
	set(val):
		version = val
		changed_data["version"] = version
## The event’s data.
var event_data: EventData:
	set(val):
		event_data = val
		if event_data != null:
			changed_data["event_data"] = event_data.to_dict()

var changed_data: Dictionary = {}

static func from_json(d: Dictionary) -> TwitchHypeTrainEvent:
	var result = TwitchHypeTrainEvent.new()
	if d.has("id") && d["id"] != null:
		result.id = d["id"]
	if d.has("event_type") && d["event_type"] != null:
		result.event_type = d["event_type"]
	if d.has("event_timestamp") && d["event_timestamp"] != null:
		result.event_timestamp = d["event_timestamp"]
	if d.has("version") && d["version"] != null:
		result.version = d["version"]
	if d.has("event_data") && d["event_data"] != null:
		result.event_data = EventData.from_json(d["event_data"])
	return result

func to_dict() -> Dictionary:
	return changed_data

func to_json() -> String:
	return JSON.stringify(to_dict())

## The most recent contribution towards the Hype Train’s goal.
class LastContribution extends RefCounted:
	## The total amount contributed. If `type` is BITS, `total` represents the amount of Bits used. If `type` is SUBS, `total` is 500, 1000, or 2500 to represent tier 1, 2, or 3 subscriptions, respectively.
	var total: int:
		set(val):
			total = val
			changed_data["total"] = total
	## The contribution method used. Possible values are:      * BITS — Cheering with Bits. * SUBS — Subscription activity like subscribing or gifting subscriptions. * OTHER — Covers other contribution methods not listed.
	var type: String:
		set(val):
			type = val
			changed_data["type"] = type
	## The ID of the user that made the contribution.
	var user: String:
		set(val):
			user = val
			changed_data["user"] = user

	var changed_data: Dictionary = {}

	static func from_json(d: Dictionary) -> LastContribution:
		var result = LastContribution.new()
		if d.has("total") && d["total"] != null:
			result.total = d["total"]
		if d.has("type") && d["type"] != null:
			result.type = d["type"]
		if d.has("user") && d["user"] != null:
			result.user = d["user"]
		return result

	func to_dict() -> Dictionary:
		return changed_data

	func to_json() -> String:
		return JSON.stringify(to_dict())

## 
class TopContributions extends RefCounted:
	## The total amount contributed. If `type` is BITS, `total` represents the amount of Bits used. If `type` is SUBS, `total` is 500, 1000, or 2500 to represent tier 1, 2, or 3 subscriptions, respectively.
	var total: int:
		set(val):
			total = val
			changed_data["total"] = total
	## The contribution method used. Possible values are:      * BITS — Cheering with Bits. * SUBS — Subscription activity like subscribing or gifting subscriptions. * OTHER — Covers other contribution methods not listed.
	var type: String:
		set(val):
			type = val
			changed_data["type"] = type
	## The ID of the user that made the contribution.
	var user: String:
		set(val):
			user = val
			changed_data["user"] = user

	var changed_data: Dictionary = {}

	static func from_json(d: Dictionary) -> TopContributions:
		var result = TopContributions.new()
		if d.has("total") && d["total"] != null:
			result.total = d["total"]
		if d.has("type") && d["type"] != null:
			result.type = d["type"]
		if d.has("user") && d["user"] != null:
			result.user = d["user"]
		return result

	func to_dict() -> Dictionary:
		return changed_data

	func to_json() -> String:
		return JSON.stringify(to_dict())

## The event’s data.
class EventData extends RefCounted:
	## The ID of the broadcaster that’s running the Hype Train.
	var broadcaster_id: String:
		set(val):
			broadcaster_id = val
			changed_data["broadcaster_id"] = broadcaster_id
	## The UTC date and time (in RFC3339 format) that another Hype Train can start.
	var cooldown_end_time: Variant:
		set(val):
			cooldown_end_time = val
			changed_data["cooldown_end_time"] = cooldown_end_time
	## The UTC date and time (in RFC3339 format) that the Hype Train ends.
	var expires_at: Variant:
		set(val):
			expires_at = val
			changed_data["expires_at"] = expires_at
	## The value needed to reach the next level.
	var goal: int:
		set(val):
			goal = val
			changed_data["goal"] = goal
	## An ID that identifies this Hype Train.
	var id: String:
		set(val):
			id = val
			changed_data["id"] = id
	## The most recent contribution towards the Hype Train’s goal.
	var last_contribution: LastContribution:
		set(val):
			last_contribution = val
			if last_contribution != null:
				changed_data["last_contribution"] = last_contribution.to_dict()
	## The highest level that the Hype Train reached (the levels are 1 through 5).
	var level: int:
		set(val):
			level = val
			changed_data["level"] = level
	## The UTC date and time (in RFC3339 format) that this Hype Train started.
	var started_at: Variant:
		set(val):
			started_at = val
			changed_data["started_at"] = started_at
	## The top contributors for each contribution type. For example, the top contributor using BITS (by aggregate) and the top contributor using SUBS (by count).
	var top_contributions: Array[TopContributions]:
		set(val):
			top_contributions = val
			changed_data["top_contributions"] = []
			if top_contributions != null:
				for value in top_contributions:
					changed_data["top_contributions"].append(value.to_dict())
	## The current total amount raised.
	var total: int:
		set(val):
			total = val
			changed_data["total"] = total

	var changed_data: Dictionary = {}

	static func from_json(d: Dictionary) -> EventData:
		var result = EventData.new()
		if d.has("broadcaster_id") && d["broadcaster_id"] != null:
			result.broadcaster_id = d["broadcaster_id"]
		if d.has("cooldown_end_time") && d["cooldown_end_time"] != null:
			result.cooldown_end_time = d["cooldown_end_time"]
		if d.has("expires_at") && d["expires_at"] != null:
			result.expires_at = d["expires_at"]
		if d.has("goal") && d["goal"] != null:
			result.goal = d["goal"]
		if d.has("id") && d["id"] != null:
			result.id = d["id"]
		if d.has("last_contribution") && d["last_contribution"] != null:
			result.last_contribution = LastContribution.from_json(d["last_contribution"])
		if d.has("level") && d["level"] != null:
			result.level = d["level"]
		if d.has("started_at") && d["started_at"] != null:
			result.started_at = d["started_at"]
		if d.has("top_contributions") && d["top_contributions"] != null:
			for value in d["top_contributions"]:
				result.top_contributions.append(TopContributions.from_json(value))
		if d.has("total") && d["total"] != null:
			result.total = d["total"]
		return result

	func to_dict() -> Dictionary:
		return changed_data

	func to_json() -> String:
		return JSON.stringify(to_dict())

