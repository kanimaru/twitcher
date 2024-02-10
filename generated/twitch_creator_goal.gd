@tool
extends RefCounted

class_name TwitchCreatorGoal

## An ID that identifies this goal.
var id: String;
## An ID that identifies the broadcaster that created the goal.
var broadcaster_id: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The type of goal. Possible values are:       * follower — The goal is to increase followers. * subscription — The goal is to increase subscriptions. This type shows the net increase or decrease in tier points associated with the subscriptions. * subscription\_count — The goal is to increase subscriptions. This type shows the net increase or decrease in the number of subscriptions. * new\_subscription — The goal is to increase subscriptions. This type shows only the net increase in tier points associated with the subscriptions (it does not account for users that unsubscribed since the goal started). * new\_subscription\_count — The goal is to increase subscriptions. This type shows only the net increase in the number of subscriptions (it does not account for users that unsubscribed since the goal started).
var type: String;
## A description of the goal. Is an empty string if not specified.
var description: String;
## The goal’s current value.      The goal’s `type` determines how this value is increased or decreased.       * If `type` is follower, this field is set to the broadcaster's current number of followers. This number increases with new followers and decreases when users unfollow the broadcaster. * If `type` is subscription, this field is increased and decreased by the points value associated with the subscription tier. For example, if a tier-two subscription is worth 2 points, this field is increased or decreased by 2, not 1. * If `type` is subscription\_count, this field is increased by 1 for each new subscription and decreased by 1 for each user that unsubscribes. * If `type` is new\_subscription, this field is increased by the points value associated with the subscription tier. For example, if a tier-two subscription is worth 2 points, this field is increased by 2, not 1. * If `type` is new\_subscription\_count, this field is increased by 1 for each new subscription.
var current_amount: int;
## The goal’s target value. For example, if the broadcaster has 200 followers before creating the goal, and their goal is to double that number, this field is set to 400.
var target_amount: int;
## The UTC date and time (in RFC3339 format) that the broadcaster created the goal.
var created_at: Variant;

static func from_json(d: Dictionary) -> TwitchCreatorGoal:
	var result = TwitchCreatorGoal.new();









	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};









	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

