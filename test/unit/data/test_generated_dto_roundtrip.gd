## Round-trip tests over real generated DTOs.
##
## Where [code]test/generator/[/code] pins the code that [i]produces[/i] the 289
## generated files, this suite samples the shipped output and checks that
## [code]from_json(payload).to_dict()[/code] gives the payload back.
##
## Both layers are needed. The generator tests catch a template regression before
## anyone regenerates; these catch the fact that a defect is live in code that
## ships today.
extends TwitcherTest

const TwitchUserDto := preload("res://addons/twitcher/generated/twitch_user.gd")
const GetUsersDto := preload("res://addons/twitcher/generated/twitch_get_users.gd")
const CheermoteImageTheme := preload("res://addons/twitcher/generated/twitch_cheermote_image_theme.gd")
const ESChannelBan := preload("res://addons/twitcher/generated_eventsub/twitch_es_channel_ban.gd")
const ESChatNotification := preload("res://addons/twitcher/generated_eventsub/twitch_es_channel_chat_notification.gd")


#region Scalar round-trips

func test_user_round_trips_scalar_fields() -> void:
	var payload := {
		"id": "141981764",
		"login": "twitchdev",
		"display_name": "TwitchDev",
		"type": "",
		"broadcaster_type": "partner",
		"description": "Supporting third-party developers.",
		"view_count": 5980557,
	}
	var dto: TwitchUserDto = TwitchUserDto.from_json(payload)
	var actual := dto.to_dict()

	for key: String in payload:
		assert_true(actual.has(StringName(key)), "round-trip dropped '%s'" % key)
		assert_eq(actual[StringName(key)], payload[key], "value changed for '%s'" % key)


func test_eventsub_scalar_fields_round_trip() -> void:
	var payload := {
		"user_id": "1234",
		"user_login": "someone",
		"broadcaster_user_id": "5678",
		"reason": "spam",
		"is_permanent": true,
	}
	var event: ESChannelBan.Event = ESChannelBan.Event.from_json(payload)
	var actual := event.to_dict()

	for key: String in payload:
		assert_true(actual.has(StringName(key)), "round-trip dropped '%s'" % key)
		assert_eq(actual[StringName(key)], payload[key], "value changed for '%s'" % key)


## The API generator keeps the wire name for renamed fields, so a payload key
## Twitch actually sends survives a round-trip even though the GDScript property
## is called something else. This is the behaviour the EventSub generator is
## missing — see [code]test/generator/test_generator_parity.gd[/code].
func test_renamed_field_round_trips_under_its_wire_name() -> void:
	var payload := {"animated": {"url_1x": "https://example.invalid/1.gif"}}
	var theme: CheermoteImageTheme = CheermoteImageTheme.from_json(payload)

	assert_not_null(theme.animated_format, "property is renamed, JSON key is not")
	assert_true(
		theme.to_dict().has(&"animated"),
		"must serialise back under the wire name, not the identifier"
	)

#endregion


#region Typed array round-trips

func test_api_dto_round_trips_a_typed_array() -> void:
	var payload := {"data": [{"id": "1", "login": "one"}, {"id": "2", "login": "two"}]}
	var response: GetUsersDto.Response = GetUsersDto.Response.from_json(payload)

	assert_eq(response.data.size(), 2, "elements should be parsed into DTOs")
	assert_true(
		response.to_dict().has(&"data"),
		"the API generator emits track_data after the append loop"
	)
	assert_eq(response.to_dict()[&"data"].size(), 2)


