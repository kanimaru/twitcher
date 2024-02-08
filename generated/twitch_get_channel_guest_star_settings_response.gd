@tool
extends RefCounted

class_name TwitchGetChannelGuestStarSettingsResponse

## Flag determining if Guest Star moderators have access to control whether a guest is live once assigned to a slot.
var is_moderator_send_live_enabled: bool;
## Number of slots the Guest Star call interface will allow the host to add to a call. Required to be between 1 and 6.
var slot_count: int;
## Flag determining if Browser Sources subscribed to sessions on this channel should output audio
var is_browser_source_audio_enabled: bool;
## This setting determines how the guests within a session should be laid out within the browser source. Can be one of the following values:       * `TILED_LAYOUT`: All live guests are tiled within the browser source with the same size. * `SCREENSHARE_LAYOUT`: All live guests are tiled within the browser source with the same size. If there is an active screen share, it is sized larger than the other guests.
var group_layout: String;
## View only token to generate browser source URLs
var browser_source_token: String;

static func from_json(d: Dictionary) -> TwitchGetChannelGuestStarSettingsResponse:
	var result = TwitchGetChannelGuestStarSettingsResponse.new();
	result.is_moderator_send_live_enabled = d["is_moderator_send_live_enabled"];
	result.slot_count = d["slot_count"];
	result.is_browser_source_audio_enabled = d["is_browser_source_audio_enabled"];
	result.group_layout = d["group_layout"];
	result.browser_source_token = d["browser_source_token"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["is_moderator_send_live_enabled"] = is_moderator_send_live_enabled;
	d["slot_count"] = slot_count;
	d["is_browser_source_audio_enabled"] = is_browser_source_audio_enabled;
	d["group_layout"] = group_layout;
	d["browser_source_token"] = browser_source_token;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

