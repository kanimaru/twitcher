extends TwitcherTest
## Unit tests for [TwitchLogfamiBridge], against Logfami's in-memory file
## backend so nothing touches the real log folder.

const FILE_PATH: String = "user://logs/twitcher.log"

var _backend: LogfamiMemoryFileBackend
var _settings: TwitchLogSettings
var _stdout: Array[String]
## Settings a test changed, restored after each test like in the settings test.
var _changed_settings: Dictionary[String, Variant] = {}


func before_each() -> void:
	super()
	TwitchLoggerManager.clear_handlers()
	_backend = LogfamiMemoryFileBackend.new()
	_stdout = []
	_settings = TwitchLogSettings.new()
	_settings.runtime = LogfamiResource.RUNTIME_GAME
	_settings.file_level = TwitchLogLevel.Severity.INFO
	_settings.stdout_level = TwitchLogLevel.OFF


func after_each() -> void:
	TwitchLogfamiBridge.uninstall()
	for key: String in _changed_settings:
		var previous: Variant = _changed_settings[key]
		if previous != null:
			ProjectSettings.set_setting(key, previous)
		elif ProjectSettings.has_setting(key):
			ProjectSettings.clear(key)
	_changed_settings.clear()
	super()


func test_twitcher_records_reach_the_log_file() -> void:
	_install()
	var logger: TwitchLogger = TwitchLogger.new("GutBridgeProbe")
	logger.set_suffix("main")

	logger.i("Token got authorized", { "expires_in": 3600 })

	var lines: PackedStringArray = _backend.lines_of(FILE_PATH)
	assert_eq(lines.size(), 2)
	assert_string_starts_with(lines[0], "# session.start ")
	assert_string_contains(lines[0], "twitcher.version=%s" % Twitcher.VERSION)
	assert_string_ends_with(lines[1],
			" INFO  [GutBridgeProbe#main] Token got authorized {expires_in=3600}")


## The point of #123: the file must have the line even when nobody turned on
## the console output for that context.
func test_file_receives_records_while_the_console_is_off() -> void:
	TwitchLoggerManager.install_console_handler()
	_install()
	var logger: TwitchLogger = TwitchLogger.new("GutBridgeConsoleOff")
	logger.set_enabled(false)

	logger.w("Message couldn't be sent")

	assert_string_ends_with(_backend.lines_of(FILE_PATH)[1],
			" WARN  [GutBridgeConsoleOff] Message couldn't be sent")


func test_file_level_filters_records() -> void:
	_install()
	var logger: TwitchLogger = TwitchLogger.new("GutBridgeLevel")

	logger.d("hidden")
	logger.e("shown")

	var lines: PackedStringArray = _backend.lines_of(FILE_PATH)
	assert_eq(lines.size(), 2)
	assert_string_ends_with(lines[1], "shown")


func test_debug_file_level_includes_debug() -> void:
	_settings.file_level = TwitchLogLevel.Severity.DEBUG
	_install()
	TwitchLogger.new("GutBridgeDebug").d("details")
	assert_string_ends_with(_backend.lines_of(FILE_PATH)[1], " DEBUG [GutBridgeDebug] details")


func test_editor_writes_its_own_file() -> void:
	_settings.runtime = LogfamiResource.RUNTIME_EDITOR
	var bridge: TwitchLogfamiBridge = _install()

	TwitchLogger.new("GutBridgeEditor").i("in the editor")

	assert_eq(bridge.file_sink.get_file_path(), "user://logs/twitcher_editor.log")
	assert_eq(_backend.lines_of("user://logs/twitcher_editor.log").size(), 2)
	assert_false(_backend.exists(FILE_PATH), "the game's file stays untouched")


func test_file_settings_reach_the_sink() -> void:
	_settings.file_directory = "user://support"
	_settings.file_max_lines = 1
	_settings.file_max_files = 2
	var bridge: TwitchLogfamiBridge = _install()
	var logger: TwitchLogger = TwitchLogger.new("GutBridgeRotation")

	logger.i("one")
	logger.i("two")
	logger.i("three")

	assert_eq(bridge.file_sink.get_existing_file_paths(), PackedStringArray([
		"user://support/twitcher.log",
		"user://support/twitcher.1.log",
	]))


