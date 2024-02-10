@tool
extends RefCounted

class_name TwitchChannelInformation

## An ID that uniquely identifies the broadcaster.
var broadcaster_id: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The broadcaster’s preferred language. The value is an ISO 639-1 two-letter language code (for example, _en_ for English). The value is set to “other” if the language is not a Twitch supported language.
var broadcaster_language: String;
## The name of the game that the broadcaster is playing or last played. The value is an empty string if the broadcaster has never played a game.
var game_name: String;
## An ID that uniquely identifies the game that the broadcaster is playing or last played. The value is an empty string if the broadcaster has never played a game.
var game_id: String;
## The title of the stream that the broadcaster is currently streaming or last streamed. The value is an empty string if the broadcaster has never streamed.
var title: String;
## The value of the broadcaster’s stream delay setting, in seconds. This field’s value defaults to zero unless 1) the request specifies a user access token, 2) the ID in the _broadcaster\_id_ query parameter matches the user ID in the access token, and 3) the broadcaster has partner status and they set a non-zero stream delay value.
var delay: int;
## The tags applied to the channel.
var tags: Array[String];
## The CCLs applied to the channel.
var content_classification_labels: Array[String];
## Boolean flag indicating if the channel has branded content.
var is_branded_content: bool;

static func from_json(d: Dictionary) -> TwitchChannelInformation:
	var result = TwitchChannelInformation.new();









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
	result.content_classification_labels = Array[String].from_json(d["content_classification_labels"]);
{else}
	result.content_classification_labels = d["content_classification_labels"];


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};











	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

