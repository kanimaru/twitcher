extends TwitcherTest
## Unit tests for [LogfamiFileSinkConfig] defaults: one session file of 1000
## lines plus two older ones, flushed on every line.


func test_defaults() -> void:
	var config: LogfamiFileSinkConfig = LogfamiFileSinkConfig.new()
	assert_eq(config.directory, "user://logs")
	assert_eq(config.max_lines, 1000)
	assert_eq(config.max_files, 3)
	assert_true(config.rotate_on_start)
	assert_eq(config.flush_policy, LogfamiFileSinkConfig.FlushPolicy.EVERY_LINE)
	assert_eq(config.flush_level, LogfamiLevel.Severity.WARN)


func test_survives_a_save_and_load() -> void:
	var config: LogfamiFileSinkConfig = LogfamiFileSinkConfig.new()
	config.base_name = "my_game"
	config.max_lines = 250
	var path: String = scratch_path("config.tres")

	assert_eq(ResourceSaver.save(config, path), OK)
	var loaded: LogfamiFileSinkConfig = ResourceLoader.load(
			path, "", ResourceLoader.CACHE_MODE_IGNORE) as LogfamiFileSinkConfig

	assert_eq(loaded.base_name, "my_game")
	assert_eq(loaded.max_lines, 250)