## Regression test for a live defect in the EventSub generator.
##
## [code]from_json[/code] fills arrays with [code]result.x.append(...)[/code].
## Appending mutates in place, so the property setter never runs and
## [code]track_data[/code] is never called. The API generator compensates with an
## explicit [code]result.track_data(&"x", result.x)[/code] after the loop; the
## EventSub generator does not.
##
## The result is silent data loss: the array is parsed correctly and readable via
## the property, but [code]to_dict()[/code] and [code]to_json()[/code] omit it
## entirely. Anything that re-serialises an EventSub DTO — logging it, caching it,
## forwarding it — loses every array field.
##
## Affects [code]badges[/code], [code]source_badges[/code], [code]fragments[/code]
## and [code]format[/code] in
## [code]generated_eventsub/twitch_es_channel_chat_notification.gd[/code], and the
## same shape everywhere else in that folder.
##
## Fix belongs in [code]TwitchEventsubGenerator.from_json_code()[/code], followed
## by regenerating. When that lands, this test flips to asserting the array
## survives.
func test_eventsub_dto_drops_typed_arrays_on_serialisation() -> void:
	var payload := {
		"chatter_user_id": "1234",
		"badges": [
			{"set_id": "moderator", "id": "1", "info": ""},
			{"set_id": "subscriber", "id": "12", "info": "16"},
		],
	}
	var event: ESChatNotification.Event = ESChatNotification.Event.from_json(payload)

	assert_eq(event.badges.size(), 2, "parsing works — the property is populated")
	assert_true(
		event.to_dict().has(&"chatter_user_id"),
		"sanity: scalar fields on the same object do survive"
	)
	assert_false(
		event.to_dict().has(&"badges"),
		"KNOWN DEFECT: append() bypasses the setter and no track_data follows"
	)


func test_eventsub_dto_drops_primitive_arrays_too() -> void:
	var payload := {"text": "hello", "format": ["bold", "italic"]}
	var fragment: ESChatNotification.Fragments = ESChatNotification.Fragments.from_json(payload)

	assert_true(event_has_text(fragment), "sanity: the scalar survives")
	assert_false(
		fragment.to_dict().has(&"format"),
		"KNOWN DEFECT: same root cause, primitive arrays are affected identically"
	)


func event_has_text(fragment: ESChatNotification.Fragments) -> bool:
	return fragment.to_dict().has(&"text")

#endregion


#region Robustness

## [code]TwitchAPI[/code] calls [code]from_json(result)[/code] with
## [code]result[/code] still [code]{}[/code] on any 4xx, so every generated
## [code]from_json[/code] is called with an empty dictionary on the error path.
var empty_payload_params := [
	"TwitchUser",
	"GetUsers.Response",
	"GetUsers.Opt",
	"CheermoteImageTheme",
	"ESChannelBan.Event",
	"ESChannelBan.Condition",
	"ESChatNotification.Event",
]


func test_from_json_tolerates_an_empty_dictionary(params = use_parameters(empty_payload_params)) -> void:
	var dto: TwitchData = _construct_from_empty(params)
	assert_not_null(dto, "%s.from_json({}) must not crash — this is the 4xx path" % params)
	if dto == null:
		return
	assert_eq(
		dto.to_dict(), {} as Dictionary[StringName, Variant],
		"%s should track nothing when given nothing" % params
	)


func test_from_json_ignores_unknown_keys() -> void:
	var dto: TwitchUserDto = TwitchUserDto.from_json({
		"id": "1", "a_field_twitch_added_last_week": "surprise",
	})
	assert_eq(dto.to_dict().keys(), [&"id"], "unknown keys must be skipped, not crash")


func test_from_json_treats_explicit_null_as_absent() -> void:
	var dto: TwitchUserDto = TwitchUserDto.from_json({"id": "1", "login": null})
	assert_false(
		dto.to_dict().has(&"login"),
		"the generated guard is `d.get(k, null) != null`, so null means absent"
	)


func _construct_from_empty(name: String) -> TwitchData:
	match name:
		"TwitchUser": return TwitchUserDto.from_json({})
		"GetUsers.Response": return GetUsersDto.Response.from_json({})
		"GetUsers.Opt": return GetUsersDto.Opt.from_json({})
		"CheermoteImageTheme": return CheermoteImageTheme.from_json({})
		"ESChannelBan.Event": return ESChannelBan.Event.from_json({})
		"ESChannelBan.Condition": return ESChannelBan.Condition.from_json({})
		"ESChatNotification.Event": return ESChatNotification.Event.from_json({})
	fail_test("unknown DTO name in fixture table: %s" % name)
	return null

#endregion
