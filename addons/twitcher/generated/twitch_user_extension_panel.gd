@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/UserExtensionPanel
class_name TwitchUserExtensionPanel
	
## A Boolean value that determines the extension’s activation state. If **false**, the user has not configured a panel extension.
var active: bool:
	set(val): 
		active = val
		track_data(&"active", val)

## An ID that identifies the extension.
var id: String:
	set(val): 
		id = val
		track_data(&"id", val)

## The extension’s version.
var version: String:
	set(val): 
		version = val
		track_data(&"version", val)

## The extension’s name.
var name: String:
	set(val): 
		name = val
		track_data(&"name", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_active: bool) -> TwitchUserExtensionPanel:
	var twitch_user_extension_panel: TwitchUserExtensionPanel = TwitchUserExtensionPanel.new()
	twitch_user_extension_panel.active = _active
	return twitch_user_extension_panel


static func from_json(d: Dictionary) -> TwitchUserExtensionPanel:
	var result: TwitchUserExtensionPanel = TwitchUserExtensionPanel.new()
	if d.get("active", null) != null:
		result.active = d["active"]
	if d.get("id", null) != null:
		result.id = d["id"]
	if d.get("version", null) != null:
		result.version = d["version"]
	if d.get("name", null) != null:
		result.name = d["name"]
	return result
