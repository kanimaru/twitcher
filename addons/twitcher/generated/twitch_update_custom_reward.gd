@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateCustomReward
	


## 
## #/components/schemas/UpdateCustomRewardBody
class Body extends TwitchData:

	## The reward’s title. The title may contain a maximum of 45 characters and it must be unique amongst all of the broadcaster’s custom rewards.
	@export var title: String:
		set(val): 
			title = val
			track_data(&"title", val)
	
	## The prompt shown to the viewer when they redeem the reward. Specify a prompt if `is_user_input_required` is **true**. The prompt is limited to a maximum of 200 characters.
	@export var prompt: String:
		set(val): 
			prompt = val
			track_data(&"prompt", val)
	
	## The cost of the reward, in channel points. The minimum is 1 point.
	@export var cost: int:
		set(val): 
			cost = val
			track_data(&"cost", val)
	
	## The background color to use for the reward. Specify the color using Hex format (for example, \\#00E5CB).
	@export var background_color: String:
		set(val): 
			background_color = val
			track_data(&"background_color", val)
	
	## A Boolean value that indicates whether the reward is enabled. Set to **true** to enable the reward. Viewers see only enabled rewards.
	@export var is_enabled: bool:
		set(val): 
			is_enabled = val
			track_data(&"is_enabled", val)
	
	## A Boolean value that determines whether users must enter information to redeem the reward. Set to **true** if user input is required. See the `prompt` field.
	@export var is_user_input_required: bool:
		set(val): 
			is_user_input_required = val
			track_data(&"is_user_input_required", val)
	
	## A Boolean value that determines whether to limit the maximum number of redemptions allowed per live stream (see the `max_per_stream` field). Set to **true** to limit redemptions.
	@export var is_max_per_stream_enabled: bool:
		set(val): 
			is_max_per_stream_enabled = val
			track_data(&"is_max_per_stream_enabled", val)
	
	## The maximum number of redemptions allowed per live stream. Applied only if `is_max_per_stream_enabled` is **true**. The minimum value is 1.
	@export var max_per_stream: int:
		set(val): 
			max_per_stream = val
			track_data(&"max_per_stream", val)
	
	## A Boolean value that determines whether to limit the maximum number of redemptions allowed per user per stream (see `max_per_user_per_stream`). The minimum value is 1\. Set to **true** to limit redemptions.
	@export var is_max_per_user_per_stream_enabled: bool:
		set(val): 
			is_max_per_user_per_stream_enabled = val
			track_data(&"is_max_per_user_per_stream_enabled", val)
	
	## The maximum number of redemptions allowed per user per stream. Applied only if `is_max_per_user_per_stream_enabled` is **true**.
	@export var max_per_user_per_stream: int:
		set(val): 
			max_per_user_per_stream = val
			track_data(&"max_per_user_per_stream", val)
	
	## A Boolean value that determines whether to apply a cooldown period between redemptions. Set to **true** to apply a cooldown period. For the duration of the cooldown period, see `global_cooldown_seconds`.
	@export var is_global_cooldown_enabled: bool:
		set(val): 
			is_global_cooldown_enabled = val
			track_data(&"is_global_cooldown_enabled", val)
	
	## The cooldown period, in seconds. Applied only if `is_global_cooldown_enabled` is **true**. The minimum value is 1; however, for it to be shown in the Twitch UX, the minimum value is 60.
	@export var global_cooldown_seconds: int:
		set(val): 
			global_cooldown_seconds = val
			track_data(&"global_cooldown_seconds", val)
	
	## A Boolean value that determines whether to pause the reward. Set to **true** to pause the reward. Viewers can’t redeem paused rewards..
	@export var is_paused: bool:
		set(val): 
			is_paused = val
			track_data(&"is_paused", val)
	
	## A Boolean value that determines whether redemptions should be set to FULFILLED status immediately when a reward is redeemed. If **false**, status is set to UNFULFILLED and follows the normal request queue process.
	@export var should_redemptions_skip_request_queue: bool:
		set(val): 
			should_redemptions_skip_request_queue = val
			track_data(&"should_redemptions_skip_request_queue", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create() -> Body:
		var body: Body = Body.new()
		return body
	
	
	static func from_json(d: Dictionary) -> Body:
		var result: Body = Body.new()
		if d.get("title", null) != null:
			result.title = d["title"]
		if d.get("prompt", null) != null:
			result.prompt = d["prompt"]
		if d.get("cost", null) != null:
			result.cost = d["cost"]
		if d.get("background_color", null) != null:
			result.background_color = d["background_color"]
		if d.get("is_enabled", null) != null:
			result.is_enabled = d["is_enabled"]
		if d.get("is_user_input_required", null) != null:
			result.is_user_input_required = d["is_user_input_required"]
		if d.get("is_max_per_stream_enabled", null) != null:
			result.is_max_per_stream_enabled = d["is_max_per_stream_enabled"]
		if d.get("max_per_stream", null) != null:
			result.max_per_stream = d["max_per_stream"]
		if d.get("is_max_per_user_per_stream_enabled", null) != null:
			result.is_max_per_user_per_stream_enabled = d["is_max_per_user_per_stream_enabled"]
		if d.get("max_per_user_per_stream", null) != null:
			result.max_per_user_per_stream = d["max_per_user_per_stream"]
		if d.get("is_global_cooldown_enabled", null) != null:
			result.is_global_cooldown_enabled = d["is_global_cooldown_enabled"]
		if d.get("global_cooldown_seconds", null) != null:
			result.global_cooldown_seconds = d["global_cooldown_seconds"]
		if d.get("is_paused", null) != null:
			result.is_paused = d["is_paused"]
		if d.get("should_redemptions_skip_request_queue", null) != null:
			result.should_redemptions_skip_request_queue = d["should_redemptions_skip_request_queue"]
		return result
	


## 
## #/components/schemas/UpdateCustomRewardResponse
class Response extends TwitchData:

	## The list contains the single reward that you updated.
	@export var data: Array[TwitchCustomReward]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchCustomReward]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchCustomReward.from_json(value))
		return result
	