@tool
extends RefCounted

class_name TwitchCheermoteImageFormat

## No description available
var 1: String;
## No description available
var 2: String;
## No description available
var 3: String;
## No description available
var 4: String;
## No description available
var 1.5: String;

static func from_json(d: Dictionary) -> TwitchCheermoteImageFormat:
	var result = TwitchCheermoteImageFormat.new();
	result.1 = d["1"];
	result.2 = d["2"];
	result.3 = d["3"];
	result.4 = d["4"];
	result.1.5 = d["1.5"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["1"] = 1;
	d["2"] = 2;
	d["3"] = 3;
	d["4"] = 4;
	d["1.5"] = 1.5;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

