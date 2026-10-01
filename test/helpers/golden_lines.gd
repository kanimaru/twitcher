class_name GoldenLines
extends RefCounted
## Compares rendered lines against a golden file under [code]test/fixtures/[/code]
## and describes the first difference, so a failing golden test says which
## line broke instead of dumping two whole files.

const FIXTURE_ROOT: String = "res://test/fixtures/"


## Lines of the golden file, without the trailing empty line.
static func read(relative_path: String) -> PackedStringArray:
	var text: String = FileAccess.get_file_as_string(FIXTURE_ROOT.path_join(relative_path))
	var lines: PackedStringArray = text.split("\n")
	if not lines.is_empty() and lines[lines.size() - 1] == "":
		lines.remove_at(lines.size() - 1)
	return lines


## Empty when equal, otherwise a description of the first differing line.
static func first_difference(actual: PackedStringArray, expected: PackedStringArray) -> String:
	for index: int in mini(actual.size(), expected.size()):
		if actual[index] != expected[index]:
			return "line %d differs\n  expected: %s\n  actual:   %s" % [
				index + 1, expected[index], actual[index],
			]
	if actual.size() != expected.size():
		return "expected %d lines, got %d" % [expected.size(), actual.size()]
	return ""
