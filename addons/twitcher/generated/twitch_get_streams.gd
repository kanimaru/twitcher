@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetStreams
	


## 
## #/components/schemas/GetStreamsResponse
class Response extends TwitchData:

	## The list of streams.
	var data: Array[TwitchStream]:
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
	static func create(_data: Array[TwitchStream]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchStream.from_json(value))
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
## #/components/schemas/GetStreamsResponse/Pagination
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
	


## All optional parameters for TwitchAPI.get_streams
## #/components/schemas/GetStreamsOpt
class Opt extends TwitchData:

	## A user ID used to filter the list of streams. Returns only the streams of those users that are broadcasting. You may specify a maximum of 100 IDs. To specify multiple IDs, include the _user\_id_ parameter for each user. For example, `&user_id=1234&user_id=5678`.
	var user_id: Array[String]:
		set(val): 
			user_id = val
			track_data(&"user_id", val)
	
	## A user login name used to filter the list of streams. Returns only the streams of those users that are broadcasting. You may specify a maximum of 100 login names. To specify multiple names, include the _user\_login_ parameter for each user. For example, `&user_login=foo&user_login=bar`.
	var user_login: Array[String]:
		set(val): 
			user_login = val
			track_data(&"user_login", val)
	
	## A game (category) ID used to filter the list of streams. Returns only the streams that are broadcasting the game (category). You may specify a maximum of 100 IDs. To specify multiple IDs, include the _game\_id_ parameter for each game. For example, `&game_id=9876&game_id=5432`.
	var game_id: Array[String]:
		set(val): 
			game_id = val
			track_data(&"game_id", val)
	
	## The type of stream to filter the list of streams by. Possible values are:  
	##   
	## * all
	## * live
	##   
	## The default is _all_.
	var type: String:
		set(val): 
			type = val
			track_data(&"type", val)
	
	## A language code used to filter the list of streams. Returns only streams that broadcast in the specified language. Specify the language using an ISO 639-1 two-letter language code or _other_ if the broadcast uses a language not in the list of [supported stream languages](https://help.twitch.tv/s/article/languages-on-twitch#streamlang).  
	##   
	## You may specify a maximum of 100 language codes. To specify multiple languages, include the _language_ parameter for each language. For example, `&language=de&language=fr`.
	var language: Array[String]:
		set(val): 
			language = val
			track_data(&"language", val)
	
	## The maximum number of items to return per page in the response. The minimum page size is 1 item per page and the maximum is 100 items per page. The default is 20.
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
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("user_id", null) != null:
			for value in d["user_id"]:
				result.user_id.append(value)
		if d.get("user_login", null) != null:
			for value in d["user_login"]:
				result.user_login.append(value)
		if d.get("game_id", null) != null:
			for value in d["game_id"]:
				result.game_id.append(value)
		if d.get("type", null) != null:
			result.type = d["type"]
		if d.get("language", null) != null:
			for value in d["language"]:
				result.language.append(value)
		if d.get("first", null) != null:
			result.first = d["first"]
		if d.get("before", null) != null:
			result.before = d["before"]
		if d.get("after", null) != null:
			result.after = d["after"]
		return result
	