@tool
extends RefCounted

class_name TwitchBlockedTerm

## The broadcaster that owns the list of blocked terms.
var broadcaster_id: String;
## The moderator that blocked the word or phrase from being used in the broadcaster’s chat room.
var moderator_id: String;
## An ID that identifies this blocked term.
var id: String;
## The blocked word or phrase.
var text: String;
## The UTC date and time (in RFC3339 format) that the term was blocked.
var created_at: Variant;
## The UTC date and time (in RFC3339 format) that the term was updated.      When the term is added, this timestamp is the same as `created_at`. The timestamp changes as AutoMod continues to deny the term.
var updated_at: Variant;
## The UTC date and time (in RFC3339 format) that the blocked term is set to expire. After the block expires, users may use the term in the broadcaster’s chat room.      This field is **null** if the term was added manually or was permanently blocked by AutoMod.
var expires_at: Variant;

static func from_json(d: Dictionary) -> TwitchBlockedTerm:
	var result = TwitchBlockedTerm.new();
	result.broadcaster_id = d["broadcaster_id"];
	result.moderator_id = d["moderator_id"];
	result.id = d["id"];
	result.text = d["text"];
	result.created_at = d["created_at"];
	result.updated_at = d["updated_at"];
	result.expires_at = d["expires_at"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["broadcaster_id"] = broadcaster_id;
	d["moderator_id"] = moderator_id;
	d["id"] = id;
	d["text"] = text;
	d["created_at"] = created_at;
	d["updated_at"] = updated_at;
	d["expires_at"] = expires_at;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

