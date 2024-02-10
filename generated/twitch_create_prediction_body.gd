@tool
extends RefCounted

class_name TwitchCreatePredictionBody

## The ID of the broadcaster that’s running the prediction. This ID must match the user ID in the user access token.
var broadcaster_id: String;
## The question that the broadcaster is asking. For example, _Will I finish this entire pizza?_ The title is limited to a maximum of 45 characters.
var title: String;
## The list of possible outcomes that the viewers may choose from. The list must contain a minimum of 2 choices and up to a maximum of 10 choices.
var outcomes: Array;
## The length of time (in seconds) that the prediction will run for. The minimum is 30 seconds and the maximum is 1800 seconds (30 minutes).
var prediction_window: int;

static func from_json(d: Dictionary) -> TwitchCreatePredictionBody:
	var result = TwitchCreatePredictionBody.new();



	for value in d["outcomes"]:
		result.outcomes.append(value);
{elif property.is_typed_array}
	for value in d["outcomes"]:
		result.outcomes.append(.from_json(value));
{elif property.is_sub_class}
	result.outcomes = Array.from_json(d["outcomes"]);
{else}
	result.outcomes = d["outcomes"];


	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};




	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

