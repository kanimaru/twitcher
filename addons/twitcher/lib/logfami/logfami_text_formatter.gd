@tool
class_name LogfamiTextFormatter
extends LogfamiFormatter
## Human readable lines, meant for log files people send in for support:
## [codeblock]
## # session.start 2025-09-29T09:59:59.000Z service.name=MyGame
## 2025-09-29T10:00:00.123Z INFO  [Shop#eu] Item bought {id=42}
## [/codeblock]
## Control characters are escaped, so every record stays on one line.

const HEADER_PREFIX: String = "# session.start"

## Attribute shown after the scope as [code]#value[/code] instead of in the
## attribute list. Empty to show every attribute in the list.
var instance_attribute: String = "instance"


func format(record: LogfamiRecord, _resource: LogfamiResource) -> String:
	var attributes: Dictionary = record.attributes.duplicate()
	var scope: String = record.scope
	if instance_attribute != "" and attributes.has(instance_attribute):
		scope += "#" + str(attributes[instance_attribute])
		attributes.erase(instance_attribute)

	var tail: PackedStringArray = []
	if scope != "":
		tail.append("[%s]" % scope)
	if record.body != "":
		tail.append(record.body)
	if not attributes.is_empty():
		tail.append("{%s}" % ", ".join(_pairs(attributes)))

	var line: String = "%s %s" % [LogfamiTime.rfc3339(record.time_unix_ms), _level(record)]
	if not tail.is_empty():
		line += " " + " ".join(tail)
	return LogfamiEscaper.escape_control(line)


func header(resource: LogfamiResource, started_unix_ms: int) -> PackedStringArray:
	var line: String = "%s %s" % [HEADER_PREFIX, LogfamiTime.rfc3339(started_unix_ms)]
	if not resource.attributes.is_empty():
		line += " " + " ".join(_pairs(resource.attributes))
	return PackedStringArray([LogfamiEscaper.escape_control(line)])


func _level(record: LogfamiRecord) -> String:
	var text: String = record.severity_text
	if text == "":
		text = str(record.severity_number)
	return text.rpad(5)


func _pairs(values: Dictionary) -> PackedStringArray:
	var keys: Array = values.keys()
	keys.sort()
	var pairs: PackedStringArray = []
	for key: Variant in keys:
		pairs.append("%s=%s" % [key, values[key]])
	return pairs
