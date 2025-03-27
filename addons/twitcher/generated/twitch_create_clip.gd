@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCreateClip
	


## 
## #/components/schemas/CreateClipResponse
class Response extends TwitchData:

	## 
	@export var data: Array[ResponseData]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[ResponseData]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(ResponseData.from_json(value))
		return result
	


## 
## #/components/schemas/CreateClipResponse/Data
class ResponseData extends TwitchData:

	## A URL that you can use to edit the clip’s title, identify the part of the clip to publish, and publish the clip. [Learn More](https://help.twitch.tv/s/article/how-to-use-clips)  
	##   
	## The URL is valid for up to 24 hours or until the clip is published, whichever comes first.
	@export var edit_url: String:
		set(val): 
			edit_url = val
			track_data(&"edit_url", val)
	
	## An ID that uniquely identifies the clip.
	@export var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	
	
	## Constructor with all required fields.
	static func create(_edit_url: String, _id: String) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.edit_url = _edit_url
		response_data.id = _id
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("edit_url", null) != null:
			result.edit_url = d["edit_url"]
		if d.get("id", null) != null:
			result.id = d["id"]
		return result
	


## All optional parameters for TwitchAPI.create_clip
## #/components/schemas/CreateClipOpt
class Opt extends TwitchData:

	## A Boolean value that determines whether the API captures the clip at the moment the viewer requests it or after a delay. If **false** (default), Twitch captures the clip at the moment the viewer requests it (this is the same clip experience as the Twitch UX). If **true**, Twitch adds a delay before capturing the clip (this basically shifts the capture window to the right slightly).
	@export var has_delay: bool:
		set(val): 
			has_delay = val
			track_data(&"has_delay", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("has_delay", null) != null:
			result.has_delay = d["has_delay"]
		return result
	