@tool
class_name LogfamiJsonLinesFormatter
extends LogfamiFormatter
## One JSON object per line (JSON Lines), with OpenTelemetry field names:
## [codeblock]
## {"timestamp":"2025-09-29T10:00:00.123Z","severity_text":"INFO","severity_number":9,
##  "scope":"Shop","body":"Item bought","attributes":{"id":42}}
## [/codeblock]
## (shown wrapped here; every record is a single line). The session header is a
## [code]session.start[/code] record that carries the resource.

const HEADER_SCOPE: String = "logfami"
const HEADER_BODY: String = "session.start"

## Adds the resource to every line. Collectors reading stdout of many
## processes need it per line; files only need it in the header.
var include_resource: bool = false


func format(record: LogfamiRecord, resource: LogfamiResource) -> String:
	var data: Dictionary = _base(
			record.time_unix_ms, record.severity_text, record.severity_number,
			record.scope, record.body, record.attributes)
	if include_resource:
		data["resource"] = _sorted(resource.attributes)
	return JSON.stringify(data, "", false)


func header(resource: LogfamiResource, started_unix_ms: int) -> PackedStringArray:
	var data: Dictionary = _base(
			started_unix_ms, LogfamiLevel.to_text(LogfamiLevel.Severity.INFO),
			LogfamiLevel.Severity.INFO, HEADER_SCOPE, HEADER_BODY, {})
	data["resource"] = _sorted(resource.attributes)
	return PackedStringArray([JSON.stringify(data, "", false)])


func file_extension() -> String:
	return "jsonl"


func _base(unix_ms: int, severity_text: String, severity_number: int, scope: String,
		body: String, attributes: Dictionary) -> Dictionary:
	return {
		"timestamp": LogfamiTime.rfc3339(unix_ms),
		"severity_text": severity_text,
		"severity_number": severity_number,
		"scope": scope,
		"body": body,
		"attributes": _sorted(attributes),
	}


## Copy with keys in sorted order, recursively, so output is deterministic.
func _sorted(values: Dictionary) -> Dictionary:
	var keys: Array = values.keys()
	keys.sort()
	var sorted: Dictionary = {}
	for key: Variant in keys:
		var value: Variant = values[key]
		if value is Dictionary:
			value = _sorted(value)
		sorted[key] = value
	return sorted