func test_json_lines_file() -> void:
	_settings.file_format = TwitchLogSettings.FORMAT_JSON_LINES
	var bridge: TwitchLogfamiBridge = _install()

	TwitchLogger.new("GutBridgeJson").i("hello")

	var path: String = "user://logs/twitcher.jsonl"
	assert_eq(bridge.file_sink.get_file_path(), path)
	var record: Dictionary = JSON.parse_string(_backend.lines_of(path)[1])
	assert_eq(record["scope"], "GutBridgeJson")
	assert_false(record.has("resource"), "files carry the resource in the header only")


func test_logfmt_file() -> void:
	_settings.file_format = TwitchLogSettings.FORMAT_LOGFMT
	_install()
	TwitchLogger.new("GutBridgeLogfmt").i("hello")
	assert_string_contains(_backend.lines_of(FILE_PATH)[1], "scope=GutBridgeLogfmt msg=hello")


func test_credentials_are_redacted() -> void:
	_install()
	TwitchLogger.new("GutBridgeRedact").i("PASS oauth:abc123", { "access_token": "abc" })
	var line: String = _backend.lines_of(FILE_PATH)[1]
	assert_false(line.contains("abc123"))
	assert_false(line.contains("=abc"))


func test_redaction_can_be_turned_off() -> void:
	_settings.redact = false
	_install()
	TwitchLogger.new("GutBridgeNoRedact").i("PASS oauth:abc123")
	assert_string_contains(_backend.lines_of(FILE_PATH)[1], "oauth:abc123")


func test_stdout_prints_json_with_the_resource() -> void:
	_settings.file_level = TwitchLogLevel.OFF
	_settings.stdout_level = TwitchLogLevel.Severity.INFO
	var bridge: TwitchLogfamiBridge = _install()
	bridge.stdout_sink.printer = _collect_stdout

	TwitchLogger.new("GutBridgeStdout").i("server started")

	var record: Dictionary = JSON.parse_string(_stdout[0])
	assert_eq(record["body"], "server started")
	assert_eq(record["resource"][TwitchLogfamiBridge.TWITCHER_VERSION_ATTRIBUTE], Twitcher.VERSION)


func test_stdout_replaces_the_console_while_installed() -> void:
	TwitchLoggerManager.install_console_handler()
	var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
	_settings.stdout_level = TwitchLogLevel.Severity.INFO

	_install()
	assert_false(TwitchLoggerManager.has_handler(console.handle), "no duplicate stdout lines")

	TwitchLogfamiBridge.uninstall()
	assert_true(TwitchLoggerManager.has_handler(console.handle), "the console comes back")


func test_uninstall_keeps_a_console_that_was_removed_before() -> void:
	var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
	_settings.stdout_level = TwitchLogLevel.Severity.INFO

	_install()
	TwitchLogfamiBridge.uninstall()

	assert_false(TwitchLoggerManager.has_handler(console.handle))


func test_without_outputs_no_handler_is_added() -> void:
	_settings.file_level = TwitchLogLevel.OFF
	var bridge: TwitchLogfamiBridge = _install()

	assert_null(bridge.file_sink)
	assert_null(bridge.stdout_sink)
	assert_eq(TwitchLoggerManager.handler_count(), 0)
	assert_eq(TwitchLogfamiBridge.get_log_file_path(), "")


func test_handler_level_is_the_lowest_output_level() -> void:
	_settings.file_level = TwitchLogLevel.Severity.WARN
	_settings.stdout_level = TwitchLogLevel.Severity.DEBUG
	_install()
	assert_true(TwitchLoggerManager.wants("Any", TwitchLogLevel.Severity.DEBUG))
	assert_false(TwitchLoggerManager.wants("Any", TwitchLogLevel.Severity.TRACE))


func test_install_replaces_the_previous_bridge() -> void:
	var first: TwitchLogfamiBridge = _install()
	var second: TwitchLogfamiBridge = _install()

	assert_same(TwitchLogfamiBridge.get_instance(), second)
	assert_ne(first, second)
	assert_eq(TwitchLoggerManager.handler_count(), 1)


func test_uninstall_detaches_and_closes_the_file() -> void:
	_install()
	TwitchLogfamiBridge.uninstall()

	TwitchLogger.new("GutBridgeGone").e("after uninstall")

	assert_null(TwitchLogfamiBridge.get_instance())
	assert_eq(TwitchLoggerManager.handler_count(), 0)
	assert_eq(_backend.open_path, "", "the file must be closed")
	assert_eq(_backend.lines_of(FILE_PATH).size(), 1, "only the header")


