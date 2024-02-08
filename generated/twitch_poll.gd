@tool
extends RefCounted

class_name TwitchPoll

## An ID that identifies the poll.
var id: String;
## An ID that identifies the broadcaster that created the poll.
var broadcaster_id: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The question that viewers are voting on. For example, _What game should I play next?_ The title may contain a maximum of 60 characters.
var title: String;
## A list of choices that viewers can choose from. The list will contain a minimum of two choices and up to a maximum of five choices.
var choices: Array;
## Not used; will be set to **false**.
var bits_voting_enabled: bool;
## Not used; will be set to 0.
var bits_per_vote: int;
## A Boolean value that indicates whether viewers may cast additional votes using Channel Points. For information about Channel Points, see [Channel Points Guide](https://help.twitch.tv/s/article/channel-points-guide).
var channel_points_voting_enabled: bool;
## The number of points the viewer must spend to cast one additional vote.
var channel_points_per_vote: int;
## The poll’s status. Valid values are:      * ACTIVE — The poll is running. * COMPLETED — The poll ended on schedule (see the `duration` field). * TERMINATED — The poll was terminated before its scheduled end. * ARCHIVED — The poll has been archived and is no longer visible on the channel. * MODERATED — The poll was deleted. * INVALID — Something went wrong while determining the state.
var status: String;
## The length of time (in seconds) that the poll will run for.
var duration: int;
## The UTC date and time (in RFC3339 format) of when the poll began.
var started_at: Variant;
## The UTC date and time (in RFC3339 format) of when the poll ended. If `status` is ACTIVE, this field is set to **null**.
var ended_at: Variant;

static func from_json(d: Dictionary) -> TwitchPoll:
	var result = TwitchPoll.new();
	result.id = d["id"];
	result.broadcaster_id = d["broadcaster_id"];
	result.broadcaster_name = d["broadcaster_name"];
	result.broadcaster_login = d["broadcaster_login"];
	result.title = d["title"];
	result.choices = d["choices"];
	result.bits_voting_enabled = d["bits_voting_enabled"];
	result.bits_per_vote = d["bits_per_vote"];
	result.channel_points_voting_enabled = d["channel_points_voting_enabled"];
	result.channel_points_per_vote = d["channel_points_per_vote"];
	result.status = d["status"];
	result.duration = d["duration"];
	result.started_at = d["started_at"];
	result.ended_at = d["ended_at"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["broadcaster_id"] = broadcaster_id;
	d["broadcaster_name"] = broadcaster_name;
	d["broadcaster_login"] = broadcaster_login;
	d["title"] = title;
	d["choices"] = choices;
	d["bits_voting_enabled"] = bits_voting_enabled;
	d["bits_per_vote"] = bits_per_vote;
	d["channel_points_voting_enabled"] = channel_points_voting_enabled;
	d["channel_points_per_vote"] = channel_points_per_vote;
	d["status"] = status;
	d["duration"] = duration;
	d["started_at"] = started_at;
	d["ended_at"] = ended_at;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

