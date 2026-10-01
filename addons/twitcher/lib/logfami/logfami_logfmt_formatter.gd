@tool
class_name LogfamiLogfmtFormatter
extends LogfamiFormatter
## [code]key=value[/code] lines (logfmt), friendly to grep and Grafana Loki:
## [codeblock]
## time=2025-09-29T10:00:00.123Z level=info scope=Shop msg="Item bought" id=42
## [/codeblock]
## Quoting follows go-logfmt: values with spaces, [code]=[/code], quotes or
## control characters are quoted, with [code]\\[/code], [code]\"[/code] and
## control characters escaped. Attributes follow the fixed keys, sorted;
## nested containers are rendered as JSON (see [LogfamiValue]).

const HEADER_SCOPE: String = "logfami"
const HEADER_MESSAGE: String = "session.start"

static var _invalid_key_characters: RegEx = RegEx.create_from_string("[^A-Za-z0-9_.\\-]")


## Quotes and escapes [param value] when logfmt requires it.
static func quote(value: String) -> String:
	return LogfamiEscaper.quote_if_needed(value)


## Replaces characters that aren't allowed in a logfmt key with [code]_[/code].
static func clean_key(key: String) -> String:
	var cleaned: String = _invalid_key_characters.sub(key, "_", true)
	return cleaned if cleaned != "" else "_"


func format(record: LogfamiRecord, _resource: LogfamiResource) -> String:
	var level: String = record.severity_text.to_lower()
	if level == "":
		level = str(record.severity_number)
	var pairs: PackedStringArray = [
		_pair("time", LogfamiTime.rfc3339(record.time_unix_ms)),
		_pair("level", level),
		_pair("scope", record.scope),
		_pair("msg", record.body),
	]
	pairs.append_array(_attribute_pairs(record.attributes))
	return " ".join(pairs)


func header(resource: LogfamiResource, started_unix_ms: int) -> PackedStringArray:
	var pairs: PackedStringArray = [
		_pair("time", LogfamiTime.rfc3339(started_unix_ms)),
		_pair("level", "info"),
		_pair("scope", HEADER_SCOPE),
		_pair("msg", HEADER_MESSAGE),
	]
	pairs.append_array(_attribute_pairs(resource.attributes))
	return PackedStringArray([" ".join(pairs)])


func _attribute_pairs(attributes: Dictionary) -> PackedStringArray:
	var keys: Array = attributes.keys()
	keys.sort()
	var pairs: PackedStringArray = []
	for key: Variant in keys:
		pairs.append(_pair(str(key), LogfamiValue.to_text(attributes[key])))
	return pairs


func _pair(key: String, value: String) -> String:
	return "%s=%s" % [clean_key(key), quote(value)]
