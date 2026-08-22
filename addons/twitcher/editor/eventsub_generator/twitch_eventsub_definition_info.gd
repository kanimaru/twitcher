@tool
extends RefCounted

## Holds one parsed row from the eventsub-subscription-types docs page - everything
## TwitchEventsubDefinition needs a static var for.
class_name TwitchEventsubDefinitionInfo

var enum_name: String
var value: String
var version: String
var conditions: Array[String] = []
var scopes: Array[String] = []
var documentation_link: String
## The generated_eventsub script this definition's response is loaded from, e.g. "channel_ad_break_begin".
## Filled in by TwitchEventsubDefinitionGenerator, not the parser.
var script_name: String
## True for a legacy alias definition (same subscription type, pointing at the pre-override,
## mechanically-derived script name) kept around so code already depending on it still works. Also
## filled in by TwitchEventsubDefinitionGenerator.
var is_obsolete: bool = false


func clone() -> TwitchEventsubDefinitionInfo:
	var copy: TwitchEventsubDefinitionInfo = TwitchEventsubDefinitionInfo.new()
	copy.enum_name = enum_name
	copy.value = value
	copy.version = version
	copy.conditions = conditions
	copy.scopes = scopes
	copy.documentation_link = documentation_link
	copy.script_name = script_name
	copy.is_obsolete = is_obsolete
	return copy
