@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/ExtensionSecret
class_name TwitchExtensionSecret
	
## The version number that identifies this definition of the secret’s data.
var format_version: int:
	set(val): 
		format_version = val
		track_data(&"format_version", val)

## The list of secrets.
var secrets: Array[Secrets]:
	set(val): 
		secrets = val
		track_data(&"secrets", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_format_version: int, _secrets: Array[Secrets]) -> TwitchExtensionSecret:
	var twitch_extension_secret: TwitchExtensionSecret = TwitchExtensionSecret.new()
	twitch_extension_secret.format_version = _format_version
	twitch_extension_secret.secrets = _secrets
	return twitch_extension_secret


static func from_json(d: Dictionary) -> TwitchExtensionSecret:
	var result: TwitchExtensionSecret = TwitchExtensionSecret.new()
	if d.get("format_version", null) != null:
		result.format_version = d["format_version"]
	if d.get("secrets", null) != null:
		for value in d["secrets"]:
			result.secrets.append(Secrets.from_json(value))
	return result



## The list of secrets.
## #/components/schemas/ExtensionSecret/Secrets
class Secrets extends TwitchData:

	## The raw secret that you use with JWT encoding.
	var content: String:
		set(val): 
			content = val
			track_data(&"content", val)
	
	## The UTC date and time (in RFC3339 format) that you may begin using this secret to sign a JWT.
	var active_at: Variant:
		set(val): 
			active_at = val
			track_data(&"active_at", val)
	
	## The UTC date and time (in RFC3339 format) that you must stop using this secret to decode a JWT.
	var expires_at: Variant:
		set(val): 
			expires_at = val
			track_data(&"expires_at", val)
	
	
	
	## Constructor with all required fields.
	static func create(_content: String, _active_at: Variant, _expires_at: Variant) -> Secrets:
		var secrets: Secrets = Secrets.new()
		secrets.content = _content
		secrets.active_at = _active_at
		secrets.expires_at = _expires_at
		return secrets
	
	
	static func from_json(d: Dictionary) -> Secrets:
		var result: Secrets = Secrets.new()
		if d.get("content", null) != null:
			result.content = d["content"]
		if d.get("active_at", null) != null:
			result.active_at = d["active_at"]
		if d.get("expires_at", null) != null:
			result.expires_at = d["expires_at"]
		return result
	