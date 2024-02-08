@tool
extends RefCounted

class_name TwitchBanUserBody

## Identifies the user and type of ban.
var data: BanUserBodyData;

static func from_json(d: Dictionary) -> TwitchBanUserBody:
	var result = TwitchBanUserBody.new();

	result.data = BanUserBodyData.from_json(d["data"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	d["data"] = data.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Identifies the user and type of ban.
class BanUserBodyData extends RefCounted:
	## The ID of the user to ban or put in a timeout.
	var user_id: String;
	## To ban a user indefinitely, don’t include this field.      To put a user in a timeout, include this field and specify the timeout period, in seconds. The minimum timeout is 1 second and the maximum is 1,209,600 seconds (2 weeks).      To end a user’s timeout early, set this field to 1, or use the [Unban user](https://dev.twitch.tv/docs/api/reference#unban-user) endpoint.
	var duration: int;
	## The reason the you’re banning the user or putting them in a timeout. The text is user defined and is limited to a maximum of 500 characters.
	var reason: String;

	static func from_json(d: Dictionary) -> BanUserBodyData:
		var result = BanUserBodyData.new();
		result.user_id = d["user_id"];
		result.duration = d["duration"];
		result.reason = d["reason"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["user_id"] = user_id;
		d["duration"] = duration;
		d["reason"] = reason;
		return d;

