@tool
class_name LogfamiRecordFilter
extends RefCounted
## Decides which records a viewer shows: a minimum severity, muted scopes and a
## text query.
##
## The query is a list of terms separated by whitespace. A record matches when
## every term occurs, case-insensitive, in its scope, body, or attributes
## (rendered as [code]key=value[/code]). A term starting with [code]-[/code]
## must not occur: [code]"token -refresh"[/code].
##
## The filter only reads records, so it works on a [LogfamiRecordBuffer] as well
## as on a plain array.

## Lowest severity that passes.
var min_level: int = LogfamiLevel.Severity.TRACE
## Records of these scopes never pass.
var muted_scopes: PackedStringArray = []
var query: String = ""


func mute(scope: String) -> void:
	if not muted_scopes.has(scope):
		muted_scopes.append(scope)


func unmute(scope: String) -> void:
	var index: int = muted_scopes.find(scope)
	if index >= 0:
		muted_scopes.remove_at(index)


func set_muted(scope: String, is_muted_now: bool) -> void:
	if is_muted_now:
		mute(scope)
	else:
		unmute(scope)


func is_muted(scope: String) -> bool:
	return muted_scopes.has(scope)


## True when [param record] passes severity, scope and query.
func matches(record: LogfamiRecord) -> bool:
	if record.severity_number < min_level:
		return false
	if is_muted(record.scope):
		return false
	return _matches_query(record)


## The records of [param records] that pass, in their order.
func apply(records: Array[LogfamiRecord]) -> Array[LogfamiRecord]:
	var passed: Array[LogfamiRecord] = []
	for record: LogfamiRecord in records:
		if matches(record):
			passed.append(record)
	return passed


func _matches_query(record: LogfamiRecord) -> bool:
	var terms: PackedStringArray = query.to_lower().split(" ", false)
	if terms.is_empty():
		return true
	var haystack: String = _haystack_of(record)
	for term: String in terms:
		if term.length() > 1 and term.begins_with("-"):
			if haystack.contains(term.substr(1)):
				return false
		elif not haystack.contains(term):
			return false
	return true


func _haystack_of(record: LogfamiRecord) -> String:
	var parts: PackedStringArray = [record.scope, record.body]
	for key: Variant in record.attributes:
		parts.append("%s=%s" % [key, record.attributes[key]])
	return " ".join(parts).to_lower()
