@tool
extends RefCounted

## Data class for holding relevant information about a redemption
class_name TwitchRedemption

enum Status {
	UNKNOWN = 0, 
	UNFULFILLED = 1, 
	FULFILLED = 2, 
	CANCELED = 3
}

## The unique redemption id
var id: String

## The reward that was redeemed.
var reward: TwitchReward

## requested broadcaster ID.
var broadcaster: TwitchUser

## The user that redeemed the reward.
var user: TwitchUser

## The user input provided. Empty string if not provided.
var user_input: String

## Defaults to "unfulfilled". Possible values are "unknown", "unfulfilled", "fulfilled", and "canceled".
var status: Status

## RFC3339 timestamp of when the reward was redeemed.
var redeemed_at: String

# I could just give this object the TwitchRedeemListener but this would cause circular reference
# the TwitchRedeemListener creates this objects so this object shouldn't know about it

var _fullfill_callback: Callable
var _cancel_callback: Callable

## Send when the redemption was fullfilled either within the app or externally
signal fullfilled

## Send when the redemption was canceled either within the app or externally
signal cancelled


func _init(redemption_id: String, twitch_reward: TwitchReward, twitch_broadcaster: TwitchUser, twitch_user: TwitchUser): 
	id = redemption_id
	reward = twitch_reward
	broadcaster = twitch_broadcaster
	user = twitch_user


## Fullfill the redemption and remove the channel points
func fullfill() -> void:
	if not _fullfill_callback: printerr("Can't fullfill without callback")
	var success = await _fullfill_callback.call(id, reward, broadcaster.id)
	if success != null: notify_fullfilled()


## When the redeem got fullfilled
func notify_fullfilled() -> void:
	if status != Status.FULFILLED:
		status = Status.FULFILLED
		fullfilled.emit()
		
	
## Cancel the redemption and 
func cancel() -> void:
	if not _cancel_callback: printerr("Can't fullfill without callback")
	var success = await _cancel_callback.call(id, reward, broadcaster.id)
	if success != null: notify_cancelled()
	

## When the redeem got fullfilled
func notify_cancelled() -> void:
	if status != Status.CANCELED:
		status = Status.CANCELED
		cancelled.emit()
