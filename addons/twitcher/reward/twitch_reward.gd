@tool
@icon("res://addons/twitcher/assets/reward-icon.svg")
extends Resource

class_name TwitchReward

## The ID that uniquely identifies this custom reward.
@export var id: String

## Owner of this reward
@export var broadcaster_user: TwitchUser

## The title of the reward.
@export var title: String

## The prompt shown to the viewer when they redeem the reward if user input is required. See the `is_user_input_required` field.
@export var description: String

## The cost of the reward in Channel Points.
@export var cost: int = 1

## Readonly, there is no API on Twitch side to update. 28x28 A custom images for the reward. This field is **null** if the broadcaster didn’t upload images.
@export var image_1: Image
		
## Readonly, there is no API on Twitch side to update. 56x56 A custom images for the reward. This field is **null** if the broadcaster didn’t upload images.
@export var image_2: Image

## Readonly, there is no API on Twitch side to update. 112x112 A custom images for the reward. This field is **null** if the broadcaster didn’t upload images.
@export var image_4: Image

## Readonly, there is no API on Twitch side to update. 28x28 default images for the reward.
@export var default_image_1: CompressedTexture2D = preload("res://addons/twitcher/assets/default-1.png")
		
## Readonly, there is no API on Twitch side to update. 56x56 default images for the reward.
@export var default_image_2: CompressedTexture2D = preload("res://addons/twitcher/assets/default-2.png")

## Readonly, there is no API on Twitch side to update. 112x112 default images for the reward.
@export var default_image_4: CompressedTexture2D = preload("res://addons/twitcher/assets/default-4.png")

## The background color to use for the reward. The color is in Hex format (for example, #00E5CB).
@export var background_color: Color

## A Boolean value that determines whether the reward is enabled. Is **true** if enabled; otherwise, **false**. Disabled rewards aren’t shown to the user.
@export var is_enabled: bool

## A Boolean value that determines whether the user must enter information when they redeem the reward. Is **true** if the user is prompted.
@export var is_user_input_required: bool

## A Boolean value that determines whether the reward is currently paused. Is **true** if the reward is paused. Viewers can’t redeem paused rewards.
@export var is_paused: bool

## A Boolean value that determines whether redemptions should be set to FULFILLED status immediately when a reward is redeemed. If **false**, status is set to UNFULFILLED and follows the normal request queue process.
@export var should_redemptions_skip_request_queue: bool

## A Boolean value that determines whether to limit the maximum number of redemptions allowed per live stream (see the `max_per_stream` field). The default is **false**.
@export var is_max_per_stream_enabled: bool

## The maximum number of redemptions allowed per live stream. Applied only if `is_max_per_stream_enabled` is **true**. The minimum value is 1.
@export var max_per_stream: int

## A Boolean value that determines whether to limit the maximum number of redemptions allowed per user per stream (see the `max_per_user_per_stream` field). The default is **false**.
@export var is_max_per_user_per_stream_enabled: bool

## The maximum number of redemptions allowed per user per stream. Applied only if `is_max_per_user_per_stream_enabled` is **true**. The minimum value is 1.
@export var max_per_user_per_stream: int

## A Boolean value that determines whether to apply a cooldown period between redemptions (see the `global_cooldown_seconds` field for the duration of the cooldown period). The default is **false**.
@export var is_global_cooldown_enabled: bool

## The cooldown period, in seconds. Applied only if the `is_global_cooldown_enabled` field is **true**. The minimum value is 1; however, the minimum value is 60 for it to be shown in the Twitch UX.
@export var global_cooldown_seconds: int


func get_image1() -> Texture:
	if image_1: return ImageTexture.create_from_image(image_1)
	return default_image_1
	
	
func get_image2() -> Texture:
	if image_2: return ImageTexture.create_from_image(image_2)
	return default_image_2
	
	
func get_image4() -> Texture:
	if image_4: return ImageTexture.create_from_image(image_4)
	return default_image_4


## Needed for the EditorsUndo cause it only supports method references
func emit_changed() -> void:
	emit_changed()


#region Temporary

## A Boolean value that determines whether the reward is currently in stock. Is **true** if the reward is in stock. Viewers can’t redeem out of stock rewards.
var is_in_stock: bool
## The number of redemptions redeemed during the current live stream. The number counts against the `max_per_stream_setting` limit. This field is **null** if the broadcaster’s stream isn’t live or _max\_per\_stream\_setting_ isn’t enabled.
var redemptions_redeemed_current_stream: int
## The timestamp of when the cooldown period expires. Is **null** if the reward isn’t in a cooldown state. See the `global_cooldown_setting` field.
var cooldown_expires_at: String

#endregion
