@tool
extends RefCounted

class_name TwitchGetEmoteSetsResponse

## The list of emotes found in the specified emote sets. The list is empty if none of the IDs were found. The list is in the same order as the set IDs specified in the request. Each set contains one or more emoticons.
var data: Array[TwitchEmote];
## A templated URL. Use the values from the `id`, `format`, `scale`, and `theme_mode` fields to replace the like-named placeholder strings in the templated URL to create a CDN (content delivery network) URL that you use to fetch the emote. For information about what the template looks like and how to use it to fetch emotes, see [Emote CDN URL format](https://dev.twitch.tv/docs/irc/emotes#cdn-template). You should use this template instead of using the URLs in the `images` object.
var template: String;

static func from_json(d: Dictionary) -> TwitchGetEmoteSetsResponse:
	var result = TwitchGetEmoteSetsResponse.new();
	result.data = d["data"];
	result.template = d["template"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	d["template"] = template;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

