@tool
extends RefCounted

class_name TwitchPredictionOutcome

## An ID that identifies this outcome.
var id: String;
## The outcome’s text.
var title: String;
## The number of unique viewers that chose this outcome.
var users: int;
## The number of Channel Points spent by viewers on this outcome.
var channel_points: int;
## A list of viewers who were the top predictors; otherwise, **null** if none.
var top_predictors: Array;
## The color that visually identifies this outcome in the UX. Possible values are:      * BLUE * PINK    If the number of outcomes is two, the color is BLUE for the first outcome and PINK for the second outcome. If there are more than two outcomes, the color is BLUE for all outcomes.
var color: String;

static func from_json(d: Dictionary) -> TwitchPredictionOutcome:
	var result = TwitchPredictionOutcome.new();





	for value in d["top_predictors"]:
		result.top_predictors.append(value);
{elif property.is_typed_array}
	for value in d["top_predictors"]:
		result.top_predictors.append(.from_json(value));
{elif property.is_sub_class}
	result.top_predictors = Array.from_json(d["top_predictors"]);
{else}
	result.top_predictors = d["top_predictors"];


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};






	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

