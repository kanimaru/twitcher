extends TwitcherTest
## Unit tests for [TwitchLogger].

const SOURCE_ROOT: String = "res://addons/twitcher/"

## Matches [code]var _log: TwitchLogger[/code] style declarations and captures the
## variable name, so call sites can be checked per file.
const DECLARATION_PATTERN: String = "var\\s+(\\w+)\\s*:\\s*TwitchLogger\\b"

var _capture: LogCapture


func before_each() -> void:
	super()
	TwitchLoggerManager.clear_handlers()
	_capture = LogCapture.new()


func test_warn_level_exists() -> void:
	var logger: TwitchLogger = TwitchLogger.new("GutWarnProbe")
	assert_true(logger.has_method("w"), "TwitchLogger must offer a warn level")


func test_warn_level_can_be_called_while_enabled() -> void:
	var logger: TwitchLogger = TwitchLogger.new("GutWarnProbe", true)
	logger.w("probe")
	pass_test("calling w() on an enabled logger must not raise")


func test_each_level_emits_its_severity() -> void:
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.TRACE)
	var logger: TwitchLogger = TwitchLogger.new("GutLevelProbe")

	logger.d("debug")
	logger.i("info")
	logger.w("warn")
	logger.e("error")

	var severities: Array[int] = []
	for record: Dictionary in _capture.records:
		severities.append(record[TwitchLogRecord.SEVERITY_NUMBER])
	assert_eq(severities, [
		TwitchLogLevel.Severity.DEBUG,
		TwitchLogLevel.Severity.INFO,
		TwitchLogLevel.Severity.WARN,
		TwitchLogLevel.Severity.ERROR,
	] as Array[int])
	assert_eq(_capture.bodies(), PackedStringArray(["debug", "info", "warn", "error"]))


func test_records_carry_the_context_as_scope() -> void:
	TwitchLoggerManager.add_handler(_capture.handle)
	TwitchLogger.new("GutScopeProbe").i("hello")
	assert_eq(_capture.last()[TwitchLogRecord.SCOPE], "GutScopeProbe")


func test_attributes_reach_the_handler() -> void:
	TwitchLoggerManager.add_handler(_capture.handle)
	TwitchLogger.new("GutAttributeProbe").i("refreshed", { "expires_in": 3600 })
	assert_eq(_capture.last()[TwitchLogRecord.ATTRIBUTES], { "expires_in": 3600 })


func test_suffix_becomes_the_instance_attribute() -> void:
	TwitchLoggerManager.add_handler(_capture.handle)
	var logger: TwitchLogger = TwitchLogger.new("GutSuffixProbe")
	logger.set_suffix("main")
	var attributes: Dictionary = { "key": "value" }

	logger.i("joined", attributes)

	assert_eq(logger.suffix, "-main", "the console suffix keeps its legacy form")
	assert_eq(_capture.last()[TwitchLogRecord.ATTRIBUTES], { "key": "value", "instance": "main" })
	assert_false(attributes.has("instance"), "the caller's dictionary must stay untouched")


## The reason handlers exist (#123): a handler like a log file must receive
## messages even when the console output for the context is off.
func test_handler_receives_records_while_the_console_is_off() -> void:
	TwitchLoggerManager.install_console_handler()
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.INFO)
	var logger: TwitchLogger = TwitchLogger.new("GutConsoleOffProbe")
	logger.set_enabled(false)

	logger.i("still recorded")

	assert_eq(_capture.bodies(), PackedStringArray(["still recorded"]))


func test_messages_below_every_threshold_create_no_record() -> void:
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.INFO)
	TwitchLogger.new("GutFilteredProbe").d("dropped")
	assert_eq(_capture.records.size(), 0)


func test_wants_reflects_the_handlers() -> void:
	var logger: TwitchLogger = TwitchLogger.new("GutWantsProbe")
	assert_false(logger.wants(TwitchLogLevel.Severity.FATAL), "no handlers, nothing wanted")

	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.WARN)

	assert_true(logger.wants(TwitchLogLevel.Severity.WARN))
	assert_false(logger.wants(TwitchLogLevel.Severity.INFO))


func test_console_prints_only_when_the_logger_is_enabled() -> void:
	var lines: Array[String] = []
	var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
	var original_printer: Callable = console.printer
	console.printer = func(line: String) -> void:
		lines.append(line)
	TwitchLoggerManager.install_console_handler()
	var logger: TwitchLogger = TwitchLogger.new("GutConsoleProbe")

	logger.set_enabled(false)
	logger.i("hidden")
	logger.set_enabled(true)
	logger.i("shown")
	logger.d("hidden debug")
	console.printer = original_printer

	assert_eq(lines.size(), 1)
	assert_string_contains(lines[0], "[GutConsoleProbe] shown")


func test_logger_methods_work_as_set_logger_callables() -> void:
	TwitchLoggerManager.add_handler(_capture.handle, TwitchLogLevel.Severity.TRACE)
	var logger: TwitchLogger = TwitchLogger.new("GutCallableProbe")
	var error: Callable = logger.e

	error.call("via callable")

	assert_eq(_capture.bodies(), PackedStringArray(["via callable"]))


## Guards against call sites using a logger member that doesn't exist, like the
## [code]_log.w()[/code] call in [TwitchChat] that shipped before the warn level
## existed. GDScript only reports those at runtime, on the exact branch.
func test_every_logger_call_site_uses_an_existing_member() -> void:
	var probe: TwitchLogger = TwitchLogger.new("GutCallSiteProbe")
	var unknown: PackedStringArray = []
	for path: String in _list_scripts(SOURCE_ROOT):
		var source: String = FileAccess.get_file_as_string(path)
		for variable: String in _logger_variables(source):
			for member: String in _members_used(source, variable):
				if not probe.has_method(member) and not member in probe:
					unknown.append("%s: %s.%s" % [path, variable, member])
	assert_eq(unknown.size(), 0, "unknown logger members: " + ", ".join(unknown))


func _logger_variables(source: String) -> PackedStringArray:
	var names: PackedStringArray = []
	var regex: RegEx = RegEx.create_from_string(DECLARATION_PATTERN)
	for result: RegExMatch in regex.search_all(source):
		names.append(result.get_string(1))
	return names


func _members_used(source: String, variable: String) -> PackedStringArray:
	var members: PackedStringArray = []
	var pattern: String = "(?<![\\w.])%s\\.([a-z_]\\w*)" % variable
	var regex: RegEx = RegEx.create_from_string(pattern)
	for result: RegExMatch in regex.search_all(source):
		var member: String = result.get_string(1)
		if not members.has(member):
			members.append(member)
	return members


func _list_scripts(root: String) -> PackedStringArray:
	var scripts: PackedStringArray = []
	var dir: DirAccess = DirAccess.open(root)
	if dir == null:
		return scripts
	for file_name: String in dir.get_files():
		if file_name.ends_with(".gd"):
			scripts.append(root.path_join(file_name))
	for sub_dir: String in dir.get_directories():
		scripts.append_array(_list_scripts(root.path_join(sub_dir)))
	return scripts
