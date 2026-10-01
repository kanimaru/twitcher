@tool
class_name LogfamiRedactionRule
extends RefCounted
## One regular expression whose matches [LogfamiRedactor] replaces.
##
## [member replacement] may reference capture groups ([code]$1[/code]) to keep
## the part that tells the reader what was hidden:
## [codeblock]
## LogfamiRedactionRule.new("api_key", "(api_key=)\\S+", "$1[REDACTED]")
## [/codeblock]

## Shown in tests and debugging, has no effect on matching.
var name: String
var pattern: RegEx
var replacement: String


func _init(rule_name: String, regex_pattern: String, rule_replacement: String) -> void:
	name = rule_name
	pattern = RegEx.create_from_string(regex_pattern)
	replacement = rule_replacement


func is_valid() -> bool:
	return pattern != null and pattern.is_valid()


## Replaces every match in [param text]. Invalid rules return it unchanged.
func apply(text: String) -> String:
	if not is_valid():
		return text
	return pattern.sub(text, replacement, true)
