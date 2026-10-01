@tool
class_name LogfamiValue
extends RefCounted
## Renders attribute and resource values the same way in every format.
##
## Containers become compact JSON with sorted keys, so a nested attribute reads
## identically in a text, logfmt or JSON Lines line and can be parsed back.
## Everything else is converted with [method @GlobalScope.str].


## [param value] as one line of text.
static func to_text(value: Variant) -> String:
	if value is Dictionary or value is Array:
		return JSON.stringify(sorted(value), "", false)
	return str(value)


## Deep copy of [param value] with dictionary keys in sorted order, recursively
## through nested dictionaries and arrays, so output is deterministic.
static func sorted(value: Variant) -> Variant:
	if value is Dictionary:
		var source: Dictionary = value
		var keys: Array = source.keys()
		keys.sort()
		var result: Dictionary = {}
		for key: Variant in keys:
			result[key] = sorted(source[key])
		return result
	if value is Array:
		var items: Array = []
		for item: Variant in value:
			items.append(sorted(item))
		return items
	return value
