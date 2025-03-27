@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetUserEmotes
	


## 
## #/components/schemas/GetUserEmotesResponse
class Response extends TwitchData:

	## 
	@export var data: Array[ResponseData]:
		set(val): 
			data = val
			track_data(&"data", val)
	
	## A templated URL. Uses the values from the _id_, _format_, _scale_, and _theme\_mode_ fields to replace the like-named placeholder strings in the templated URL to create a CDN (content delivery network) URL that you use to fetch the emote.   
	##   
	##  For information about what the template looks like and how to use it to fetch emotes, see [Emote CDN URL](https://dev.twitch.tv/docs/irc/emotes#cdn-template) format.
	@export var template: String:
		set(val): 
			template = val
			track_data(&"template", val)
	
	## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through.   
	##   
	##  For more information about pagination support, see [Twitch API Guide - Pagination](https://dev.twitch.tv/docs/api/guide#pagination).
	@export var pagination: ResponsePagination:
		set(val): 
			pagination = val
			track_data(&"pagination", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[ResponseData], _template: String) -> Response:
		var response: Response = Response.new()
		response.data = _data
		response.template = _template
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(ResponseData.from_json(value))
		if d.get("template", null) != null:
			result.template = d["template"]
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
		template = response.template
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


## 
## #/components/schemas/GetUserEmotesResponse/Data
class ResponseData extends TwitchData:

	## An ID that uniquely identifies this emote.
	@export var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The User ID of broadcaster whose channel is receiving the unban request.
	@export var name: String:
		set(val): 
			name = val
			track_data(&"name", val)
	
	## The type of emote. The possible values are:   
	##   
	## * **none** — No emote type was assigned to this emote.
	## * **bitstier** — A Bits tier emote.
	## * **follower** — A follower emote.
	## * **subscriptions** — A subscriber emote.
	## * **channelpoints** — An emote granted by using channel points.
	## * **rewards** — An emote granted to the user through a special event.
	## * **hypetrain** — An emote granted for participation in a Hype Train.
	## * **prime** — An emote granted for linking an Amazon Prime account.
	## * **turbo** — An emote granted for having Twitch Turbo.
	## * **smilies** — Emoticons supported by Twitch.
	## * **globals** — An emote accessible by everyone.
	## * **owl2019** — Emotes related to Overwatch League 2019.
	## * **twofactor** — Emotes granted by enabling two-factor authentication on an account.
	## * **limitedtime** — Emotes that were granted for only a limited time.
	@export var emote_type: String:
		set(val): 
			emote_type = val
			track_data(&"emote_type", val)
	
	## An ID that identifies the emote set that the emote belongs to.
	@export var emote_set_id: String:
		set(val): 
			emote_set_id = val
			track_data(&"emote_set_id", val)
	
	## The ID of the broadcaster who owns the emote.
	@export var owner_id: String:
		set(val): 
			owner_id = val
			track_data(&"owner_id", val)
	
	## The formats that the emote is available in. For example, if the emote is available only as a static PNG, the array contains only static. But if the emote is available as a static PNG and an animated GIF, the array contains static and animated.   
	##   
	## * **animated** — An animated GIF is available for this emote.
	## * **static** — A static PNG file is available for this emote.
	@export var format: Array[String]:
		set(val): 
			format = val
			track_data(&"format", val)
	
	## The sizes that the emote is available in. For example, if the emote is available in small and medium sizes, the array contains 1.0 and 2.0\.   
	##   
	## * **1.0** — A small version (28px x 28px) is available.
	## * **2.0** — A medium version (56px x 56px) is available.
	## * **3.0** — A large version (112px x 112px) is available.
	@export var scale: Array[String]:
		set(val): 
			scale = val
			track_data(&"scale", val)
	
	## The background themes that the emote is available in.   
	##   
	## * **dark**
	## * **light**
	@export var theme_mode: Array[String]:
		set(val): 
			theme_mode = val
			track_data(&"theme_mode", val)
	
	
	
	## Constructor with all required fields.
	static func create(_id: String, _name: String, _emote_type: String, _emote_set_id: String, _owner_id: String, _format: Array[String], _scale: Array[String], _theme_mode: Array[String]) -> ResponseData:
		var response_data: ResponseData = ResponseData.new()
		response_data.id = _id
		response_data.name = _name
		response_data.emote_type = _emote_type
		response_data.emote_set_id = _emote_set_id
		response_data.owner_id = _owner_id
		response_data.format = _format
		response_data.scale = _scale
		response_data.theme_mode = _theme_mode
		return response_data
	
	
	static func from_json(d: Dictionary) -> ResponseData:
		var result: ResponseData = ResponseData.new()
		if d.get("id", null) != null:
			result.id = d["id"]
		if d.get("name", null) != null:
			result.name = d["name"]
		if d.get("emote_type", null) != null:
			result.emote_type = d["emote_type"]
		if d.get("emote_set_id", null) != null:
			result.emote_set_id = d["emote_set_id"]
		if d.get("owner_id", null) != null:
			result.owner_id = d["owner_id"]
		if d.get("format", null) != null:
			for value in d["format"]:
				result.format.append(value)
		if d.get("scale", null) != null:
			for value in d["scale"]:
				result.scale.append(value)
		if d.get("theme_mode", null) != null:
			for value in d["theme_mode"]:
				result.theme_mode.append(value)
		return result
	


## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through.   
##   
##  For more information about pagination support, see [Twitch API Guide - Pagination](https://dev.twitch.tv/docs/api/guide#pagination).
## #/components/schemas/GetUserEmotesResponse/Pagination
class ResponsePagination extends TwitchData:

	## The cursor used to get the next page of results. Use the cursor to set the request’s after query parameter.
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
	


## All optional parameters for TwitchAPI.get_user_emotes
## #/components/schemas/GetUserEmotesOpt
class Opt extends TwitchData:

	## The cursor used to get the next page of results. The Pagination object in the response contains the cursor’s value.
	@export var after: String:
		set(val): 
			after = val
			track_data(&"after", val)
	
	## The User ID of a broadcaster you wish to get follower emotes of. Using this query parameter will guarantee inclusion of the broadcaster’s follower emotes in the response body.   
	##   
	## **Note:** If the user specified in `user_id` is subscribed to the broadcaster specified, their follower emotes will appear in the response body regardless if this query parameter is used.
	@export var broadcaster_id: String:
		set(val): 
			broadcaster_id = val
			track_data(&"broadcaster_id", val)
	
	
	
	## Constructor with all required fields.
	static func create() -> Opt:
		var opt: Opt = Opt.new()
		return opt
	
	
	static func from_json(d: Dictionary) -> Opt:
		var result: Opt = Opt.new()
		if d.get("after", null) != null:
			result.after = d["after"]
		if d.get("broadcaster_id", null) != null:
			result.broadcaster_id = d["broadcaster_id"]
		return result
	