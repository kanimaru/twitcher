## Unit tests for [TwitchAPIParser].
##
## The parser turns an OpenAPI document into the [TwitchGenComponent] /
## [TwitchGenMethod] object model the generators walk. Everything here runs off
## an injected [code]definition[/code], so no HTTP request is ever made.
##
## Where the golden files pin the [i]output[/i], these pin the [i]model[/i] — so
## a mapping bug reports as "String became Variant" rather than as a hundred-line
## diff.
extends TwitcherTest

const GOLDEN_DIR := "res://test/generator/golden/"

var _harness: GeneratorHarness


func after_each() -> void:
	if _harness != null:
		_harness.dispose()
		_harness = null
	super()


#region _get_param_type

## The full JSON-Schema-to-GDScript type mapping, as
## [code][schema, expected type][/code].
var type_params := [
	[{"type": "string"}, "String"],
	[{"type": "STRING"}, "String"],
	[{"type": "integer"}, "int"],
	[{"type": "boolean"}, "bool"],
	[{"type": "bool"}, "bool"],
	[{"type": "number"}, "int"],
	[{"type": "number", "format": "float"}, "float"],
	[{"type": "number", "format": "double"}, "int"],
	[{"type": "object"}, "Dictionary"],
	[{"type": "wat"}, "Variant"],
	[{}, "Variant"],
	[{"$ref": "#/components/schemas/Thing"}, "#/components/schemas/Thing"],
	[{"type": "array", "items": {"type": "string"}}, "String"],
	[{"type": "array", "items": {"$ref": "#/components/schemas/Thing"}}, "#/components/schemas/Thing"],
	[{"type": "array", "items": {"type": "integer"}}, "Variant"],
]


func test_param_type_mapping(params = use_parameters(type_params)) -> void:
	var parser := TwitchAPIParser.new()
	assert_eq(parser._get_param_type(params[0]), params[1], "for schema %s" % [params[0]])
	parser.client.free()
	parser.free()


## [code]$ref[/code] wins over [code]type[/code], because a schema carrying both
## is describing a reference with a redundant hint.
func test_ref_takes_precedence_over_type() -> void:
	var parser := TwitchAPIParser.new()
	assert_eq(
		parser._get_param_type({"type": "string", "$ref": "#/components/schemas/Thing"}),
		"#/components/schemas/Thing"
	)
	parser.client.free()
	parser.free()

#endregion


#region components

func test_parses_a_standalone_component() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_minimal.json"))

	var component := _harness.find_component("TwitchSampleUser")
	assert_not_null(component, "component should exist after prepare_component prefixes it")
	if component == null:
		return
	assert_eq(component._ref, "#/components/schemas/SampleUser")
	assert_true(component._is_root)
	assert_eq(component._fields.size(), 8)


func test_marks_required_fields() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_minimal.json"))

	var component := _harness.find_component("TwitchSampleUser")
	assert_true(component.get_field_by_name("id")._is_required, "id is in the required list")
	assert_true(component.get_field_by_name("login")._is_required, "login is in the required list")
	assert_false(component.get_field_by_name("view_count")._is_required)


func test_field_order_follows_the_spec() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_minimal.json"))

	var names: PackedStringArray = []
	for field: TwitchGenField in _harness.find_component("TwitchSampleUser")._fields:
		names.append(field._name)

	assert_eq(names, PackedStringArray([
		"id", "login", "view_count", "ratio", "score", "is_live", "raw_settings", "untyped"
	]), "GDScript dictionaries preserve insertion order, so generation is deterministic")


func test_typed_array_field_is_flagged_as_typed() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var data := _harness.find_component("Response").get_field_by_name("data")
	assert_true(data._is_array, "data is an array")
	assert_true(data._is_typed_array, "its items carry a $ref, so elements need from_json")


func test_primitive_array_field_is_array_but_not_typed() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var tags := _harness.find_component("TwitchSampleItem").get_field_by_name("tags")
	assert_true(tags._is_array)
	assert_false(tags._is_typed_array, "string items are appended directly, not parsed")


