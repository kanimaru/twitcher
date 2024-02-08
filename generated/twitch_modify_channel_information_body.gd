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
	result.game_id = d["game_id"];
	result.broadcaster_language = d["broadcaster_language"];
	result.title = d["title"];
	result.delay = d["delay"];
	result.tags = d["tags"];
	result.content_classification_labels = d["content_classification_labels"];
	result.is_branded_content = d["is_branded_content"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["game_id"] = game_id;
	d["broadcaster_language"] = broadcaster_language;
	d["title"] = title;
	d["delay"] = delay;
	d["tags"] = tags;
	d["content_classification_labels"] = content_classification_labels;
	d["is_branded_content"] = is_branded_content;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

