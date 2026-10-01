@tool
class_name LogfamiRedactor
extends LogfamiProcessor
## Masks secrets before a record is written, so log files can be shared safely.
##
## Two mechanisms work together:
## [br]- [member rules] rewrite the body and every text attribute, e.g.
## [code]Bearer abc123…[/code] becomes [code]Bearer [REDACTED][/code].
## [br]- [member sensitive_keys] mask a whole attribute value when its key
## contains one of them, e.g. [code]{ "refresh_token": "…" }[/code].
## [codeblock]
## pipeline.add_processor(LogfamiRedactor.with_defaults())
## [/codeblock]

const MASK: String = "[REDACTED]"

## Attribute keys containing one of these (case-insensitive) are masked.
const DEFAULT_SENSITIVE_KEYS: PackedStringArray = [
	"token",
	"secret",
	"password",
	"authorization",
	"cookie",
	"api_key",
	"apikey",
]

var rules: Array[LogfamiRedactionRule] = []
var sensitive_keys: PackedStringArray = []


## Redactor with rules for common credentials: authorization headers, IRC
## [code]oauth:[/code] passwords, [code]key=value[/code] and JSON secrets, and
## OAuth codes in URLs. [param include_generic_secrets] also masks any long
## mixed letter and digit token, at the price of false positives such as
## hashes.
static func with_defaults(include_generic_secrets: bool = false) -> LogfamiRedactor:
	var redactor: LogfamiRedactor = LogfamiRedactor.new()
	redactor.sensitive_keys = DEFAULT_SENSITIVE_KEYS.duplicate()
	redactor.add_rule(LogfamiRedactionRule.new("authorization_header",
			"(?i)\\b(bearer|oauth)\\s+(?=[\\w\\-.~+/]*\\d)[\\w\\-.~+/]{8,}=*",
			"$1 " + MASK))
	redactor.add_rule(LogfamiRedactionRule.new("irc_password",
			"(?i)\\boauth:[a-z0-9]+",
			"oauth:" + MASK))
	redactor.add_rule(LogfamiRedactionRule.new("key_value",
			"(?i)\\b(access_token|refresh_token|id_token|client_secret|password|passwd"
					+ "|api_key|apikey|secret|token)([\"']?\\s*[:=]\\s*[\"']?)"
					+ "[^\\s&\"',;}\\]]+",
			"$1$2" + MASK))
	redactor.add_rule(LogfamiRedactionRule.new("url_code",
			"([?&#]code=)[^&\\s#\"']+",
			"$1" + MASK))
	if include_generic_secrets:
		redactor.add_rule(LogfamiRedactionRule.new("generic_secret",
				"\\b(?=[\\w\\-]*\\d)(?=[\\w\\-]*[A-Za-z])[\\w\\-]{30,}\\b",
				MASK))
	return redactor


func add_rule(rule: LogfamiRedactionRule) -> LogfamiRedactor:
	rules.append(rule)
	return self


## Applies every rule to [param text], in the order they were added.
func redact(text: String) -> String:
	var redacted: String = text
	for rule: LogfamiRedactionRule in rules:
		redacted = rule.apply(redacted)
	return redacted


func is_sensitive_key(key: String) -> bool:
	var lowered: String = key.to_lower()
	for sensitive: String in sensitive_keys:
		if lowered.contains(sensitive.to_lower()):
			return true
	return false


func process(record: LogfamiRecord) -> LogfamiRecord:
	record.body = redact(record.body)
	record.attributes = _redact_dictionary(record.attributes)
	return record


func _redact_dictionary(values: Dictionary) -> Dictionary:
	var redacted: Dictionary = {}
	for key: Variant in values:
		if is_sensitive_key(str(key)):
			redacted[key] = MASK
		else:
			redacted[key] = _redact_value(values[key])
	return redacted


func _redact_value(value: Variant) -> Variant:
	if value is String or value is StringName:
		return redact(str(value))
	if value is Dictionary:
		return _redact_dictionary(value)
	if value is Array:
		var redacted: Array = []
		for item: Variant in value:
			redacted.append(_redact_value(item))
		return redacted
	return value