func test_engine_errors_are_captured_when_enabled() -> void:
	_settings.capture_engine = true
	var bridge: TwitchLogfamiBridge = _install()

	push_warning("bridge capture probe")

	assert_push_warning("bridge capture probe")
	assert_true(bridge.engine_capture.is_installed())
	assert_string_contains(_backend.lines_of(FILE_PATH)[1], "[godot] bridge capture probe")

	TwitchLogfamiBridge.uninstall()
	assert_false(bridge.engine_capture.is_installed())


func test_engine_capture_is_off_by_default() -> void:
	assert_null(_install().engine_capture)


func test_log_paths() -> void:
	_install()
	assert_eq(TwitchLogfamiBridge.get_log_file_path(), ProjectSettings.globalize_path(FILE_PATH))
	assert_eq(TwitchLogfamiBridge.get_log_folder_path(),
			ProjectSettings.globalize_path("user://logs"))


func test_log_folder_without_bridge_comes_from_the_settings() -> void:
	_set_setting(TwitchLogSettings.FILE_DIRECTORY, "user://support")
	assert_eq(TwitchLogfamiBridge.get_log_folder_path(),
			ProjectSettings.globalize_path("user://support"))


func test_install_once_respects_auto_install() -> void:
	TwitchLogfamiBridge.auto_install = false
	TwitchLogfamiBridge.install_once()
	assert_null(TwitchLogfamiBridge.get_instance())


func test_first_log_call_installs_from_the_project_settings() -> void:
	_set_setting(TwitchLogSettings.FILE_LEVEL, "off")
	_set_setting(TwitchLogSettings.STDOUT_LEVEL, "off")
	TwitchLogfamiBridge.auto_install = true
	var logger: TwitchLogger = TwitchLogger.new("GutBridgeAutoInstall")
	assert_null(TwitchLogfamiBridge.get_instance(), "creating a logger doesn't install")

	logger.i("first call")

	var bridge: TwitchLogfamiBridge = TwitchLogfamiBridge.get_instance()
	assert_not_null(bridge)
	assert_eq(bridge.settings.file_level, TwitchLogLevel.OFF)


## Static loggers register while scripts load, long before an autoload's
## _init can run. The opt-out must still work after that.
func test_auto_install_can_be_turned_off_after_loggers_exist() -> void:
	_set_setting(TwitchLogSettings.FILE_LEVEL, "off")
	_set_setting(TwitchLogSettings.STDOUT_LEVEL, "off")
	TwitchLogfamiBridge.auto_install = true
	var logger: TwitchLogger = TwitchLogger.new("GutBridgeLateOptOut")

	TwitchLogfamiBridge.auto_install = false
	logger.i("logged without a bridge")

	assert_null(TwitchLogfamiBridge.get_instance())


func test_uninstall_turns_auto_install_off() -> void:
	_set_setting(TwitchLogSettings.FILE_LEVEL, "off")
	_set_setting(TwitchLogSettings.STDOUT_LEVEL, "off")
	TwitchLogfamiBridge.auto_install = true
	var logger: TwitchLogger = TwitchLogger.new("GutBridgeUninstall")
	logger.i("installs")
	assert_not_null(TwitchLogfamiBridge.get_instance())

	TwitchLogfamiBridge.uninstall()
	logger.i("must not reinstall")

	assert_false(TwitchLogfamiBridge.auto_install)
	assert_null(TwitchLogfamiBridge.get_instance())


func test_install_once_keeps_an_installed_bridge() -> void:
	var installed: TwitchLogfamiBridge = _install()
	TwitchLogfamiBridge.auto_install = true
	TwitchLogfamiBridge.install_once()
	assert_same(TwitchLogfamiBridge.get_instance(), installed)


func _install() -> TwitchLogfamiBridge:
	return TwitchLogfamiBridge.install(_settings, _backend, LogfamiFixedClock.new())


func _collect_stdout(line: String) -> void:
	_stdout.append(line)


func _set_setting(key: String, value: Variant) -> void:
	if not _changed_settings.has(key):
		var previous: Variant = null
		if ProjectSettings.has_setting(key):
			previous = ProjectSettings.get_setting(key)
		_changed_settings[key] = previous
	ProjectSettings.set_setting(key, value)
