@tool
extends RefCounted

class_name TwitchGlobalEmote

## An ID that identifies this emote.
var id: String;
## The name of the emote. This is the name that viewers type in the chat window to get the emote to appear.
var name: String;
## The image URLs for the emote. These image URLs always provide a static, non-animated emote image with a light background.      **NOTE:** You should use the templated URL in the `template` field to fetch the image instead of using these URLs.
var images: GlobalEmoteImages;
## The formats that the emote is available in. For example, if the emote is available only as a static PNG, the array contains only `static`. But if the emote is available as a static PNG and an animated GIF, the array contains `static` and `animated`. The possible formats are:      * animated — An animated GIF is available for this emote. * static — A static PNG file is available for this emote.
var format: Array[String];
## The sizes that the emote is available in. For example, if the emote is available in small and medium sizes, the array contains 1.0 and 2.0\. Possible sizes are:      * 1.0 — A small version (28px x 28px) is available. * 2.0 — A medium version (56px x 56px) is available. * 3.0 — A large version (112px x 112px) is available.
var scale: Array[String];
## The background themes that the emote is available in. Possible themes are:      * dark * light
var theme_mode: Array[String];

static func from_json(d: Dictionary) -> TwitchGlobalEmote:
	var result = TwitchGlobalEmote.new();




	for value in d["format"]:
		result.format.append(value);
{elif property.is_typed_array}
	for value in d["format"]:
		result.format.append(.from_json(value));
{elif property.is_sub_class}
	result.format = Array[String].from_json(d["format"]);
{else}
	result.format = d["format"];


	for value in d["scale"]:
		result.scale.append(value);
{elif property.is_typed_array}
	for value in d["scale"]:
		result.scale.append(.from_json(value));
{elif property.is_sub_class}
	result.scale = Array[String].from_json(d["scale"]);
{else}
	result.scale = d["scale"];


	for value in d["theme_mode"]:
		result.theme_mode.append(value);
{elif property.is_typed_array}
	for value in d["theme_mode"]:
		result.theme_mode.append(.from_json(value));
{elif property.is_sub_class}
	result.theme_mode = Array[String].from_json(d["theme_mode"]);
{else}
	result.theme_mode = d["theme_mode"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};



	d["images"] = images.to_dict();
{else}
	d["images"] = images;




	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The image URLs for the emote. These image URLs always provide a static, non-animated emote image with a light background.      **NOTE:** You should use the templated URL in the `template` field to fetch the image instead of using these URLs.
class GlobalEmoteImages extends RefCounted:
	## A URL to the small version (28px x 28px) of the emote.
	var url_1x: String;
	## A URL to the medium version (56px x 56px) of the emote.
	var url_2x: String;
	## A URL to the large version (112px x 112px) of the emote.
	var url_4x: String;

	static func from_json(d: Dictionary) -> GlobalEmoteImages:
		var result = GlobalEmoteImages.new();
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