func test_inline_object_becomes_a_sub_component() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var item := _harness.find_component("TwitchSampleItem")
	assert_true(item._sub_components.has("Badge"), "the inline 'badge' object is promoted to a class")
	var badge: TwitchGenComponent = item._sub_components["Badge"]
	assert_eq(badge._fields.size(), 2)
	assert_eq(badge._ref, "#/components/schemas/SampleItem/Badge")


## [code]allOf[/code] is only inspected one element deep — the parser's own
## comment says "just take the first one to stay insane". Pinned so the
## limitation is visible rather than discovered.
func test_all_of_resolves_to_its_first_ref() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var pagination := _harness.find_component("Response").get_field_by_name("pagination")
	assert_eq(pagination._type, "#/components/schemas/SamplePagination")
	assert_false(pagination._is_array)


func test_pagination_field_switches_on_paging() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	assert_true(
		_harness.find_component("Response")._has_paging,
		"a field literally named 'pagination' is what enables the iterator code"
	)
	assert_false(_harness.find_component("TwitchSampleItem")._has_paging)

#endregion


#region field renaming

## The full [code]TwitchGenField._update_name[/code] table as
## [code][wire name, identifier][/code]. Every entry is a name Twitch sends that
## is illegal or reserved in GDScript.
var rename_params := [
	["animated", "animated_format"],
	["static", "static_format"],
	["1", "_1"],
	["2", "_2"],
	["3", "_3"],
	["4", "_4"],
	["1.5", "_1_5"],
	["100x100", "_100x100"],
	["24x24", "_24x24"],
	["300x200", "_300x200"],
	["source-only", "source_only"],
	["normal_name", "normal_name"],
]


func test_field_rename_table(params = use_parameters(rename_params)) -> void:
	var field := TwitchGenField.new()
	field._name = params[0]
	assert_eq(field._name, params[1], "identifier for wire name '%s'" % params[0])


## The rename is only safe because the wire name is kept alongside it. If
## [code]_original_name[/code] were ever dropped, [code]from_json[/code] would
## read a key Twitch never sends.
func test_original_wire_name_is_preserved(params = use_parameters(rename_params)) -> void:
	var field := TwitchGenField.new()
	field._name = params[0]
	assert_eq(field._original_name, params[0], "wire name must survive the rename")

#endregion


#region methods

func test_parses_an_operation() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var method := _harness.find_method("get_sample_items")
	assert_not_null(method, "operationId hyphens are converted to underscores")
	if method == null:
		return
	assert_eq(method._http_verb, "get")
	assert_eq(method._path, "/sample/items")
	assert_eq(method._summary, "Gets a list of sample items.")
	assert_eq(method._doc_url, "https://example.invalid/docs/get-sample-items")
	assert_eq(method._result_type, "#/components/schemas/GetSampleItemsResponse")


func test_operation_id_hyphens_become_underscores() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))
	assert_null(_harness.find_method("get-sample-items"), "the hyphenated form must not survive")
	assert_not_null(_harness.find_method("get_sample_items"))


func test_splits_required_and_optional_parameters() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var method := _harness.find_method("get_sample_items")
	var required: PackedStringArray = []
	for p: TwitchGenParameter in method._required_parameters:
		required.append(p._name)
	var optional: PackedStringArray = []
	for p: TwitchGenParameter in method._optional_parameters:
		optional.append(p._name)

	assert_eq(required, PackedStringArray(["broadcaster_id", "item_id"]))
	assert_eq(optional, PackedStringArray(["started_at", "first", "after"]))


func test_date_time_parameters_are_flagged() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var method := _harness.find_method("get_sample_items")
	assert_true(method.get_parameter_by_name("started_at")._is_time)
	assert_false(method.get_parameter_by_name("first")._is_time)


