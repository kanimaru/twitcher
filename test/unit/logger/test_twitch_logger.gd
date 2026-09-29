## Unit tests for [TwitchLogger].
extends TwitcherTest

const SOURCE_ROOT: String = "res://addons/twitcher/"

## Matches [code]var _log: TwitchLogger[/code] style declarations and captures the
## variable name, so call sites can be checked per file.
const DECLARATION_PATTERN: String = "var\\s+(\\w+)\\s*:\\s*TwitchLogger\\b"


func test_warn_level_exists() -> void:
	var logger: TwitchLogger = TwitchLogger.new("GutWarnProbe")
	assert_true(logger.has_method("w"), "TwitchLogger must offer a warn level")


func test_warn_level_can_be_called_while_enabled() -> void:
	var logger: TwitchLogger = TwitchLogger.new("GutWarnProbe", true)
	logger.w("probe")
	pass_test("calling w() on an enabled logger must not raise")


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
