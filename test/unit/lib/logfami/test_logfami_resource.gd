extends TwitcherTest
## Unit tests for [LogfamiResource].


func test_detect_fills_the_standard_attributes() -> void:
	var resource: LogfamiResource = LogfamiResource.detect()

	for key: String in [
		LogfamiResource.SERVICE_NAME,
		LogfamiResource.SERVICE_VERSION,
		LogfamiResource.GODOT_VERSION,
		LogfamiResource.OS_TYPE,
		LogfamiResource.PROCESS_PID,
		LogfamiResource.RUNTIME,
	]:
		assert_true(resource.attributes.has(key), "missing '%s'" % key)
	assert_eq(resource.get_attribute(LogfamiResource.OS_TYPE), OS.get_name().to_lower())
	assert_eq(resource.get_attribute(LogfamiResource.PROCESS_PID), OS.get_process_id())


func test_service_name_comes_from_the_project() -> void:
	var expected: String = str(ProjectSettings.get_setting("application/config/name", ""))
	if expected == "":
		expected = "godot-app"
	assert_eq(LogfamiResource.detect().get_attribute(LogfamiResource.SERVICE_NAME), expected)


func test_tests_run_headless() -> void:
	assert_eq(LogfamiResource.detect_runtime(), LogfamiResource.RUNTIME_HEADLESS)


func test_with_attribute_returns_a_copy() -> void:
	var resource: LogfamiResource = LogfamiResource.new({ "a": 1 })

	var extended: LogfamiResource = resource.with_attribute("b", 2)

	assert_eq(extended.attributes, { "a": 1, "b": 2 })
	assert_eq(resource.attributes, { "a": 1 }, "the original must stay untouched")


func test_constructor_copies_the_attributes() -> void:
	var attributes: Dictionary = { "a": 1 }
	var resource: LogfamiResource = LogfamiResource.new(attributes)
	attributes["a"] = 2
	assert_eq(resource.get_attribute("a"), 1)


func test_get_attribute_default() -> void:
	assert_eq(LogfamiResource.new().get_attribute("missing", "fallback"), "fallback")
