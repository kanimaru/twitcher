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
