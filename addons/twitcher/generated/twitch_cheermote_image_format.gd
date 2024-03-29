@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCheermoteImageFormat

## No description available
var _1: String;
## No description available
var _2: String;
## No description available
var _3: String;
## No description available
var _4: String;
## No description available
var _1_5: String;

static func from_json(d: Dictionary) -> TwitchCheermoteImageFormat:
	var result = TwitchCheermoteImageFormat.new();
	if d.has("1") && d["1"] != null:
		result._1 = d["1"];
	if d.has("2") && d["2"] != null:
		result._2 = d["2"];
	if d.has("3") && d["3"] != null:
		result._3 = d["3"];
	if d.has("4") && d["4"] != null:
		result._4 = d["4"];
	if d.has("1.5") && d["1.5"] != null:
		result._1_5 = d["1.5"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["1"] = _1;
	d["2"] = _2;
	d["3"] = _3;
	d["4"] = _4;
	d["1.5"] = _1_5;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

