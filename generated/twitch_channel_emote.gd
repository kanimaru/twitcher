@tool
extends RefCounted

class_name TwitchChannelEmote

## An ID that identifies this emote.
var id: String;
## The name of the emote. This is the name that viewers type in the chat window to get the emote to appear.
var name: String;
## The image URLs for the emote. These image URLs always provide a static, non-animated emote image with a light background.      **NOTE:** You should use the templated URL in the `template` field to fetch the image instead of using these URLs.
var images: Images;
## The subscriber tier at which the emote is unlocked. This field contains the tier information only if `emote_type` is set to `subscriptions`, otherwise, it's an empty string.
var tier: String;
## The type of emote. The possible values are:      * bitstier — A custom Bits tier emote. * follower — A custom follower emote. * subscriptions — A custom subscriber emote.
var emote_type: String;
## An ID that identifies the emote set that the emote belongs to.
var emote_set_id: String;
## The formats that the emote is available in. For example, if the emote is available only as a static PNG, the array contains only `static`. But if the emote is available as a static PNG and an animated GIF, the array contains `static` and `animated`. The possible formats are:      * animated — An animated GIF is available for this emote. * static — A static PNG file is available for this emote.
var format: Array[String];
## The sizes that the emote is available in. For example, if the emote is available in small and medium sizes, the array contains 1.0 and 2.0\. Possible sizes are:      * 1.0 — A small version (28px x 28px) is available. * 2.0 — A medium version (56px x 56px) is available. * 3.0 — A large version (112px x 112px) is available.
var scale: Array[String];
## The background themes that the emote is available in. Possible themes are:      * dark * light
var theme_mode: Array[String];

static func from_json(d: Dictionary) -> TwitchChannelEmote:
	var result = TwitchChannelEmote.new();
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("name") && d["name"] != null:
		result.name = d["name"];
	if d.has("images") && d["images"] != null:
		result.images = Images.from_json(d["images"]);
	if d.has("tier") && d["tier"] != null:
		result.tier = d["tier"];
	if d.has("emote_type") && d["emote_type"] != null:
		result.emote_type = d["emote_type"];
	if d.has("emote_set_id") && d["emote_set_id"] != null:
		result.emote_set_id = d["emote_set_id"];
	if d.has("format") && d["format"] != null:
		for value in d["format"]:
			result.format.append(value);
	if d.has("scale") && d["scale"] != null:
		for value in d["scale"]:
			result.scale.append(value);
	if d.has("theme_mode") && d["theme_mode"] != null:
		for value in d["theme_mode"]:
			result.theme_mode.append(value);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["name"] = name;
	if images != null:
		d["images"] = images.to_dict();
	d["tier"] = tier;
	d["emote_type"] = emote_type;
	d["emote_set_id"] = emote_set_id;
	d["format"] = [];
	if format != null:
		for value in format:
			d["format"].append(value);
	d["scale"] = [];
	if scale != null:
		for value in scale:
			d["scale"].append(value);
	d["theme_mode"] = [];
	if theme_mode != null:
		for value in theme_mode:
			d["theme_mode"].append(value);
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The image URLs for the emote. These image URLs always provide a static, non-animated emote image with a light background.      **NOTE:** You should use the templated URL in the `template` field to fetch the image instead of using these URLs.
class Images extends RefCounted:
	## A URL to the small version (28px x 28px) of the emote.
	var url_1x: String;
	## A URL to the medium version (56px x 56px) of the emote.
	var url_2x: String;
	## A URL to the large version (112px x 112px) of the emote.
	var url_4x: String;

	static func from_json(d: Dictionary) -> Images:
		var result = Images.new();
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
