extends TwitcherTest
## Unit tests for [TwitchLogContexts].

const CONTEXT: String = "GutContextProbe"


func after_each() -> void:
	var key: String = TwitchLogContexts.setting_key(CONTEXT)
	if ProjectSettings.has_setting(key):
		ProjectSettings.clear(key)
	super()


func test_setting_key_lives_under_the_logs_group() -> void:
	assert_eq(TwitchLogContexts.setting_key("TwitchAuth"), "twitcher/logs/TwitchAuth")


func test_property_registers_the_setting_as_off() -> void:
	TwitchLogContexts.property_for(CONTEXT)

	assert_true(ProjectSettings.has_setting(TwitchLogContexts.setting_key(CONTEXT)))
	assert_eq(TwitchLogContexts.get_mode(CONTEXT), TwitchLogContexts.MODE_OFF)


func test_mode_of_follows_the_logger_flags() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT)

	assert_eq(TwitchLogContexts.mode_of(logger), "off")
	logger.enabled = true
	assert_eq(TwitchLogContexts.mode_of(logger), "info")
	logger.debug = true
	assert_eq(TwitchLogContexts.mode_of(logger), "debug")


func test_apply_switches_the_logger(params: Array = use_parameters([
	["off", false, false],
	["info", true, false],
	["debug", true, true],
])) -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true, true)

	TwitchLogContexts.apply(logger, params[0])

	assert_eq(logger.enabled, params[1])
	assert_eq(logger.debug, params[2])


func test_apply_ignores_unknown_modes() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT, true, false)
	TwitchLogContexts.apply(logger, "verbose")
	assert_true(logger.enabled)


func test_level_of_maps_modes_to_thresholds() -> void:
	assert_eq(TwitchLogContexts.level_of("off"), LogfamiLevel.OFF)
	assert_eq(TwitchLogContexts.level_of("info"), LogfamiLevel.Severity.INFO)
	assert_eq(TwitchLogContexts.level_of("debug"), LogfamiLevel.Severity.DEBUG)
	assert_eq(TwitchLogContexts.level_of("nonsense"), LogfamiLevel.OFF)


func test_set_mode_stores_the_setting_and_switches_the_logger() -> void:
	var logger: TwitchLogger = TwitchLogger.new(CONTEXT)

	assert_true(TwitchLogContexts.set_mode(CONTEXT, "debug", false))

	assert_eq(ProjectSettings.get_setting(TwitchLogContexts.setting_key(CONTEXT)), "debug")
	assert_eq(TwitchLogContexts.get_mode(CONTEXT), "debug")
	assert_true(logger.enabled)
	assert_true(logger.debug)


func test_set_mode_rejects_unknown_modes_and_empty_contexts() -> void:
	assert_false(TwitchLogContexts.set_mode(CONTEXT, "verbose", false))
	assert_false(TwitchLogContexts.set_mode("", "info", false))
	assert_eq(TwitchLogContexts.override_level(CONTEXT), TwitchLogContexts.NO_OVERRIDE)


func test_set_mode_works_before_the_logger_exists() -> void:
	TwitchLogContexts.set_mode(CONTEXT, "info", false)

	var logger: TwitchLogger = TwitchLogger.new(CONTEXT)

	assert_true(logger.enabled, "the setting enables the logger on registration")
	assert_eq(TwitchLogContexts.get_mode(CONTEXT), "info")


func test_override_level_is_none_until_a_mode_got_set() -> void:
	assert_eq(TwitchLogContexts.override_level(CONTEXT), TwitchLogContexts.NO_OVERRIDE)
	TwitchLogContexts.set_mode(CONTEXT, "info", false)
	assert_eq(TwitchLogContexts.override_level(CONTEXT), LogfamiLevel.Severity.INFO)


## Twitcher has two loggers for "Http"; the registry only keeps the last one, so
## the console has to follow the mode for the other one as well.
func test_set_mode_reaches_loggers_the_registry_does_not_hold() -> void:
	var first: TwitchLogger = TwitchLogger.new(CONTEXT)
	var second: TwitchLogger = TwitchLogger.new(CONTEXT)
	var console: TwitchConsoleLogHandler = TwitchConsoleLogHandler.new()

	TwitchLogContexts.set_mode(CONTEXT, "info", false)

	assert_eq(console.threshold_for(CONTEXT, first), LogfamiLevel.Severity.INFO)
	assert_eq(console.threshold_for(CONTEXT, second), LogfamiLevel.Severity.INFO)

	TwitchLogContexts.set_mode(CONTEXT, "off", false)
	assert_eq(console.threshold_for(CONTEXT, first), LogfamiLevel.OFF)


func test_known_contexts_contain_loggers_and_settings_sorted() -> void:
	TwitchLogger.new("GutKnownLogger")
	TwitchLogContexts.property_for("GutKnownSettingOnly")
	ProjectSettings.set_setting("twitcher/logs/GutKnownNotMode", 42)

	var contexts: PackedStringArray = TwitchLogContexts.known_contexts()

	assert_true(contexts.has("GutKnownLogger"), "registered logger")
	assert_true(contexts.has("GutKnownSettingOnly"), "setting without a logger")
	assert_false(contexts.has("GutKnownNotMode"), "setting that holds no mode")
	var sorted: PackedStringArray = contexts.duplicate()
	sorted.sort()
	assert_eq(contexts, sorted)
	ProjectSettings.clear("twitcher/logs/GutKnownNotMode")
	ProjectSettings.clear("twitcher/logs/GutKnownSettingOnly")


func test_known_contexts_skip_the_file_and_stdout_settings() -> void:
	TwitchLogSettings.from_project()

	var contexts: PackedStringArray = TwitchLogContexts.known_contexts()

	for name: String in ["file", "stdout", "capture_engine", "file/level", "stdout/level"]:
		assert_false(contexts.has(name), name)
