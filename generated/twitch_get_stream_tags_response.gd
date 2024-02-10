@tool
extends RefCounted

class_name TwitchGetStreamTagsResponse

## The list of stream tags. The list is empty if the broadcaster or Twitch hasn’t added tags to the broadcaster’s channel.
var data: Array[TwitchStreamTag];

static func from_json(d: Dictionary) -> TwitchGetStreamTagsResponse:
	var result = TwitchGetStreamTagsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

