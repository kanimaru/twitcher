## Differential tests between [TwitchAPIGenerator] and [TwitchEventsubGenerator].
##
## The EventSub generator is a near-verbatim fork of the API generator — roughly
## 90% duplicated. Forks drift, and three of the divergences below are live
## defects rather than deliberate differences.
##
## These tests fail when a divergence is [i]fixed[/i] as well as when a new one
## appears, which is the point: each is a decision that should be made
## explicitly. Every assertion says which of the two it is.
extends TwitcherTest

const GOLDEN_DIR := "res://test/generator/golden/"

var _api: GeneratorHarness
var _eventsub: GeneratorHarness


func after_each() -> void:
	if _api != null:
		_api.dispose()
		_api = null
	if _eventsub != null:
		_eventsub.dispose()
		_eventsub = null
	super()


func _build_both(spec_file: String) -> void:
	var spec := _load_spec(spec_file)
	_api = GeneratorHarness.new()
	await _api.build_api(spec)
	_eventsub = GeneratorHarness.new()
	await _eventsub.build_eventsub(spec)


#region DEFECT: renamed fields lose their wire name

## [b]Live defect.[/b] [code]TwitchGenField[/code] renames wire names that are
## illegal GDScript identifiers ([code]animated[/code] → [code]animated_format[/code],
## [code]1[/code] → [code]_1[/code], [code]source-only[/code] → [code]source_only[/code])
## and keeps the original in [code]_original_name[/code].
##
## The API generator emits [code]_original_name[/code] on the wire side of both
## the setter's [code]track_data[/code] and [code]from_json[/code]'s
## [code]d.get(...)[/code]. The EventSub generator emits the [i]sanitised[/i]
## name on both sides, so a payload containing a renamed field would parse as
## null and serialise under a key Twitch does not recognise.
##
## No EventSub schema currently contains a renamed field, so this is latent. It
## becomes a silent data-loss bug the day Twitch adds one.
func test_eventsub_from_json_reads_the_sanitised_name_instead_of_the_wire_name() -> void:
	await _build_both("spec_renamed_fields.json")

	var api_code := _api.code_for("SampleRenames")
	var eventsub_code := _eventsub.code_for("SampleRenames")

	assert_string_contains(
		api_code, 'if d.get("animated", null) != null:',
		"API generator reads the wire name — correct"
	)
	assert_string_contains(
		eventsub_code, 'if d.get("animated_format", null) != null:',
		"DEFECT: EventSub reads the renamed identifier, a key Twitch never sends"
	)
	assert_false(
		eventsub_code.contains('d.get("animated", null)'),
		"DEFECT confirmed: the wire name appears nowhere in EventSub's from_json"
	)


func test_eventsub_track_data_uses_the_sanitised_name() -> void:
	await _build_both("spec_renamed_fields.json")

	assert_string_contains(
		_api.code_for("SampleRenames"), 'track_data(&"source-only", val)',
		"API generator serialises under the wire name — correct"
	)
	assert_string_contains(
		_eventsub.code_for("SampleRenames"), 'track_data(&"source_only", val)',
		"DEFECT: EventSub serialises under the identifier, so to_dict() output is wrong"
	)

#endregion


#region DEFECT: array fields are never tracked

## [b]Live defect, and it affects shipped code today.[/b]
##
## Both generators build arrays in [code]from_json[/code] with
## [code]result.x.append(...)[/code]. Because [code]append[/code] mutates the
## array in place it never runs the property setter, so
## [code]track_data[/code] is never called and [code]TwitchData._tracked[/code]
## never learns about the field.
##
## The API generator compensates with an explicit
## [code]result.track_data(&"x", result.x)[/code] after the loop. The EventSub
## generator does not — so [code]to_dict()[/code] and [code]to_json()[/code] on
## any EventSub DTO silently drop every array field.
##
## Verified in shipped output: see the [code]badges[/code], [code]fragments[/code]
## and [code]format[/code] arrays in
## [code]generated_eventsub/twitch_es_channel_chat_notification.gd[/code].
## [code]test/unit/data/test_generated_dto_roundtrip.gd[/code] demonstrates the
## resulting data loss on a real class.
func test_api_generator_tracks_typed_array_fields_after_appending() -> void:
	await _build_both("spec_grouped.json")

	assert_string_contains(
		_api.code_for("GetSampleItems"), 'result.track_data(&"data", result.data)',
		"API generator restores tracking that append() bypassed — correct"
	)


func test_eventsub_generator_omits_track_data_for_array_fields() -> void:
	await _build_both("spec_grouped.json")

	var eventsub_code := _eventsub.code_for("GetSampleItemsResponse")
	assert_string_contains(
		eventsub_code, "result.data.append(",
		"sanity: the append loop is emitted"
	)
	assert_false(
		eventsub_code.contains('result.track_data(&"data", result.data)'),
		"DEFECT: no track_data after the loop, so to_dict() drops the array"
	)

