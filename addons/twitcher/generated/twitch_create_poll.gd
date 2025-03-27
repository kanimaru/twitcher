@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCreatePoll
	


## 
## #/components/schemas/CreatePollBody
class Body extends TwitchData:

	## The ID of the broadcaster that’s running the poll. This ID must match the user ID in the user access token.
	@export var broadcaster_id: String:
		set(val): 
			broadcaster_id = val
			track_data(&"broadcaster_id", val)
	
	## The question that viewers will vote on. For example, _What game should I play next?_ The question may contain a maximum of 60 characters.
	@export var title: String:
		set(val): 
			title = val
			track_data(&"title", val)
	
	## A list of choices that viewers may choose from. The list must contain a minimum of 2 choices and up to a maximum of 5 choices.
	@export var choices: Array[BodyChoices]:
		set(val): 
			choices = val
			track_data(&"choices", val)
	
	## The length of time (in seconds) that the poll will run for. The minimum is 15 seconds and the maximum is 1800 seconds (30 minutes).
	@export var duration: int:
		set(val): 
			duration = val
			track_data(&"duration", val)
	
	## A Boolean value that indicates whether viewers may cast additional votes using Channel Points. If **true**, the viewer may cast more than one vote but each additional vote costs the number of Channel Points specified in `channel_points_per_vote`. The default is **false** (viewers may cast only one vote). For information about Channel Points, see [Channel Points Guide](https://help.twitch.tv/s/article/channel-points-guide).
	@export var channel_points_voting_enabled: bool:
		set(val): 
			channel_points_voting_enabled = val
			track_data(&"channel_points_voting_enabled", val)
	
	## The number of points that the viewer must spend to cast one additional vote. The minimum is 1 and the maximum is 1000000\. Set only if `ChannelPointsVotingEnabled` is **true**.
	@export var channel_points_per_vote: int:
		set(val): 
			channel_points_per_vote = val
			track_data(&"channel_points_per_vote", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_broadcaster_id: String, _title: String, _choices: Array[BodyChoices], _duration: int) -> Body:
		var body: Body = Body.new()
		body.broadcaster_id = _broadcaster_id
		body.title = _title
		body.choices = _choices
		body.duration = _duration
		return body
	
	
	static func from_json(d: Dictionary) -> Body:
		var result: Body = Body.new()
		if d.get("broadcaster_id", null) != null:
			result.broadcaster_id = d["broadcaster_id"]
		if d.get("title", null) != null:
			result.title = d["title"]
		if d.get("choices", null) != null:
			for value in d["choices"]:
				result.choices.append(BodyChoices.from_json(value))
		if d.get("duration", null) != null:
			result.duration = d["duration"]
		if d.get("channel_points_voting_enabled", null) != null:
			result.channel_points_voting_enabled = d["channel_points_voting_enabled"]
		if d.get("channel_points_per_vote", null) != null:
			result.channel_points_per_vote = d["channel_points_per_vote"]
		return result
	


## A list of choices that viewers may choose from. The list must contain a minimum of 2 choices and up to a maximum of 5 choices.
## #/components/schemas/CreatePollBody/Choices
class BodyChoices extends TwitchData:

	## One of the choices the viewer may select. The choice may contain a maximum of 25 characters.
	@export var title: String:
		set(val): 
			title = val
			track_data(&"title", val)
	
	
	
	## Constructor with all required fields.
	static func create(_title: String) -> BodyChoices:
		var body_choices: BodyChoices = BodyChoices.new()
		body_choices.title = _title
		return body_choices
	
	
	static func from_json(d: Dictionary) -> BodyChoices:
		var result: BodyChoices = BodyChoices.new()
		if d.get("title", null) != null:
			result.title = d["title"]
		return result
	


## 
## #/components/schemas/CreatePollResponse
class Response extends TwitchData:

	## A list that contains the single poll that you created.
	@export var data: Array[TwitchPoll]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchPoll]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchPoll.from_json(value))
		return result
	