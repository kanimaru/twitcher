@tool
extends RefCounted

class_name TwitchUserExtension

## An ID that identifies the extension.
var id: String;
## The extension's version.
var version: String;
## The extension's name.
var name: String;
## A Boolean value that determines whether the extension is configured and can be activated. Is **true** if the extension is configured and can be activated.
var can_activate: bool;
## The extension types that you can activate for this extension. Possible values are:      * component * mobile * overlay * panel
var type: Array[String];

static func from_json(d: Dictionary) -> TwitchUserExtension:
	var result = TwitchUserExtension.new();





	for value in d["type"]:
		result.type.append(value);
{elif property.is_typed_array}
	for value in d["type"]:
		result.type.append(.from_json(value));
{elif property.is_sub_class}
	result.type = Array[String].from_json(d["type"]);
{else}
	result.type = d["type"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};





	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

