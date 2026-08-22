@tool
extends Twitcher

## Parses https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ into the flat list of
## subscription types (name, version, required scopes, condition fields) TwitchEventsubDefinition
## is generated from. There's no swagger/openapi source for this page (unlike the eventsub-reference
## page, which TwitchAPIParser already covers via the twitch-eventsub-swagger json), so this fetches
## and regex-parses the doc HTML directly.
##
## Condition fields are cross-referenced against api_parser's already-parsed condition components -
## matching e.g. anchor id "automod-message-hold-condition" to component classname
## "AutomodMessageHoldCondition" (see _find_condition_component).
class_name TwitchEventsubDefinitionParser

const SUBSCRIPTION_TYPES_URL = "https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/"

## Already-parsed eventsub-reference schemas (conditions, events, ...), used to look up condition fields.
@export var api_parser: TwitchAPIParser

var definitions: Array[TwitchEventsubDefinitionInfo] = []

var _client: BufferedHTTPClient = BufferedHTTPClient.new()

# A subscription type header is a lowercase dotted name (2-4 segments), optionally suffixed with "V2"/"v2".
# e.g. "automod.message.hold", "channel.moderate v2". This distinguishes it from the other h3 headers in
# the same section ("Authorization", "... Request Body", "... Webhook Example", ...).
var _h3_regex: RegEx = RegEx.create_from_string("<h3 id=\"([a-zA-Z0-9_-]+)\">(.*?)</h3>")
var _type_header_regex: RegEx = RegEx.create_from_string("^[a-z][a-z0-9_]*(\\.[a-z0-9_]+){1,3}(\\s+[Vv]([0-9]+))?$")
var _version_regex: RegEx = RegEx.create_from_string("\"version\":\\s*\"([^\"]+)\"")

# Twitch inconsistently wraps scopes in the Authorization prose in either <code> or <strong>.
var _scope_regex: RegEx = RegEx.create_from_string(
	"<(?:code class=\"highlighter-rouge\"|strong)>([a-z_]+(?::[a-z_]+){1,2})</(?:code|strong)>")
var _request_body_header_regex: RegEx = RegEx.create_from_string("(?i)request-body")
var _condition_link_regex: RegEx = RegEx.create_from_string("eventsub-reference/#([a-z0-9-]+-condition)\"")

# Fallback for sections whose Request Body table doesn't link to a condition object on the reference page
# (it just says "Object"): pull the field names straight out of the first JSON "condition": { ... } block
# in the webhook/payload example. Condition objects are always flat, so a non-greedy match up to the next
# "}" is safe.
var _condition_json_regex: RegEx = RegEx.create_from_string("\"condition\":\\s*\\{([^{}]*)\\}")
var _json_key_regex: RegEx = RegEx.create_from_string("\"([a-zA-Z_][a-zA-Z0-9_]*)\"\\s*:")
var _tag_regex: RegEx = RegEx.create_from_string("<[^>]+>")


