#!/usr/bin/env -S godot --headless -s
## Regenerates the golden files in [code]test/generator/golden/[/code].
##
## Run after an intentional change to either generator, then [b]read the diff[/b]
## before committing. A golden file you did not review is worse than no golden
## file at all — it turns a regression into a rubber stamp.
##
## [codeblock]
## godot --headless --path . -s res://test/generator/regenerate_goldens.gd
## [/codeblock]
##
## Uses the same [GeneratorHarness] as the test suites, so a golden can never be
## produced by a different code path than the one asserting on it.
@tool
extends SceneTree

const GOLDEN_DIR := "res://test/generator/golden/"

## [code][spec file, flavour, output key, golden file][/code].
##
## Keep in sync with the [code]golden_params[/code] table in
## [code]test/generator/test_golden_files.gd[/code] — the suite asserts that
## every golden file on disk is claimed by a case, so an orphaned golden fails
## the build rather than rotting quietly.
const CASES: Array = [
	["spec_minimal.json", "api", "SampleUser", "api_sample_user.gd.golden"],
	["spec_grouped.json", "api", "GetSampleItems", "api_get_sample_items.gd.golden"],
	["spec_grouped.json", "api", "SampleItem", "api_sample_item.gd.golden"],
	["spec_renamed_fields.json", "api", "SampleRenames", "api_sample_renames.gd.golden"],
	["spec_minimal.json", "eventsub", "SampleUser", "eventsub_sample_user.gd.golden"],
	["spec_renamed_fields.json", "eventsub", "SampleRenames", "eventsub_sample_renames.gd.golden"],
]

## Written from [code]api_code()[/code] rather than a single component.
const API_FACADE_CASE := ["spec_grouped.json", "twitch_api.gd.golden"]


func _init() -> void:
	print("Regenerating goldens in %s" % GOLDEN_DIR)
	var written := 0

	for case: Array in CASES:
		var spec: Dictionary = _load_spec(case[0])
		var harness := GeneratorHarness.new()
		if case[1] == "api":
			await harness.build_api(spec)
		else:
			await harness.build_eventsub(spec)
		_write(case[3], harness.code_for(case[2]))
		harness.dispose()
		written += 1

	var facade_harness := GeneratorHarness.new()
	await facade_harness.build_api(_load_spec(API_FACADE_CASE[0]))
	_write(API_FACADE_CASE[1], facade_harness.api_code())
	facade_harness.dispose()
	written += 1

	print("\n%d golden files written. Review the diff before committing." % written)
	quit(0)


func _load_spec(file_name: String) -> Dictionary:
	var raw := FileAccess.get_file_as_string(GOLDEN_DIR + file_name)
	if raw == "":
		printerr("Could not read spec: %s" % file_name)
		quit(1)
		return {}
	return JSON.parse_string(raw) as Dictionary


func _write(file_name: String, content: String) -> void:
	var path := GOLDEN_DIR + file_name
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("Could not write %s: %s" % [path, error_string(FileAccess.get_open_error())])
		quit(1)
		return
	file.store_string(content)
	file.close()
	print("  wrote %s (%d bytes)" % [file_name, content.length()])
