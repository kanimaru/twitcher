@tool
extends RefCounted

class_name TwitchGame

## An ID that identifies the category or game.
var id: String;
## The category’s or game’s name.
var name: String;
## A URL to the category’s or game’s box art. You must replace the `{width}x{height}` placeholder with the size of image you want.
var box_art_url: String;
## The ID that [IGDB](https://www.igdb.com/) uses to identify this game. If the IGDB ID is not available to Twitch, this field is set to an empty string.
var igdb_id: String;

static func from_json(d: Dictionary) -> TwitchGame:
	var result = TwitchGame.new();
	result.id = d["id"];
	result.name = d["name"];
	result.box_art_url = d["box_art_url"];
	result.igdb_id = d["igdb_id"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["name"] = name;
	d["box_art_url"] = box_art_url;
	d["igdb_id"] = igdb_id;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

