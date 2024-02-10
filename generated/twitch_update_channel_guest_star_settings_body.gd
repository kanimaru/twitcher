@tool
extends RefCounted

class_name TwitchUpdateChannelGuestStarSettingsBody

## Flag determining if Guest Star moderators have access to control whether a guest is live once assigned to a slot.
var is_moderator_send_live_enabled: bool;
## Number of slots the Guest Star call interface will allow the host to add to a call. Required to be between 1 and 6.
var slot_count: int;
## Flag determining if Browser Sources subscribed to sessions on this channel should output audio
var is_browser_source_audio_enabled: bool;
## This setting determines how the guests within a session should be laid out within the browser source. Can be one of the following values:       * `TILED_LAYOUT`: All live guests are tiled within the browser source with the same size. * `SCREENSHARE_LAYOUT`: All live guests are tiled within the browser source with the same size. If there is an active screen share, it is sized larger than the other guests. * `HORIZONTAL_LAYOUT`: All live guests are arranged in a horizontal bar within the browser source * `VERTICAL_LAYOUT`: All live guests are arranged in a vertical bar within the browser source
var group_layout: String;
## Flag determining if Guest Star should regenerate the auth token associated with the channel’s browser sources. Providing a true value for this will immediately invalidate all browser sources previously configured in your streaming software.
var regenerate_browser_sources: bool;

static func from_json(d: Dictionary) -> TwitchUpdateChannelGuestStarSettingsBody:
	var result = TwitchUpdateChannelGuestStarSettingsBody.new();





	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};





	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

