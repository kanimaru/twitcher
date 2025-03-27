@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetFollowedChannels
	


## 
## #/components/schemas/GetFollowedChannelsResponse
class Response extends TwitchData:

	## The list of broadcasters that the user follows. The list is in descending order by `followed_at` (with the most recently followed broadcaster first). The list is empty if the user doesn’t follow anyone.
	@export var data: Array[ResponseData]:
		set(val): 
			data = val
			track_data(&"data", val)
	
	## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read more](https://dev.twitch.tv/docs/api/guide#pagination).
	@export var pagination: ResponsePagination:
		set(val): 
			pagination = val
			track_data(&"pagination", val)
	
	## The total number of broadcasters that the user follows. As someone pages through the list, the number may change as the user follows or unfollows broadcasters.
	@export var total: int:
		set(val): 
			total = val
			track_data(&"total", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[ResponseData], _total: int) -> Response:
		var response: Response = Response.new()
		response.data = _data
		response.total = _total
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(ResponseData.from_json(value))
		if d.get("pagination", null) != null:
			result.pagination = ResponsePagination.from_json(d["pagination"])
		if d.get("total", null) != null:
			result.total = d["total"]
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
		total = response.total
	
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


## The list of broadcasters that the user follows. The list is in descending order by `followed_at` (with the most recently followed broadcaster first). The list is empty if the user doesn’t follow anyone.
## #/components/schemas/GetFollowedChannelsResponse/Data
class ResponseData extends TwitchData:

	## An ID that uniquely identifies the broadcaster that this user is following.
	@export var broadcaster_id: String:
		set(val): 
			broadcaster_id = val
			track_data(&"broadcaster_id", val)
	
	## The broadcaster’s login name.
	@export var broadcaster_login: String:
		set(val): 
			broadcaster_login = val
			track_data(&"broadcaster_login", val)
	
	## The broadcaster’s display name.
	@export var broadcaster_name: String:
		set(val): 
			broadcaster_name = val
			track_data(&"broadcaster_name", val)
	
	## The UTC timestamp when the user started following the broadcaster.
	@export var followed_at: String:
		set(val): 
			followed_at = val
			track_data(&"followed_at", val)
	
	
	
	## Constructor with all required fields.
	static func create(_broadcaster_id: String, _broadcaster_login: String, _broadcaster_name: String, _followed_at: String) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.broadcaster_id = _broadcaster_id
		response_data.broadcaster_login = _broadcaster_login
		response_data.broadcaster_name = _broadcaster_name
		response_data.followed_at = _followed_at
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("broadcaster_id", null) != null:
			result.broadcaster_id = d["broadcaster_id"]
		if d.get("broadcaster_login", null) != null:
			result.broadcaster_login = d["broadcaster_login"]
		if d.get("broadcaster_name", null) != null:
			result.broadcaster_name = d["broadcaster_name"]
		if d.get("followed_at", null) != null:
			result.followed_at = d["followed_at"]
		return result
	


## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read more](https://dev.twitch.tv/docs/api/guide#pagination).
## #/components/schemas/GetFollowedChannelsResponse/Pagination
class ResponsePagination extends TwitchData:

	## The cursor used to get the next page of results. Use the cursor to set the request’s _after_ query parameter.
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
	


## All optional parameters for TwitchAPI.get_followed_channels
## #/components/schemas/GetFollowedChannelsOpt
class Opt extends TwitchData:

	## A broadcaster’s ID. Use this parameter to see whether the user follows this broadcaster. If specified, the response contains this broadcaster if the user follows them. If not specified, the response contains all broadcasters that the user follows.
	@export var broadcaster_id: String:
		set(val): 
			broadcaster_id = val
			track_data(&"broadcaster_id", val)
	
	## The maximum number of items to return per page in the response. The minimum page size is 1 item per page and the maximum is 100\. The default is 20.
	@export var first: int:
		set(val): 
			first = val
			track_data(&"first", val)
	
	## The cursor used to get the next page of results. The **Pagination** object in the response contains the cursor’s value. [Read more](https://dev.twitch.tv/docs/api/guide#pagination).
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
		if d.get("broadcaster_id", null) != null:
			result.broadcaster_id = d["broadcaster_id"]
		if d.get("first", null) != null:
			result.first = d["first"]
		if d.get("after", null) != null:
			result.after = d["after"]
		return result
	