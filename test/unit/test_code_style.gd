extends TwitcherTest
## Enforces the GDScript style rules from CLAUDE.md on folders that already
## follow them. Add a folder to [constant CHECKED_ROOTS] once it's cleaned up.
##
## Checked per line of code (comments and string contents are ignored):
## no [code]:=[/code], no [code]&&[/code] / [code]||[/code] / [code]![/code],
## lines under 100 columns (tabs count 4), no statement after a [code]:[/code]
## on [code]if[/code] / [code]elif[/code] / [code]else[/code] / [code]for[/code]
## / [code]while[/code] lines, and every [code]func[/code] declares a return
## type. Member order isn't checked.

## Folders (recursive) and single scripts.
const CHECKED_ROOTS: PackedStringArray = [
	"res://addons/twitcher/logger/",
	"res://addons/twitcher/lib/logfami/",
	"res://addons/twitcher/editor/logs/",
	"res://test/unit/logger/",
	"res://test/unit/lib/logfami/",
	"res://test/unit/editor/logs/",
	"res://test/fixtures/logfami/",
	"res://test/helpers/log_capture.gd",
	"res://test/helpers/golden_lines.gd",
	"res://test/unit/test_code_style.gd",
	"res://test/unit/test_twitcher.gd",
]

const MAX_COLUMNS: int = 99
const TAB_WIDTH: int = 4

var _strings: RegEx = RegEx.create_from_string("\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'")


func test_checked_roots_contain_scripts() -> void:
	for root: String in CHECKED_ROOTS:
		assert_gt(_list_scripts(root).size(), 0, "no scripts in %s" % root)


func test_no_inferred_types() -> void:
	_assert_no_code_matching(":=", "uses ':=', declare the type explicitly")


func test_boolean_operators_are_words() -> void:
	_assert_no_code_matching("&&|\\|\\|", "use 'and' / 'or' instead of '&&' / '||'")
	_assert_no_code_matching("(?<![=!<>])!(?!=)", "use 'not' instead of '!'")


func test_lines_stay_under_one_hundred_columns() -> void:
	var violations: PackedStringArray = []
	for path: String in _checked_scripts():
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		for index: int in lines.size():
			var width: int = lines[index].replace("\t", " ".repeat(TAB_WIDTH)).length()
			if width > MAX_COLUMNS:
				violations.append("%s:%d (%d)" % [path.get_file(), index + 1, width])
	assert_eq(violations.size(), 0, "lines too long: " + ", ".join(violations))


func test_one_statement_per_line() -> void:
	# A `for` line may carry a typed loop variable, so its colon must follow `in`.
	var regex: RegEx = RegEx.create_from_string(
			"^\\s*((if|elif|else|while)\\b.*|for\\b.*\\bin\\b.*):\\s*\\S")
	var violations: PackedStringArray = []
	for path: String in _checked_scripts():
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		for index: int in lines.size():
			var code: String = _code_of(lines[index])
			if code.strip_edges().ends_with(":"):
				continue
			if regex.search(code) != null:
				violations.append("%s:%d" % [path.get_file(), index + 1])
	assert_eq(violations.size(), 0, "statement after ':' on: " + ", ".join(violations))


func test_functions_declare_a_return_type() -> void:
	var start: RegEx = RegEx.create_from_string(
			"^\\s*(@abstract\\s+)?(static\\s+)?func\\s+\\w+\\s*\\(")
	var violations: PackedStringArray = []
	for path: String in _checked_scripts():
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		var index: int = 0
		while index < lines.size():
			if start.search(lines[index]) == null:
				index += 1
				continue
			var first_line: int = index
			var signature: String = _code_of(lines[index])
			var is_abstract: bool = signature.contains("@abstract")
			while not _is_signature_complete(signature, is_abstract) and index + 1 < lines.size():
				index += 1
				signature += _code_of(lines[index])
			if not signature.contains("->"):
				violations.append("%s:%d" % [path.get_file(), first_line + 1])
			index += 1
	assert_eq(violations.size(), 0, "missing return type: " + ", ".join(violations))


func test_code_of_ignores_strings_and_comments() -> void:
	assert_eq(_code_of("var a: String = \"x := y\" # z := w"), "var a: String = \"\" ")
	assert_eq(_code_of("var b := 1"), "var b := 1", "real code must stay visible")
	assert_eq(_code_of("print('a && b') && c"), "print(\"\") && c")


func test_not_operator_pattern() -> void:
	var regex: RegEx = RegEx.create_from_string("(?<![=!<>])!(?!=)")
	assert_not_null(regex.search("if !done:"), "'!' is flagged")
	assert_null(regex.search("if a != b:"), "'!=' is fine")
	assert_null(regex.search("assert_true(!= 0)"), "'!=' after a space is fine")


func test_one_statement_pattern_allows_typed_loop_variables() -> void:
	var regex: RegEx = RegEx.create_from_string(
			"^\\s*((if|elif|else|while)\\b.*|for\\b.*\\bin\\b.*):\\s*\\S")
	assert_null(regex.search("for key: String in keys:"), "typed loop variable")
	assert_not_null(regex.search("for key in keys: print(key)"), "one-line for")
	assert_not_null(regex.search("if done: return"), "one-line if")


func test_abstract_functions_are_checked() -> void:
	var start: RegEx = RegEx.create_from_string(
			"^\\s*(@abstract\\s+)?(static\\s+)?func\\s+\\w+\\s*\\(")
	assert_not_null(start.search("@abstract func process(record: LogfamiRecord) -> LogfamiRecord"))
	assert_true(_is_signature_complete("@abstract func f() -> int", true))
	assert_false(_is_signature_complete("func f(", false))


func _assert_no_code_matching(pattern: String, message: String) -> void:
	var regex: RegEx = RegEx.create_from_string(pattern)
	var violations: PackedStringArray = []
	for path: String in _checked_scripts():
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		for index: int in lines.size():
			if regex.search(_code_of(lines[index])) != null:
				violations.append("%s:%d" % [path.get_file(), index + 1])
	assert_eq(violations.size(), 0, "%s: %s" % [message, ", ".join(violations)])


## An abstract function has no body, so its signature ends without a colon.
func _is_signature_complete(signature: String, is_abstract: bool) -> bool:
	var trimmed: String = signature.strip_edges()
	if is_abstract:
		return trimmed.contains(")") and not trimmed.ends_with(",")
	return trimmed.ends_with(":")


## The line without string contents and comments, so rules only see code.
func _code_of(line: String) -> String:
	var without_strings: String = _strings.sub(line, "\"\"", true)
	var comment_start: int = without_strings.find("#")
	if comment_start >= 0:
		return without_strings.substr(0, comment_start)
	return without_strings


func _checked_scripts() -> PackedStringArray:
	var scripts: PackedStringArray = []
	for root: String in CHECKED_ROOTS:
		scripts.append_array(_list_scripts(root))
	return scripts


func _list_scripts(root: String) -> PackedStringArray:
	var scripts: PackedStringArray = []
	if root.ends_with(".gd"):
		if FileAccess.file_exists(root):
			scripts.append(root)
		return scripts
	var dir: DirAccess = DirAccess.open(root)
	if dir == null:
		return scripts
	for file_name: String in dir.get_files():
		if file_name.ends_with(".gd"):
			scripts.append(root.path_join(file_name))
	for sub_dir: String in dir.get_directories():
		scripts.append_array(_list_scripts(root.path_join(sub_dir)))
	return scripts
