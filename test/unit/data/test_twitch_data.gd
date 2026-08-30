## Unit tests for [TwitchData], the base class every generated DTO extends.
##
## 289 generated files inherit this, so its behaviour is the contract for ~44 000
## lines of code. It is also the purest class in the addon: a Resource with a
## dictionary and three methods.
##
## The central design point is that [code]_tracked[/code] records only fields that
## were explicitly set, so [code]to_dict()[/code] produces a sparse payload and a
## PATCH-style request does not clobber unset fields with nulls. That makes the
## null-erase behaviour load-bearing rather than incidental.
extends TwitcherTest

const SampleUser := preload("res://addons/twitcher/generated/twitch_user.gd")


func test_new_instance_serialises_to_an_empty_dictionary() -> void:
	assert_eq(TwitchData.new().to_dict(), {} as Dictionary[StringName, Variant])


func test_track_data_records_a_scalar() -> void:
	var data := TwitchData.new()
	data.track_data(&"id", "123")
	assert_eq(data.to_dict(), {&"id": "123"} as Dictionary[StringName, Variant])


func test_track_data_overwrites_a_previous_value() -> void:
	var data := TwitchData.new()
	data.track_data(&"id", "first")
	data.track_data(&"id", "second")
	assert_eq(data.to_dict()[&"id"], "second")


## Null means "not set", not "set to null". This is what keeps [code]to_dict()[/code]
## sparse — an optional field assigned then cleared must vanish from the payload
## rather than serialise as an explicit null.
func test_track_data_erases_on_null() -> void:
	var data := TwitchData.new()
	data.track_data(&"id", "123")
	data.track_data(&"id", null)
	assert_false(data.to_dict().has(&"id"), "null must erase, not store")


func test_tracking_null_for_an_unset_key_is_harmless() -> void:
	var data := TwitchData.new()
	data.track_data(&"never_set", null)
	assert_eq(data.to_dict(), {} as Dictionary[StringName, Variant])


func test_track_data_preserves_falsy_values() -> void:
	var data := TwitchData.new()
	data.track_data(&"count", 0)
	data.track_data(&"flag", false)
	data.track_data(&"text", "")
	assert_has_entries(data.to_dict(), {&"count": 0, &"flag": false, &"text": ""},
		"only null erases — 0, false and empty string are real values")


func test_track_data_serialises_arrays_of_dtos() -> void:
	var child := TwitchData.new()
	child.track_data(&"id", "child")

	var parent := TwitchData.new()
	parent.track_data(&"items", [child])

	assert_eq(parent.to_dict()[&"items"], [{&"id": "child"}],
		"array elements exposing to_dict must be serialised, not stored as objects")


func test_track_data_passes_through_arrays_of_primitives() -> void:
	var data := TwitchData.new()
	data.track_data(&"tags", ["a", "b"])
	assert_eq(data.to_dict()[&"tags"], ["a", "b"])


func test_track_data_handles_a_mixed_array() -> void:
	var child := TwitchData.new()
	child.track_data(&"id", "child")

	var data := TwitchData.new()
	data.track_data(&"mixed", ["plain", child])

	assert_eq(data.to_dict()[&"mixed"], ["plain", {&"id": "child"}])


func test_track_data_serialises_a_nested_dto() -> void:
	var child := TwitchData.new()
	child.track_data(&"id", "child")

	var parent := TwitchData.new()
	parent.track_data(&"child", child)

	assert_eq(parent.to_dict()[&"child"], {&"id": "child"})


func test_empty_array_is_tracked_as_empty() -> void:
	var data := TwitchData.new()
	data.track_data(&"items", [])
	assert_true(data.to_dict().has(&"items"), "an empty array is a value, not an absence")
	assert_eq(data.to_dict()[&"items"], [])


#region to_json

func test_to_json_of_an_empty_object() -> void:
	assert_eq(TwitchData.new().to_json(), "{}")


