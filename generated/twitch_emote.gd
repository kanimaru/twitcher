@tool
extends RefCounted

class_name TwitchEmote

## An ID that uniquely identifies this emote.
var id: String;
## The name of the emote. This is the name that viewers type in the chat window to get the emote to appear.
var name: String;
## The image URLs for the emote. These image URLs always provide a static, non-animated emote image with a light background.      **NOTE:** You should use the templated URL in the `template` field to fetch the image instead of using these URLs.
var images: EmoteImages;
## The type of emote. The possible values are:       * bitstier — A Bits tier emote. * follower — A follower emote. * subscriptions — A subscriber emote.
var emote_type: String;
## An ID that identifies the emote set that the emote belongs to.
var emote_set_id: String;
## The ID of the broadcaster who owns the emote.
var owner_id: String;
## The formats that the emote is available in. For example, if the emote is available only as a static PNG, the array contains only `static`. But if the emote is available as a static PNG and an animated GIF, the array contains `static` and `animated`. The possible formats are:       * animated — An animated GIF is available for this emote. * static — A static PNG file is available for this emote.
var format: Array[String];
## The sizes that the emote is available in. For example, if the emote is available in small and medium sizes, the array contains 1.0 and 2.0\. Possible sizes are:       * 1.0 — A small version (28px x 28px) is available. * 2.0 — A medium version (56px x 56px) is available. * 3.0 — A large version (112px x 112px) is available.
var scale: Array[String];
## The background themes that the emote is available in. Possible themes are:       * dark * light
var theme_mode: Array[String];

static func from_json(d: Dictionary) -> TwitchEmote:
	var result = TwitchEmote.new();
	result.id = d["id"];
	result.name = d["name"];

	result.images = EmoteImages.from_json(d["images"]);

	result.emote_type = d["emote_type"];
	result.emote_set_id = d["emote_set_id"];
	result.owner_id = d["owner_id"];
	result.format = d["format"];
	result.scale = d["scale"];
	result.theme_mode = d["theme_mode"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["name"] = name;

	d["images"] = images.to_dict();

	d["emote_type"] = emote_type;
	d["emote_set_id"] = emote_set_id;
	d["owner_id"] = owner_id;
	d["format"] = format;
	d["scale"] = scale;
	d["theme_mode"] = theme_mode;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The image URLs for the emote. These image URLs always provide a static, non-animated emote image with a light background.      **NOTE:** You should use the templated URL in the `template` field to fetch the image instead of using these URLs.
class EmoteImages extends RefCounted:
	## A URL to the small version (28px x 28px) of the emote.
	var url_1x: String;
	## A URL to the medium version (56px x 56px) of the emote.
	var url_2x: String;
	## A URL to the large version (112px x 112px) of the emote.
	var url_4x: String;

	static func from_json(d: Dictionary) -> EmoteImages:
		var result = EmoteImages.new();
		result.url_1x = d["url_1x"];
		result.url_2x = d["url_2x"];
		result.url_4x = d["url_4x"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["url_1x"] = url_1x;
		d["url_2x"] = url_2x;
		d["url_4x"] = url_4x;
		return d;

