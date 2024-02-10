@tool
extends RefCounted

class_name TwitchModifyChannelInformationBody

## The ID of the game that the user plays. The game is not updated if the ID isn’t a game ID that Twitch recognizes. To unset this field, use “0” or “” (an empty string).
var game_id: String;
## The user’s preferred language. Set the value to an ISO 639-1 two-letter language code (for example, _en_ for English). Set to “other” if the user’s preferred language is not a Twitch supported language. The language isn’t updated if the language code isn’t a Twitch supported language.
var broadcaster_language: String;
## The title of the user’s stream. You may not set this field to an empty string.
var title: String;
## The number of seconds you want your broadcast buffered before streaming it live. The delay helps ensure fairness during competitive play. Only users with Partner status may set this field. The maximum delay is 900 seconds (15 minutes).
var delay: int;
## A list of channel-defined tags to apply to the channel. To remove all tags from the channel, set tags to an empty array. Tags help identify the content that the channel streams. [Learn More](https://help.twitch.tv/s/article/guide-to-tags)      A channel may specify a maximum of 10 tags. Each tag is limited to a maximum of 25 characters and may not be an empty string or contain spaces or special characters. Tags are case insensitive. For readability, consider using camelCasing or PascalCasing.
var tags: Array[String];
## List of labels that should be set as the Channel’s CCLs.
var content_classification_labels: Array;
## Boolean flag indicating if the channel has branded content.
var is_branded_content: bool;

static func from_json(d: Dictionary) -> TwitchModifyChannelInformationBody:
	var result = TwitchModifyChannelInformationBody.new();





	for value in d["tags"]:
		result.tags.append(value);
{elif property.is_typed_array}
	for value in d["tags"]:
		result.tags.append(.from_json(value));
{elif property.is_sub_class}
	result.tags = Array[String].from_json(d["tags"]);
{else}
	result.tags = d["tags"];


	for value in d["content_classification_labels"]:
		result.content_classification_labels.append(value);
{elif property.is_typed_array}
	for value in d["content_classification_labels"]:
		result.content_classification_labels.append(.from_json(value));
{elif property.is_sub_class}
	result.content_classification_labels = Array.from_json(d["content_classification_labels"]);
{else}
	result.content_classification_labels = d["content_classification_labels"];


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};







	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

