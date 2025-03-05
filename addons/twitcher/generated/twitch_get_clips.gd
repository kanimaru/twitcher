@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetClips
	


## 
## #/components/schemas/GetClipsResponse
class Response extends TwitchData:

	## The list of video clips. For clips returned by _game\_id_ or _broadcaster\_id_, the list is in descending order by view count. For lists returned by _id_, the list is in the same order as the input IDs.
	var data: Array[TwitchClip]:
		set(val): 
			data = val
			track_data(&"data", val)
	
	## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
	var pagination: ResponsePagination:
		set(val): 
			pagination = val
			track_data(&"pagination", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchClip]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchClip.from_json(value))
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
		return data.size() > 0
		
		
	func _iter_next(iter: Array) -> bool:
		if data.size() - 1 > _cur_iter:
			_cur_iter += 1
			iter[0] = data[_cur_iter]
		if data.size() - 1 == _cur_iter && not _has_pagination(): 
			return false
		return true
		
		
	func _iter_get(iter: Variant) -> Variant:
		if data.size() - 1 == _cur_iter && _has_pagination():
			await next_page()
		return iter


## The information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
## #/components/schemas/GetClipsResponse/Pagination
class ResponsePagination extends TwitchData:

	## The cursor used to get the next page of results. Set the request’s _after_ or _before_ query parameter to this value depending on whether you’re paging forwards or backwards.
	var cursor: String:
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
	


## All optional parameters for TwitchAPI.get_clips
## #/components/schemas/GetClipsOpt
class Opt extends TwitchData:

	## An ID that identifies the broadcaster whose video clips you want to get. Use this parameter to get clips that were captured from the broadcaster’s streams.
	var broadcaster_id: String:
		set(val): 
			broadcaster_id = val
			track_data(&"broadcaster_id", val)
	
	## An ID that identifies the game whose clips you want to get. Use this parameter to get clips that were captured from streams that were playing this game.
	var game_id: String:
		set(val): 
			game_id = val
			track_data(&"game_id", val)
	
	## An ID that identifies the clip to get. To specify more than one ID, include this parameter for each clip you want to get. For example, `id=foo&id=bar`. You may specify a maximum of 100 IDs. The API ignores duplicate IDs and IDs that aren’t found.
	var id: Array[String]:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The start date used to filter clips. The API returns only clips within the start and end date window. Specify the date and time in RFC3339 format.
	var started_at: Variant:
		set(val): 
			started_at = val
			track_data(&"started_at", val)
	
	## The end date used to filter clips. If not specified, the time window is the start date plus one week. Specify the date and time in RFC3339 format.
	var ended_at: Variant:
		set(val): 
			ended_at = val
			track_data(&"ended_at", val)
	
	## The maximum number of clips to return per page in the response. The minimum page size is 1 clip per page and the maximum is 100\. The default is 20.
	var first: int:
		set(val): 
			first = val
			track_data(&"first", val)
	
	## The cursor used to get the previous page of results. The **Pagination** object in the response contains the cursor’s value. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
	var before: String:
		set(val): 
			before = val
			track_data(&"before", val)
	
	## The cursor used to get the next page of results. The **Pagination** object in the response contains the cursor’s value. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
	var after: String:
		set(val): 
			after = val
			track_data(&"after", val)
	
	## A Boolean value that determines whether the response includes featured clips. If **true**, returns only clips that are featured. If **false**, returns only clips that aren’t featured. All clips are returned if this parameter is not present.
	var is_featured: bool:
		set(val): 
			is_featured = val
			track_data(&"is_featured", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("broadcaster_id", null) != null:
			result.broadcaster_id = d["broadcaster_id"]
		if d.get("game_id", null) != null:
			result.game_id = d["game_id"]
		if d.get("id", null) != null:
			for value in d["id"]:
				result.id.append(value)
		if d.get("started_at", null) != null:
			result.started_at = d["started_at"]
		if d.get("ended_at", null) != null:
			result.ended_at = d["ended_at"]
		if d.get("first", null) != null:
			result.first = d["first"]
		if d.get("before", null) != null:
			result.before = d["before"]
		if d.get("after", null) != null:
			result.after = d["after"]
		if d.get("is_featured", null) != null:
			result.is_featured = d["is_featured"]
		return result
	