## [code]to_dict()[/code] preserves insertion order (Godot Dictionaries do), but
## [code]to_json()[/code] does not: [code]JSON.stringify[/code] defaults to
## [code]sort_keys = true[/code], so the emitted JSON is alphabetical.
##
## Worth knowing on two counts. It is deterministic, so asserting on exact JSON
## strings is safe. And it means the key order of a request body sent to Twitch
## has nothing to do with the order fields were assigned — so a test that builds
## an expected string by mirroring assignment order will fail confusingly.
func test_to_json_sorts_keys_alphabetically() -> void:
	var data := TwitchData.new()
	data.track_data(&"id", "123")
	data.track_data(&"count", 7)

	assert_eq(data.to_dict().keys(), [&"id", &"count"], "to_dict keeps insertion order")
	assert_eq(data.to_json(), '{"count":7,"id":"123"}', "to_json sorts; see doc comment")


## Godot's JSON parser produces [code]float[/code] for every number, so an
## [code]int[/code] field does not survive a stringify/parse cycle as an
## [code]int[/code].
##
## Not a Twitcher bug — [code]to_json()[/code] emits [code]7[/code] correctly, and
## the wire never sees the difference. But it does mean a test comparing a parsed
## payload against an integer literal fails confusingly, and that
## [code]from_json[/code] assigns a float into an [code]int[/code] property
## (Godot coerces silently). Pinned so the next person meets this in a test rather
## than in a debugger.
func test_json_parsing_widens_integers_to_floats() -> void:
	var data := TwitchData.new()
	data.track_data(&"count", 7)

	var reparsed: Variant = JSON.parse_string(data.to_json())
	assert_eq(typeof(reparsed["count"]), TYPE_FLOAT, "Godot's JSON parser has no integer type")
	assert_eq(reparsed["count"], 7.0)

#endregion


#region to_dict aliasing

## [code]to_dict()[/code] returns [code]_tracked[/code] itself, not a copy. A
## caller mutating the result silently rewrites the DTO's tracked state.
##
## Nothing in Twitcher does this today — [code]TwitchAPI.request()[/code] passes
## the result straight to [code]JSON.stringify[/code] — so this is a hazard
## rather than a live bug. Pinned so that changing it to return a copy is a
## deliberate decision, and so the aliasing is discoverable from the test file
## rather than from a debugging session.
func test_to_dict_returns_the_live_dictionary_not_a_copy() -> void:
	var data := TwitchData.new()
	data.track_data(&"id", "123")

	var dict := data.to_dict()
	dict[&"injected"] = "surprise"

	assert_true(
		data.to_dict().has(&"injected"),
		"to_dict() aliases internal state; see doc comment"
	)

#endregion


#region generated subclass behaviour

## The generated setters are what actually call [code]track_data[/code].
## [code]TwitchUser[/code] stands in for all 289 generated classes.
func test_generated_setter_tracks_the_assigned_field() -> void:
	var user := SampleUser.new()
	user.id = "12345"
	assert_eq(user.to_dict()[&"id"], "12345")


func test_generated_dto_only_reports_fields_that_were_set() -> void:
	var user := SampleUser.new()
	user.id = "12345"
	assert_eq(
		user.to_dict().keys(), [&"id"],
		"a sparse payload is the whole point of tracking"
	)


func test_generated_from_json_populates_tracked_data() -> void:
	var user: SampleUser = SampleUser.from_json({"id": "12345", "login": "someone"})
	assert_eq(user.id, "12345")
	assert_eq(user.login, "someone")
	assert_has_entries(user.to_dict(), {&"id": "12345", &"login": "someone"})


func test_generated_from_json_ignores_absent_fields() -> void:
	var user: SampleUser = SampleUser.from_json({"id": "12345"})
	assert_false(user.to_dict().has(&"login"), "absent keys must stay absent")


func test_generated_from_json_tolerates_an_empty_dictionary() -> void:
	var user: SampleUser = SampleUser.from_json({})
	assert_not_null(user, "the error path passes {} in — it must not crash")
	assert_eq(user.to_dict(), {} as Dictionary[StringName, Variant])

#endregion