#endregion


#region DEFECT: dead fully-qualified-name path

## [b]Dead code.[/b] The API generator resolves a fully-qualified name through
## [code]component._fqdn[/code], a Callable assigned in
## [code]prepare_component[/code]. The EventSub generator instead reads
## [code]component.get_meta("fqdn")[/code] — and nothing anywhere calls
## [code]set_meta("fqdn")[/code].
##
## So EventSub's [code]full_qualified[/code] argument silently does nothing and
## always returns the short class name.
func test_eventsub_full_qualified_lookup_is_never_populated() -> void:
	await _build_both("spec_grouped.json")

	# Not "Response": EventSub groups on Condition/Event/EventV2, so a
	# ...Response schema is standalone here and keeps its full name.
	var component := _eventsub.find_component("TwitchESGetSampleItemsResponse")
	assert_not_null(component, "sanity: the component exists")
	if component == null:
		return
	assert_false(
		component.has_meta("fqdn"),
		"DEFECT: nothing sets the meta the EventSub generator reads"
	)
	assert_eq(
		_eventsub.generator.get_type(component._ref, false, true),
		_eventsub.generator.get_type(component._ref, false, false),
		"DEFECT confirmed: full_qualified=true is indistinguishable from false"
	)


func test_api_full_qualified_lookup_resolves_through_the_callable() -> void:
	await _build_both("spec_grouped.json")

	var component := _api.find_component("Response")
	assert_eq(
		_api.generator.get_type(component._ref, false, true), "TwitchGetSampleItems.Response",
		"API generator resolves the outer class — correct"
	)
	assert_eq(_api.generator.get_type(component._ref, false, false), "Response")

#endregion


#region Intentional differences

## Different class prefixes are deliberate — EventSub DTOs are namespaced
## [code]TwitchES*[/code] to keep them apart from the API DTOs.
func test_eventsub_prefixes_class_names_with_twitch_es() -> void:
	await _build_both("spec_minimal.json")

	assert_string_contains(_api.code_for("SampleUser"), "class_name TwitchSampleUser")
	assert_string_contains(_eventsub.code_for("SampleUser"), "class_name TwitchESSampleUser")


## Different suffix sets are deliberate: the API groups by
## [code]Response[/code]/[code]Body[/code]/[code]Opt[/code], EventSub by
## [code]Condition[/code]/[code]Event[/code]/[code]EventV2[/code].
func test_the_two_generators_group_on_different_suffixes() -> void:
	assert_eq(TwitchAPIGenerator.suffixes, ["Response", "Body", "Opt"] as Array[String])
	assert_eq(TwitchEventsubGenerator.suffixes, ["Condition", "Event", "EventV2"] as Array[String])


func test_the_two_generators_write_to_different_folders() -> void:
	assert_eq(TwitchAPIGenerator.api_output_path, "res://addons/twitcher/generated/")
	assert_eq(TwitchEventsubGenerator.api_output_path, "res://addons/twitcher/generated_eventsub/")


## Cosmetic drift with no functional effect, pinned so that unifying the two
## generators is a visible change rather than an invisible one.
func test_eventsub_emits_untyped_path_variable() -> void:
	await _build_both("spec_grouped.json")

	var method := _api.find_method("get_sample_items")
	assert_string_contains(
		_api.generator.path_code(method), 'var path: String = "/sample/items?"',
		"API generator declares the type"
	)
	assert_string_contains(
		_eventsub.generator.path_code(_eventsub.find_method("get_sample_items")),
		'var path = "/sample/items?"',
		"EventSub omits it — cosmetic, but drift"
	)


## Off-by-one drift in the iterator. The API generator triggers the next page
## when the cursor reaches [code]data.size()[/code]; EventSub uses
## [code]data.size() - 1[/code], i.e. one element early. EventSub DTOs are never
## paginated so this is unreachable, but it is a real difference.
func test_iterator_page_boundary_differs_between_generators() -> void:
	await _build_both("spec_grouped.json")

	var api_component := _api.find_component("Response")
	var eventsub_component := _eventsub.find_component("TwitchESGetSampleItemsResponse")
	assert_not_null(eventsub_component, "sanity: the component exists")
	if eventsub_component == null:
		return

	assert_string_contains(
		_api.generator.iter_code(api_component), "if data.size() == _cur_iter && _has_pagination():"
	)
	assert_string_contains(
		_eventsub.generator.iter_code(eventsub_component),
		"if data.size() - 1 == _cur_iter && _has_pagination():",
		"EventSub pages one element early — unreachable today, but drift"
	)

#endregion


func _load_spec(file_name: String) -> Dictionary:
	var raw := FileAccess.get_file_as_string(GOLDEN_DIR + file_name)
	assert_ne(raw, "", "missing spec fixture: %s" % file_name)
	return JSON.parse_string(raw) as Dictionary
