## Tests for [TwitchEventsubDefinitionGenerator].
##
## Only the parts that don't need the parsed Twitch documentation are covered
## here, the generated code itself is pinned by the golden files in
## [code]test/generator/[/code].
extends TwitcherTest


func _make_generator() -> TwitchEventsubDefinitionGenerator:
	return autofree(TwitchEventsubDefinitionGenerator.new())


## The checked-in definitions are generated, a hand edit to their header that
## the generator doesn't know about would be reverted by the next run.
func test_the_header_matches_the_checked_in_definitions() -> void:
	var checked_in: String = FileAccess.get_file_as_string(
			TwitchEventsubDefinitionGenerator.OUTPUT_PATH)

	assert_true(checked_in.begins_with(_make_generator()._header_code()),
			"twitch_eventsub_definition.gd has to start with the generated header")


func test_generated_definitions_are_reference_counted() -> void:
	assert_string_contains(_make_generator()._header_code(), "\nextends RefCounted\n")