func parse_subscription_types() -> void:
	var html: String = await _fetch_html()

	var h3_matches: Array[RegExMatch] = _h3_regex.search_all(html)
	var type_header_indices: Array[int] = []
	for i in h3_matches.size():
		if _type_header_regex.search(h3_matches[i].get_string(2).strip_edges()):
			type_header_indices.append(i)

	definitions.clear()
	for t in type_header_indices.size():
		var i: int = type_header_indices[t]
		var h3_match: RegExMatch = h3_matches[i]
		var anchor_id: String = h3_match.get_string(1)
		var text: String = h3_match.get_string(2).strip_edges()

		# A section spans until the next *type-header* h3, not just the next h3 (which would only be
		# "Authorization" and cut the section off before the scopes text and the Request Body table).
		var next_type_header_index: int = type_header_indices[t + 1] if t + 1 < type_header_indices.size() else -1
		var section_start: int = h3_match.get_start()
		var section_end: int = h3_matches[next_type_header_index].get_start() if next_type_header_index != -1 else html.length()
		var section: String = html.substr(section_start, section_end - section_start)

		# The webhook/payload JSON examples are syntax-highlighted: each token sits in its own <span>, so
		# e.g. "version": "2" is actually "version"</span><span...>:</span>...  in the raw markup and won't
		# match a plain JSON regex. Strip tags first so the JSON reads as JSON again.
		var plain_text: String = _tag_regex.sub(section, "", true)

		var version_match: RegExMatch = _type_header_regex.search(text)
		var is_v2: bool = version_match.get_start(2) != -1
		var value: String = text.substr(0, version_match.get_start(2)).strip_edges() if is_v2 else text

		var version: String = "1"
		var version_json_match: RegExMatch = _version_regex.search(plain_text)
		if version_json_match: version = version_json_match.get_string(1)

		# Authorization scopes only ever show up between the type header and the "Request Body" heading;
		# scanning past that risks picking up unrelated colon-separated text in webhook/payload JSON examples.
		var request_body_match: RegExMatch = _request_body_header_regex.search(section)
		var scope_slice: String = section.substr(0, request_body_match.get_start()) if request_body_match else section
		var scopes: Array[String] = []
		for scope_match: RegExMatch in _scope_regex.search_all(scope_slice):
			if not scopes.has(scope_match.get_string(1)): scopes.append(scope_match.get_string(1))

		var conditions: Array[String] = _parse_conditions(section, plain_text, value)

		var info: TwitchEventsubDefinitionInfo = TwitchEventsubDefinitionInfo.new()
		info.enum_name = _to_enum_name(value) + ("V2" if is_v2 else "")
		info.value = value
		info.version = version
		info.conditions = conditions
		info.scopes = scopes
		info.documentation_link = "%s#%s" % [SUBSCRIPTION_TYPES_URL, anchor_id]
		definitions.append(info)

	print("%s subscription type definitions parsed" % definitions.size())


func _parse_conditions(section: String, plain_text: String, value: String) -> Array[String]:
	var condition_link_match: RegExMatch = _condition_link_regex.search(section)
	if condition_link_match:
		var condition_id: String = condition_link_match.get_string(1)
		var component: TwitchGenComponent = _find_condition_component(condition_id)
		if component:
			var fields: Array[String] = []
			for field: TwitchGenField in component._fields:
				fields.append(field._original_name)
			return fields
		push_warning("No condition component found for '%s' (%s)" % [condition_id, value])
		return []

	var condition_json_match: RegExMatch = _condition_json_regex.search(plain_text)
	if condition_json_match:
		var fields: Array[String] = []
		for key_match: RegExMatch in _json_key_regex.search_all(condition_json_match.get_string(1)):
			if not fields.has(key_match.get_string(1)): fields.append(key_match.get_string(1))
		return fields

	push_warning("No condition found for '%s'" % value)
	return []


## Matches e.g. "automod-message-hold-condition" to the component classname "AutomodMessageHoldCondition".
## Compares lowercased, separator-stripped strings rather than String.to_snake_case() - that splits a
## trailing version digit off its letter (e.g. "ModerateV2" -> "moderate_v_2"), which breaks the match.
func _find_condition_component(condition_id: String) -> TwitchGenComponent:
	var condition_key: String = condition_id.replace("-", "").to_lower()
	for component: TwitchGenComponent in api_parser.components:
		if component._classname.to_lower() == condition_key:
			return component
	return null


func _to_enum_name(dotted_value: String) -> String:
	var result: String = ""
	for word in dotted_value.replace(".", "_").split("_"):
		if word.is_empty(): continue
		result += word.substr(0, 1).to_upper() + word.substr(1)
	return result


func _fetch_html() -> String:
	add_child(_client)
	_client.max_error_count = 3
	var request: BufferedHTTPClient.RequestData = _client.request(SUBSCRIPTION_TYPES_URL, HTTPClient.METHOD_GET, {}, "")
	var response: BufferedHTTPClient.ResponseData = await _client.wait_for_request(request)
	remove_child(_client)

	if response.error:
		push_error("Could not fetch %s" % SUBSCRIPTION_TYPES_URL)
		return ""
	return response.response_data.get_string_from_utf8()
