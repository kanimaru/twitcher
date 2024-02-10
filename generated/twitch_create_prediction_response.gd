@tool
extends RefCounted

class_name TwitchCreatePredictionResponse

## A list that contains the single prediction that you created.
var data: Array[TwitchPrediction];

static func from_json(d: Dictionary) -> TwitchCreatePredictionResponse:
	var result = TwitchCreatePredictionResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

