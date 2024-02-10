@tool
extends RefCounted

class_name TwitchStreamTag

## An ID that identifies this tag.
var tag_id: String;
## A Boolean value that determines whether the tag is an automatic tag. An automatic tag is one that Twitch adds to the stream. Broadcasters may not add automatic tags to their channel. The value is **true** if the tag is an automatic tag; otherwise, **false**.
var is_auto: bool;
## A dictionary that contains the localized names of the tag. The key is in the form, <locale>-<coutry/region>. For example, en-us. The value is the localized name.
var localization_names: Dictionary;
## A dictionary that contains the localized descriptions of the tag. The key is in the form, <locale>-<coutry/region>. For example, en-us. The value is the localized description.
var localization_descriptions: Dictionary;

static func from_json(d: Dictionary) -> TwitchStreamTag:
	var result = TwitchStreamTag.new();




	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};




	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

