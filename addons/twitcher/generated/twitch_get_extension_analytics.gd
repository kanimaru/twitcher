@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetExtensionAnalytics
	


## 
## #/components/schemas/GetExtensionAnalyticsResponse
class Response extends TwitchData:

	## A list of reports. The reports are returned in no particular order; however, the data within each report is in ascending order by date (newest first). The report contains one row of data per day of the reporting window; the report contains rows for only those days that the extension was used. The array is empty if there are no reports.
	@export var data: Array[TwitchExtensionAnalytics]:
		set(val): 
			data = val
			track_data(&"data", val)
	
	## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
	@export var pagination: ResponsePagination:
		set(val): 
			pagination = val
			track_data(&"pagination", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchExtensionAnalytics]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchExtensionAnalytics.from_json(value))
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


## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
## #/components/schemas/GetExtensionAnalyticsResponse/Pagination
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
	


## All optional parameters for TwitchAPI.get_extension_analytics
## #/components/schemas/GetExtensionAnalyticsOpt
class Opt extends TwitchData:

	## The extension's client ID. If specified, the response contains a report for the specified extension. If not specified, the response includes a report for each extension that the authenticated user owns.
	@export var extension_id: String:
		set(val): 
			extension_id = val
			track_data(&"extension_id", val)
	
	## The type of analytics report to get. Possible values are:  
	##   
	## * overview\_v2
	@export var type: String:
		set(val): 
			type = val
			track_data(&"type", val)
	
	## The reporting window's start date, in RFC3339 format. Set the time portion to zeroes (for example, 2021-10-22T00:00:00Z).  
	##   
	## The start date must be on or after January 31, 2018\. If you specify an earlier date, the API ignores it and uses January 31, 2018\. If you specify a start date, you must specify an end date. If you don't specify a start and end date, the report includes all available data since January 31, 2018.  
	##   
	## The report contains one row of data for each day in the reporting window.
	@export var started_at: String:
		set(val): 
			started_at = val
			track_data(&"started_at", val)
	
	## The reporting window's end date, in RFC3339 format. Set the time portion to zeroes (for example, 2021-10-27T00:00:00Z). The report is inclusive of the end date.  
	##   
	## Specify an end date only if you provide a start date. Because it can take up to two days for the data to be available, you must specify an end date that's earlier than today minus one to two days. If not, the API ignores your end date and uses an end date that is today minus one to two days.
	@export var ended_at: String:
		set(val): 
			ended_at = val
			track_data(&"ended_at", val)
	
	## The maximum number of report URLs to return per page in the response. The minimum page size is 1 URL per page and the maximum is 100 URLs per page. The default is 20.  
	##   
	## **NOTE**: While you may specify a maximum value of 100, the response will contain at most 20 URLs per page.
	@export var first: int:
		set(val): 
			first = val
			track_data(&"first", val)
	
	## The cursor used to get the next page of results. The **Pagination** object in the response contains the cursor’s value. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)  
	##   
	## This parameter is ignored if the _extension\_id_ parameter is set.
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
		if d.get("extension_id", null) != null:
			result.extension_id = d["extension_id"]
		if d.get("type", null) != null:
			result.type = d["type"]
		if d.get("started_at", null) != null:
			result.started_at = d["started_at"]
		if d.get("ended_at", null) != null:
			result.ended_at = d["ended_at"]
		if d.get("first", null) != null:
			result.first = d["first"]
		if d.get("after", null) != null:
			result.after = d["after"]
		return result
	