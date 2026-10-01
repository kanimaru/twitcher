extends TwitcherTest
## Enforces the GDScript style rules from CLAUDE.md on folders that already
## follow them. Add a folder to [constant CHECKED_ROOTS] once it's cleaned up.
##
## Checked per line of code (comments and string contents are ignored):
## no [code]:=[/code], no [code]&&[/code] / [code]||[/code], lines under 100
## columns (tabs count 4), no statement after a [code]:[/code] on
## [code]if[/code] / [code]elif[/code] / [code]else[/code] / [code]while[/code]
## lines, and every [code]func[/code] declares a return type.

const CHECKED_ROOTS: PackedStringArray = [
	"res://addons/twitcher/logger/",
	"res://addons/twitcher/lib/logfami/",
	"res://test/unit/logger/",
	"res://test/unit/lib/logfami/",
]

const MAX_COLUMNS: int = 99
const TAB_WIDTH: int = 4


func test_checked_roots_contain_scripts() -> void:
	for root: String in CHECKED_ROOTS:
		assert_gt(_list_scripts(root).size(), 0, "no scripts in %s" % root)


func test_no_inferred_types() -> void:
	_assert_no_code_matching(":=", "uses ':=', declare the type explicitly")


func test_boolean_operators_are_words() -> void:
	_assert_no_code_matching("&&|\\|\\|", "use 'and' / 'or' instead of '&&' / '||'")


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
	var regex: RegEx = RegEx.create_from_string("^\\s*(if|elif|else|while)\\b.*:\\s*\\S")
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
	var start: RegEx = RegEx.create_from_string("^\\s*(static\\s+)?func\\s+\\w+\\s*\\(")
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
			while not signature.strip_edges().ends_with(":") and index + 1 < lines.size():
				index += 1
				signature += _code_of(lines[index])
			if not signature.contains("->") and not signature.contains("@abstract"):
				violations.append("%s:%d" % [path.get_file(), first_line + 1])
			index += 1
	assert_eq(violations.size(), 0, "missing return type: " + ", ".join(violations))


func test_code_of_ignores_strings_and_comments() -> void:
	assert_eq(_code_of("var a: String = \"x := y\" # z := w"), "var a: String = \"\" ")
	assert_eq(_code_of("var b := 1"), "var b := 1", "real code must stay visible")
	assert_eq(_code_of("print('a && b') && c"), "print(\"\") && c")


func _assert_no_code_matching(pattern: String, message: String) -> void:
	var regex: RegEx = RegEx.create_from_string(pattern)
	var violations: PackedStringArray = []
	for path: String in _checked_scripts():
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		for index: int in lines.size():
			if regex.search(_code_of(lines[index])) != null:
				violations.append("%s:%d" % [path.get_file(), index + 1])
	assert_eq(violations.size(), 0, "%s: %s" % [message, ", ".join(violations)])


## The line without string contents and comments, so rules only see code.
func _code_of(line: String) -> String:
	var strings: RegEx = RegEx.create_from_string("\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'")
	var without_strings: String = strings.sub(line, "\"\"", true)
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
	var dir: DirAccess = DirAccess.open(root)
	if dir == null:
		return scripts
	for file_name: String in dir.get_files():
		if file_name.ends_with(".gd"):
			scripts.append(root.path_join(file_name))
	for sub_dir: String in dir.get_directories():
		scripts.append_array(_list_scripts(root.path_join(sub_dir)))
	return scripts
