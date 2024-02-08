@tool
extends RefCounted

class_name TwitchGuestStarSession

## ID uniquely representing the Guest Star session.
var id: String;
## List of guests currently interacting with the Guest Star session.
var guests: Variant;
## ID representing this guest’s slot assignment.       * Host is always in slot "0" * Guests are assigned the following consecutive IDs (e.g, "1", "2", "3", etc) * Screen Share is represented as a special guest with the ID "SCREENSHARE" * The identifier here matches the ID referenced in browser source links used in broadcasting software.
var slot_id: String;
## Flag determining whether or not the guest is visible in the browser source in the host’s streaming software.
var is_live: bool;
## User ID of the guest assigned to this slot.
var user_id: String;
## Display name of the guest assigned to this slot.
var user_display_name: String;
## Login of the guest assigned to this slot.
var user_login: String;
## Value from 0 to 100 representing the host’s volume setting for this guest.
var volume: int;
## Timestamp when this guest was assigned a slot in the session.
var assigned_at: Variant;
## Information about the guest’s audio settings
var audio_settings: GuestStarSessionAudioSettings;
## Information about the guest’s video settings
var video_settings: GuestStarSessionVideoSettings;

static func from_json(d: Dictionary) -> TwitchGuestStarSession:
	var result = TwitchGuestStarSession.new();
	result.id = d["id"];
	result.guests = d["guests"];
	result.slot_id = d["slot_id"];
	result.is_live = d["is_live"];
	result.user_id = d["user_id"];
	result.user_display_name = d["user_display_name"];
	result.user_login = d["user_login"];
	result.volume = d["volume"];
	result.assigned_at = d["assigned_at"];

	result.audio_settings = GuestStarSessionAudioSettings.from_json(d["audio_settings"]);


	result.video_settings = GuestStarSessionVideoSettings.from_json(d["video_settings"]);

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["guests"] = guests;
	d["slot_id"] = slot_id;
	d["is_live"] = is_live;
	d["user_id"] = user_id;
	d["user_display_name"] = user_display_name;
	d["user_login"] = user_login;
	d["volume"] = volume;
	d["assigned_at"] = assigned_at;

	d["audio_settings"] = audio_settings.to_dict();


	d["video_settings"] = video_settings.to_dict();

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Information about the guest’s audio settings
class GuestStarSessionAudioSettings extends RefCounted:
	## Flag determining whether the host is allowing the guest’s audio to be seen or heard within the session.
	var is_host_enabled: bool;
	## Flag determining whether the guest is allowing their audio to be transmitted to the session.
	var is_guest_enabled: bool;
	## Flag determining whether the guest has an appropriate audio device available to be transmitted to the session.
	var is_available: bool;

	static func from_json(d: Dictionary) -> GuestStarSessionAudioSettings:
		var result = GuestStarSessionAudioSettings.new();
		result.is_host_enabled = d["is_host_enabled"];
		result.is_guest_enabled = d["is_guest_enabled"];
		result.is_available = d["is_available"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["is_host_enabled"] = is_host_enabled;
		d["is_guest_enabled"] = is_guest_enabled;
		d["is_available"] = is_available;
		return d;

## Information about the guest’s video settings
class GuestStarSessionVideoSettings extends RefCounted:
	## Flag determining whether the host is allowing the guest’s video to be seen or heard within the session.
	var is_host_enabled: bool;
	## Flag determining whether the guest is allowing their video to be transmitted to the session.
	var is_guest_enabled: bool;
	## Flag determining whether the guest has an appropriate video device available to be transmitted to the session.
	var is_available: bool;

	static func from_json(d: Dictionary) -> GuestStarSessionVideoSettings:
		var result = GuestStarSessionVideoSettings.new();
		result.is_host_enabled = d["is_host_enabled"];
		result.is_guest_enabled = d["is_guest_enabled"];
		result.is_available = d["is_available"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["is_host_enabled"] = is_host_enabled;
		d["is_guest_enabled"] = is_guest_enabled;
		d["is_available"] = is_available;
		return d;

