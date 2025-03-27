@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateDropsEntitlements
	


## 
## #/components/schemas/UpdateDropsEntitlementsBody
class Body extends TwitchData:

	## A list of IDs that identify the entitlements to update. You may specify a maximum of 100 IDs.
	@export var entitlement_ids: Array[String]:
		set(val): 
			entitlement_ids = val
			track_data(&"entitlement_ids", val)
	
	## The fulfillment status to set the entitlements to. Possible values are:  
	##   
	## * CLAIMED — The user claimed the benefit.
	## * FULFILLED — The developer granted the benefit that the user claimed.
	@export var fulfillment_status: String:
		set(val): 
			fulfillment_status = val
			track_data(&"fulfillment_status", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create() -> Body:
		var body: Body = Body.new()
		return body
	
	
	static func from_json(d: Dictionary) -> Body:
		var result: Body = Body.new()
		if d.get("entitlement_ids", null) != null:
			for value in d["entitlement_ids"]:
				result.entitlement_ids.append(value)
		if d.get("fulfillment_status", null) != null:
			result.fulfillment_status = d["fulfillment_status"]
		return result
	


## 
## #/components/schemas/UpdateDropsEntitlementsResponse
class Response extends TwitchData:

	## A list that indicates which entitlements were successfully updated and those that weren’t.
	@export var data: Array[TwitchDropsEntitlementUpdated]:
		set(val): 
			data = val
			track_data(&"data", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchDropsEntitlementUpdated]) -> Response:
		var response: Response = Response.new()
		response.data = _data
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchDropsEntitlementUpdated.from_json(value))
		return result
	