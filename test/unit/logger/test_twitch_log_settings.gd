extends TwitcherTest
## Unit tests for [TwitchLogSettings].

var stdout_params: Array = [
	["auto", LogfamiResource.RUNTIME_HEADLESS, LogfamiLevel.Severity.INFO],
	["auto", LogfamiResource.RUNTIME_GAME, LogfamiLevel.OFF],
	["auto", LogfamiResource.RUNTIME_EDITOR, LogfamiLevel.OFF],
	["AUTO", LogfamiResource.RUNTIME_HEADLESS, LogfamiLevel.Severity.INFO],
	["debug", LogfamiResource.RUNTIME_GAME, LogfamiLevel.Severity.DEBUG],
	["off", LogfamiResource.RUNTIME_HEADLESS, LogfamiLevel.OFF],
	["error", LogfamiResource.RUNTIME_EDITOR, LogfamiLevel.Severity.ERROR],
]

## Settings a test changed, with their previous value or null when they didn't
## exist; restored after each test.
var _changed_settings: Dictionary[String, Variant] = {}


func after_each() -> void:
	for key: String in _changed_settings:
		var previous: Variant = _changed_settings[key]
		if previous != null:
			ProjectSettings.set_setting(key, previous)
		elif ProjectSettings.has_setting(key):
			ProjectSettings.clear(key)
	_changed_settings.clear()
	super()


func test_defaults() -> void:
	for key: String in _all_keys():
		_set_setting(key, null)

	var settings: TwitchLogSettings = TwitchLogSettings.from_project()

	assert_eq(settings.file_level, LogfamiLevel.Severity.INFO, "file logging is on by default")
	assert_eq(settings.file_format, TwitchLogSettings.FORMAT_TEXT)
	assert_eq(settings.file_directory, TwitchLogSettings.DEFAULT_FILE_DIRECTORY)
	assert_eq(settings.file_max_lines, 1000)
	assert_eq(settings.file_max_files, 3)
	assert_true(settings.redact)
	var runtime: String = LogfamiResource.detect_runtime()
	assert_eq(settings.runtime, runtime)
	assert_eq(settings.stdout_level,
			TwitchLogSettings.resolve_stdout_level(TwitchLogSettings.AUTO, runtime),
			"stdout defaults to auto, whatever runtime the suite runs in")
	assert_eq(settings.stdout_format, TwitchLogSettings.FORMAT_JSON_LINES)
	assert_false(settings.capture_engine)


func test_from_project_registers_every_setting() -> void:
	for key: String in _all_keys():
		_set_setting(key, null)

	TwitchLogSettings.from_project()

	for key: String in _all_keys():
		assert_true(ProjectSettings.has_setting(key), "missing %s" % key)


func test_reads_configured_values() -> void:
	_set_setting(TwitchLogSettings.FILE_LEVEL, "debug")
	_set_setting(TwitchLogSettings.FILE_FORMAT, "logfmt")
	_set_setting(TwitchLogSettings.FILE_DIRECTORY, "user://support")
	_set_setting(TwitchLogSettings.FILE_MAX_LINES, 50)
	_set_setting(TwitchLogSettings.FILE_MAX_FILES, 5)
	_set_setting(TwitchLogSettings.FILE_REDACT, false)
	_set_setting(TwitchLogSettings.STDOUT_LEVEL, "off")
	_set_setting(TwitchLogSettings.STDOUT_FORMAT, "text")
	_set_setting(TwitchLogSettings.CAPTURE_ENGINE, true)

	var settings: TwitchLogSettings = TwitchLogSettings.from_project()

	assert_eq(settings.file_level, LogfamiLevel.Severity.DEBUG)
	assert_eq(settings.file_format, TwitchLogSettings.FORMAT_LOGFMT)
	assert_eq(settings.file_directory, "user://support")
	assert_eq(settings.file_max_lines, 50)
	assert_eq(settings.file_max_files, 5)
	assert_false(settings.redact)
	assert_eq(settings.stdout_level, LogfamiLevel.OFF)
	assert_eq(settings.stdout_format, TwitchLogSettings.FORMAT_TEXT)
	assert_true(settings.capture_engine)


func test_file_logging_can_be_turned_off() -> void:
	_set_setting(TwitchLogSettings.FILE_LEVEL, "off")
	assert_eq(TwitchLogSettings.from_project().file_level, LogfamiLevel.OFF)


func test_resolve_stdout_level(params: Array = use_parameters(stdout_params)) -> void:
	var text: String = params[0]
	var runtime: String = params[1]
	var expected: int = params[2]
	assert_eq(TwitchLogSettings.resolve_stdout_level(text, runtime), expected,
			"%s in %s" % [text, runtime])


func test_is_editor() -> void:
	var settings: TwitchLogSettings = TwitchLogSettings.new()
	settings.runtime = LogfamiResource.RUNTIME_EDITOR
	assert_true(settings.is_editor())
	settings.runtime = LogfamiResource.RUNTIME_GAME
	assert_false(settings.is_editor())


## Sets [param key], or removes it when [param value] is null, remembering the
## previous state for [method after_each].
func _set_setting(key: String, value: Variant) -> void:
	if not _changed_settings.has(key):
		var previous: Variant = null
		if ProjectSettings.has_setting(key):
			previous = ProjectSettings.get_setting(key)
		_changed_settings[key] = previous
	if value != null:
		ProjectSettings.set_setting(key, value)
	elif ProjectSettings.has_setting(key):
		ProjectSettings.clear(key)


func _all_keys() -> PackedStringArray:
	return PackedStringArray([
		TwitchLogSettings.FILE_LEVEL,
		TwitchLogSettings.FILE_FORMAT,
		TwitchLogSettings.FILE_DIRECTORY,
		TwitchLogSettings.FILE_MAX_LINES,
		TwitchLogSettings.FILE_MAX_FILES,
		TwitchLogSettings.FILE_REDACT,
		TwitchLogSettings.STDOUT_LEVEL,
		TwitchLogSettings.STDOUT_FORMAT,
		TwitchLogSettings.CAPTURE_ENGINE,
	])
