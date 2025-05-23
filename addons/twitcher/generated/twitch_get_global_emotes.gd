@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetGlobalEmotes
	


## 
## #/components/schemas/GetGlobalEmotesResponse
class Response extends TwitchData:

	## The list of global emotes.
	@export var data: Array[TwitchGlobalEmote]:
		set(val): 
			data = val
			track_data(&"data", val)
	
	## A templated URL. Use the values from the `id`, `format`, `scale`, and `theme_mode` fields to replace the like-named placeholder strings in the templated URL to create a CDN (content delivery network) URL that you use to fetch the emote. For information about what the template looks like and how to use it to fetch emotes, see [Emote CDN URL format](https://dev.twitch.tv/docs/irc/emotes#cdn-template). You should use this template instead of using the URLs in the `images` object.
	@export var template: String:
		set(val): 
			template = val
			track_data(&"template", val)
	var response: BufferedHTTPClient.ResponseData
	
	
	## Constructor with all required fields.
	static func create(_data: Array[TwitchGlobalEmote], _template: String) -> Response:
		var response: Response = Response.new()
		response.data = _data
		response.template = _template
		return response
	
	
	static func from_json(d: Dictionary) -> Response:
		var result: Response = Response.new()
		if d.get("data", null) != null:
			for value in d["data"]:
				result.data.append(TwitchGlobalEmote.from_json(value))
		if d.get("template", null) != null:
			result.template = d["template"]
		return result
	