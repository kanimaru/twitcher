@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/BlockedTerm
class_name TwitchBlockedTerm
	
## The broadcaster that owns the list of blocked terms.
var broadcaster_id: String:
	set(val): 
		broadcaster_id = val
		track_data(&"broadcaster_id", val)

## The moderator that blocked the word or phrase from being used in the broadcaster’s chat room.
var moderator_id: String:
	set(val): 
		moderator_id = val
		track_data(&"moderator_id", val)

## An ID that identifies this blocked term.
var id: String:
	set(val): 
		id = val
		track_data(&"id", val)

## The blocked word or phrase.
var text: String:
	set(val): 
		text = val
		track_data(&"text", val)

## The UTC date and time (in RFC3339 format) that the term was blocked.
var created_at: Variant:
	set(val): 
		created_at = val
		track_data(&"created_at", val)

## The UTC date and time (in RFC3339 format) that the term was updated.  
##   
## When the term is added, this timestamp is the same as `created_at`. The timestamp changes as AutoMod continues to deny the term.
var updated_at: Variant:
	set(val): 
		updated_at = val
		track_data(&"updated_at", val)

## The UTC date and time (in RFC3339 format) that the blocked term is set to expire. After the block expires, users may use the term in the broadcaster’s chat room.  
##   
## This field is **null** if the term was added manually or was permanently blocked by AutoMod.
var expires_at: Variant:
	set(val): 
		expires_at = val
		track_data(&"expires_at", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_broadcaster_id: String, _moderator_id: String, _id: String, _text: String, _created_at: Variant, _updated_at: Variant, _expires_at: Variant) -> TwitchBlockedTerm:
	var twitch_blocked_term: TwitchBlockedTerm = TwitchBlockedTerm.new()
	twitch_blocked_term.broadcaster_id = _broadcaster_id
	twitch_blocked_term.moderator_id = _moderator_id
	twitch_blocked_term.id = _id
	twitch_blocked_term.text = _text
	twitch_blocked_term.created_at = _created_at
	twitch_blocked_term.updated_at = _updated_at
	twitch_blocked_term.expires_at = _expires_at
	return twitch_blocked_term


static func from_json(d: Dictionary) -> TwitchBlockedTerm:
	var result: TwitchBlockedTerm = TwitchBlockedTerm.new()
	if d.get("broadcaster_id", null) != null:
		result.broadcaster_id = d["broadcaster_id"]
	if d.get("moderator_id", null) != null:
		result.moderator_id = d["moderator_id"]
	if d.get("id", null) != null:
		result.id = d["id"]
	if d.get("text", null) != null:
		result.text = d["text"]
	if d.get("created_at", null) != null:
		result.created_at = d["created_at"]
	if d.get("updated_at", null) != null:
		result.updated_at = d["updated_at"]
	if d.get("expires_at", null) != null:
		result.expires_at = d["expires_at"]
	return result
