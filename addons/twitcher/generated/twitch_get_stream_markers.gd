@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetStreamMarkers
	


## 
## #/components/schemas/GetStreamMarkersResponse
class Response extends TwitchData:

	## The list of markers grouped by the user that created the marks.
	@export var data: Array[TwitchStreamMarkers]:
		set(val): 
			data = val
			track_data(&"data", val)
	
	## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
	@export var pagination: ResponsePagination:
		set(val): 
			pagination = val
			track_data(&"pagination", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchStreamMarkers]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchStreamMarkers.from_json(value))
		if d.get("pagination", null) != null:
			result.pagination = ResponsePagination.from_json(d["pagination"])
		return result
	
	
	
	func _has_pagination() -> bool:
		if pagination == null: return false
		if pagination.cursor == null || pagination.cursor == "": return false
		return true
	
	var _next_page: Callable
	var _cur_iter: int = 0
	
	
	func next_page() -> Response:
		var response: Response = await _next_page.call()
		_cur_iter = 0
		_next_page = response._next_page
		data = response.data
		pagination = response.pagination
	
		return response
	
	
	func _iter_init(iter: Array) -> bool:
		if data.is_empty(): return false
		iter[0] = data[0]
		_cur_iter = 1
		return true
		
		
	func _iter_next(iter: Array) -> bool:
		if data.size() > _cur_iter:
			iter[0] = data[_cur_iter]
			_cur_iter += 1
		elif not _has_pagination(): 
			return false
		return true
		
		
	func _iter_get(iter: Variant) -> Variant:
		if data.size() - 1 == _cur_iter && _has_pagination():
			await next_page()
		return iter


## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
## #/components/schemas/GetStreamMarkersResponse/Pagination
class ResponsePagination extends TwitchData:

	## The cursor used to get the next page of results. Set the request’s _after_ or _before_ query parameter to this value depending on whether you’re paging forwards or backwards.
	@export var cursor: String:
		set(val): 
			cursor = val
			track_data(&"cursor", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> ResponsePagination:
		var response_pagination: ResponsePagination = ResponsePagination.new()
		return response_pagination
	
	
	static func from_json(d: Dictionary) -> ResponsePagination:
		var result: ResponsePagination = ResponsePagination.new()
		if d.get("cursor", null) != null:
			result.cursor = d["cursor"]
		return result
	


## All optional parameters for TwitchAPI.get_stream_markers
## #/components/schemas/GetStreamMarkersOpt
class Opt extends TwitchData:

	## A user ID. The request returns the markers from this user’s most recent video. This ID must match the user ID in the access token or the user in the access token must be one of the broadcaster’s editors.  
	##   
	## This parameter and the _video\_id_ query parameter are mutually exclusive.
	@export var user_id: String:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	## A video on demand (VOD)/video ID. The request returns the markers from this VOD/video. The user in the access token must own the video or the user must be one of the broadcaster’s editors.  
	##   
	## This parameter and the _user\_id_ query parameter are mutually exclusive.
	@export var video_id: String:
		set(val): 
			video_id = val
			track_data(&"video_id", val)
	
	## The maximum number of items to return per page in the response. The minimum page size is 1 item per page and the maximum is 100 items per page. The default is 20.
	@export var first: String:
		set(val): 
			first = val
			track_data(&"first", val)
	
	## The cursor used to get the previous page of results. The **Pagination** object in the response contains the cursor’s value. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
	@export var before: String:
		set(val): 
			before = val
			track_data(&"before", val)
	
	## The cursor used to get the next page of results. The **Pagination** object in the response contains the cursor’s value. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
	@export var after: String:
		set(val): 
			after = val
			track_data(&"after", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("user_id", null) != null:
			result.user_id = d["user_id"]
		if d.get("video_id", null) != null:
			result.video_id = d["video_id"]
		if d.get("first", null) != null:
			result.first = d["first"]
		if d.get("before", null) != null:
			result.before = d["before"]
		if d.get("after", null) != null:
			result.after = d["after"]
		return result
	