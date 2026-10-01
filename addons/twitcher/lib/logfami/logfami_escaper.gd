@tool
class_name LogfamiEscaper
extends RefCounted
## Keeps log lines on one line, following the OWASP advice against log
## injection: untrusted text (chat messages, player names) must not be able to
## start a line that looks like a real entry.

## Control characters and the Unicode line and paragraph separators.
const _CONTROL_PATTERN: String = "[\\x00-\\x1f\\x7f\\x{2028}\\x{2029}]"

const _NAMED_ESCAPES: Dictionary[String, String] = {
	"\n": "\\n",
	"\r": "\\r",
	"\t": "\\t",
}

static var _control_regex: RegEx = RegEx.create_from_string(_CONTROL_PATTERN)


## Replaces control characters with visible escapes: [code]\n[/code],
## [code]\r[/code], [code]\t[/code], everything else as [code]\uXXXX[/code].
## Text without control characters is returned unchanged.
static func escape_control(text: String) -> String:
	if _control_regex.search(text) == null:
		return text
	var escaped: String = ""
	for character: String in text:
		escaped += _escape_character(character)
	return escaped


## Escapes [param text] for use inside double quotes: backslash and quote get a
## backslash, control characters are escaped like in [method escape_control].
static func escape_quoted(text: String) -> String:
	var escaped: String = text.replace("\\", "\\\\").replace("\"", "\\\"")
	return escape_control(escaped)


static func _escape_character(character: String) -> String:
	if _NAMED_ESCAPES.has(character):
		return _NAMED_ESCAPES[character]
	if _control_regex.search(character) != null:
		return "\\u%04x" % character.unicode_at(0)
	return character
