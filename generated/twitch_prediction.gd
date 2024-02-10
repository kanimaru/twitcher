@tool
extends RefCounted

class_name TwitchPrediction

## An ID that identifies this prediction.
var id: String;
## An ID that identifies the broadcaster that created the prediction.
var broadcaster_id: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The question that the prediction asks. For example, _Will I finish this entire pizza?_
var title: String;
## The ID of the winning outcome. Is **null** unless `status` is RESOLVED.
var winning_outcome_id: String;
## The list of possible outcomes for the prediction.
var outcomes: Array[TwitchPredictionOutcome];
## The length of time (in seconds) that the prediction will run for.
var prediction_window: int;
## The prediction’s status. Valid values are:      * ACTIVE — The Prediction is running and viewers can make predictions. * CANCELED — The broadcaster canceled the Prediction and refunded the Channel Points to the participants. * LOCKED — The broadcaster locked the Prediction, which means viewers can no longer make predictions. * RESOLVED — The winning outcome was determined and the Channel Points were distributed to the viewers who predicted the correct outcome.
var status: String;
## The UTC date and time of when the Prediction began.
var created_at: Variant;
## The UTC date and time of when the Prediction ended. If `status` is ACTIVE, this is set to **null**.
var ended_at: Variant;
## The UTC date and time of when the Prediction was locked. If `status` is not LOCKED, this is set to **null**.
var locked_at: Variant;

static func from_json(d: Dictionary) -> TwitchPrediction:
	var result = TwitchPrediction.new();












	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};












	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

