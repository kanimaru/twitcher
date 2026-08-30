## Golden-file (snapshot) tests for the two code generators.
##
## Twitcher ships ~44 000 lines across 289 generated files. Testing that output
## directly would mean 289 test scripts that all say the same thing. Testing the
## two generators that produce it costs three small OpenAPI fixtures and covers
## the lot.
##
## Each case feeds a fixture spec through [GeneratorHarness] and compares the
## emitted source against a checked-in [code].golden[/code] file. Any change to a
## template, a type mapping or the naming rules shows up as a readable diff in
## review.
##
## [b]When a golden legitimately changes:[/b]
##
## [codeblock]
## godot --headless --path . -s res://test/generator/regenerate_goldens.gd
## [/codeblock]
##
## Then read the diff. A golden regenerated without being read converts a
## regression into a rubber stamp.
extends TwitcherTest

const GOLDEN_DIR := "res://test/generator/golden/"

var _harness: GeneratorHarness

## [code][spec, flavour, output key, golden file][/code]. Mirrors
## [code]regenerate_goldens.gd[/code]'s CASES;
## [method test_every_golden_file_is_claimed_by_a_case] keeps the two honest.
var golden_params := [
	["spec_minimal.json", "api", "SampleUser", "api_sample_user.gd.golden"],
	["spec_grouped.json", "api", "GetSampleItems", "api_get_sample_items.gd.golden"],
	["spec_grouped.json", "api", "SampleItem", "api_sample_item.gd.golden"],
	["spec_renamed_fields.json", "api", "SampleRenames", "api_sample_renames.gd.golden"],
	["spec_minimal.json", "eventsub", "SampleUser", "eventsub_sample_user.gd.golden"],
	["spec_renamed_fields.json", "eventsub", "SampleRenames", "eventsub_sample_renames.gd.golden"],
]


func after_each() -> void:
	if _harness != null:
		_harness.dispose()
		_harness = null
	super()


func test_generated_output_matches_golden(params = use_parameters(golden_params)) -> void:
	var spec_file: String = params[0]
	var flavour: String = params[1]
	var key: String = params[2]
	var golden_file: String = params[3]

	_harness = GeneratorHarness.new()
	if flavour == "api":
		await _harness.build_api(_load_spec(spec_file))
	else:
		await _harness.build_eventsub(_load_spec(spec_file))

	var actual := _harness.code_for(key)
	var expected := _read_golden(golden_file)

	if actual == expected:
		pass_test("%s matches" % golden_file)
		return

	fail_test("%s differs from generated output.\n%s\n\nRegenerate with:\n  godot --headless --path . -s res://test/generator/regenerate_goldens.gd" % [
		golden_file, _first_difference(expected, actual)
	])


func test_twitch_api_facade_matches_golden() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	var actual := _harness.api_code()
	var expected := _read_golden("twitch_api.gd.golden")

	if actual == expected:
		pass_test("twitch_api.gd.golden matches")
		return
	fail_test("twitch_api.gd.golden differs.\n%s" % _first_difference(expected, actual))


## Guards against a golden that no case reads any more. Without this, deleting a
## case leaves a stale file that looks like coverage but asserts nothing.
func test_every_golden_file_is_claimed_by_a_case() -> void:
	var claimed: Dictionary[String, bool] = {"twitch_api.gd.golden": true}
	for case: Array in golden_params:
		claimed[case[3]] = true

	var orphans: PackedStringArray = []
	for file: String in DirAccess.get_files_at(GOLDEN_DIR):
		if file.ends_with(".golden") and not claimed.has(file):
			orphans.append(file)

	assert_eq(
		orphans.size(), 0,
		"golden files no test reads: " + ", ".join(orphans)
	)


func test_every_spec_fixture_is_used_by_a_case() -> void:
	var used: Dictionary[String, bool] = {"spec_grouped.json": true}
	for case: Array in golden_params:
		used[case[0]] = true

	var unused: PackedStringArray = []
	for file: String in DirAccess.get_files_at(GOLDEN_DIR):
		if file.ends_with(".json") and not used.has(file):
			unused.append(file)

	assert_eq(unused.size(), 0, "spec fixtures no test uses: " + ", ".join(unused))


## The generator writes one file per entry in [code]grouped_files[/code], named
## from the class name. Pinning the file set catches a component being dropped or
## a naming rule changing without a golden of its own.
func test_grouped_spec_produces_the_expected_file_set() -> void:
	_harness = GeneratorHarness.new()
	await _harness.build_api(_load_spec("spec_grouped.json"))

	assert_eq(
		_harness.output_filenames(),
		PackedStringArray([
			"twitch_get_sample_items.gd",
			"twitch_sample_item.gd",
			"twitch_sample_pagination.gd",
		])
	)


#region helpers

func _load_spec(file_name: String) -> Dictionary:
	var raw := FileAccess.get_file_as_string(GOLDEN_DIR + file_name)
	assert_ne(raw, "", "missing spec fixture: %s" % file_name)
	return JSON.parse_string(raw) as Dictionary


func _read_golden(file_name: String) -> String:
	var path := GOLDEN_DIR + file_name
	if not FileAccess.file_exists(path):
		fail_test("missing golden file: %s — run regenerate_goldens.gd" % path)
		return ""
	return FileAccess.get_file_as_string(path)


## A whole-file diff of generated source is unreadable in a test log. This
## reports the first differing line with a little context, which is what you
## actually need to see.
func _first_difference(expected: String, actual: String) -> String:
	var expected_lines := expected.split("\n")
	var actual_lines := actual.split("\n")
	var limit: int = min(expected_lines.size(), actual_lines.size())

	for i: int in limit:
		if expected_lines[i] == actual_lines[i]:
			continue
		var context: PackedStringArray = []
		for j: int in range(max(0, i - 2), i):
			context.append("   %4d | %s" % [j + 1, expected_lines[j]])
		context.append("-> %4d | expected: %s" % [i + 1, expected_lines[i]])
		context.append("   %4s | actual:   %s" % ["", actual_lines[i]])
		return "\n".join(context)

	return "identical for %d lines, then lengths differ (expected %d lines, got %d)" % [
		limit, expected_lines.size(), actual_lines.size()
	]

#endregion
