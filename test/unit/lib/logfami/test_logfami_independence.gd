extends TwitcherTest
## Logfami is a standalone library: it must work in any Godot project, without
## Twitcher or any other addon. This scans its sources for references that
## would break that.

const LIBRARY_ROOT: String = "res://addons/twitcher/lib/logfami/"

## Identifiers that would tie Logfami to Twitcher or its sibling libraries.
const FORBIDDEN_PATTERNS: PackedStringArray = [
	"\\bTwitch\\w*",
	"twitcher/",
	"\\bHttpUtil\\b",
	"\\bBufferedHTTPClient\\b",
	"\\bOAuth[A-Z]\\w*",
	"\\bOAuth\\s*[.(]",
	":\\s*OAuth\\b",
	"ProjectSettings\\.set",
]


func test_library_has_sources() -> void:
	assert_gt(_list_scripts(LIBRARY_ROOT).size(), 0, "scan must not pass on an empty folder")


func test_library_references_nothing_outside_itself() -> void:
	var hits: PackedStringArray = []
	for path: String in _list_scripts(LIBRARY_ROOT):
		var source: String = FileAccess.get_file_as_string(path)
		for pattern: String in FORBIDDEN_PATTERNS:
			var regex: RegEx = RegEx.create_from_string(pattern)
			for result: RegExMatch in regex.search_all(source):
				hits.append("%s: %s" % [path.get_file(), result.get_string()])
	assert_eq(hits.size(), 0, "Logfami must stay standalone: " + ", ".join(hits))


func test_every_class_is_prefixed() -> void:
	var regex: RegEx = RegEx.create_from_string("(?m)^class_name\\s+(\\w+)")
	var unprefixed: PackedStringArray = []
	for path: String in _list_scripts(LIBRARY_ROOT):
		var found: RegExMatch = regex.search(FileAccess.get_file_as_string(path))
		if found != null and not found.get_string(1).begins_with("Logfami"):
			unprefixed.append(found.get_string(1))
	assert_eq(unprefixed.size(), 0,
			"class names need the Logfami prefix: " + ", ".join(unprefixed))


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