func test_array_parameters_are_flagged() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var method := _harness.find_method("get_sample_items")
	assert_true(method.get_parameter_by_name("item_id")._is_array)
	assert_false(method.get_parameter_by_name("broadcaster_id")._is_array)


## Paging hangs off a parameter literally named [code]after[/code], not off
## anything in the response. Both halves have to line up for the iterator code to
## be emitted correctly.
func test_after_parameter_switches_on_paging() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))
	assert_true(_harness.find_method("get_sample_items")._has_paging)


func test_optional_parameters_produce_an_opt_component() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var method := _harness.find_method("get_sample_items")
	assert_true(method._contains_optional)
	assert_eq(method.get_optional_classname(), "GetSampleItemsOpt")
	assert_eq(method.get_optional_type(), "#/components/schemas/GetSampleItemsOpt")


func test_get_without_a_request_body_has_no_body() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))
	assert_false(_harness.find_method("get_sample_items")._contains_body)

#endregion


#region parameter sorting

## [code]TwitchGenParameter.sort[/code] decides generated signature order:
## broadcaster_id last, then required before optional, then alphabetical. Order
## is part of the public API of every generated method, so a change here silently
## breaks callers.
func test_broadcaster_id_sorts_last_even_though_required() -> void:
	var broadcaster := _parameter("broadcaster_id", true)
	var other := _parameter("aaa", true)
	assert_false(TwitchGenParameter.sort(broadcaster, other), "broadcaster_id never sorts first")
	assert_true(TwitchGenParameter.sort(other, broadcaster), "anything else beats broadcaster_id")


func test_required_parameters_sort_before_optional() -> void:
	assert_true(TwitchGenParameter.sort(_parameter("zzz", true), _parameter("aaa", false)))
	assert_false(TwitchGenParameter.sort(_parameter("aaa", false), _parameter("zzz", true)))


func test_equal_priority_parameters_sort_by_name() -> void:
	assert_true(TwitchGenParameter.sort(_parameter("aaa", true), _parameter("bbb", true)))
	assert_false(TwitchGenParameter.sort(_parameter("bbb", true), _parameter("aaa", true)))


## The comparator is applied via [code]sort_custom[/code], which Godot does not
## document as stable. Distinct names make the ordering total, so the result does
## not depend on stability — this asserts that property holds for the fixture.
func test_sort_is_total_for_distinct_names() -> void:
	var a := _parameter("aaa", true)
	var b := _parameter("bbb", true)
	assert_ne(
		TwitchGenParameter.sort(a, b), TwitchGenParameter.sort(b, a),
		"a total order must be antisymmetric, so the result cannot depend on sort stability"
	)


func _parameter(name: String, required: bool) -> TwitchGenParameter:
	var parameter := TwitchGenParameter.new()
	parameter._name = name
	parameter._required = required
	return parameter

#endregion


#region class name sanitisation

## [code]Image[/code] and [code]Panel[/code] would collide with Godot built-ins,
## so the component gets prefixed at assignment time.
func test_classnames_colliding_with_godot_builtins_are_prefixed() -> void:
	var component := TwitchGenComponent.new()
	component._classname = "Image"
	assert_eq(component._classname, "TwitchImage")

	var panel := TwitchGenComponent.new()
	panel._classname = "Panel"
	assert_eq(panel._classname, "TwitchPanel")


func test_other_classnames_pass_through() -> void:
	var component := TwitchGenComponent.new()
	component._classname = "User"
	assert_eq(component._classname, "User")


func test_filename_is_the_snake_cased_root_classname() -> void:
	var component := TwitchGenComponent.new()
	component._classname = "TwitchGetSampleItems"
	assert_eq(component.get_filename(), "twitch_get_sample_items.gd")

#endregion


func _load_spec(file_name: String) -> Dictionary:
	var raw := FileAccess.get_file_as_string(GOLDEN_DIR + file_name)
	assert_ne(raw, "", "missing spec fixture: %s" % file_name)
	return JSON.parse_string(raw) as Dictionary
