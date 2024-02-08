@tool
extends RefCounted

class_name TwitchSendChatAnnouncementBody

## The announcement to make in the broadcaster’s chat room. Announcements are limited to a maximum of 500 characters; announcements longer than 500 characters are truncated.
var message: String;
## The color used to highlight the announcement. Possible case-sensitive values are:      * blue * green * orange * purple * primary (default)    If `color` is set to _primary_ or is not set, the channel’s accent color is used to highlight the announcement (see **Profile Accent Color** under [profile settings](https://www.twitch.tv/settings/profile), **Channel and Videos**, and **Brand**).
var color: String;

static func from_json(d: Dictionary) -> TwitchSendChatAnnouncementBody:
	var result = TwitchSendChatAnnouncementBody.new();
	result.message = d["message"];
	result.color = d["color"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["message"] = message;
	d["color"] = color;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

