## Base class for every Twitcher test.
##
## Extend this instead of [code]GutTest[/code] directly. It provides:
##
## [b]Isolation.[/b] A [StaticStateGuard] snapshots process-global state before
## each test and restores it after, so suites cannot contaminate one another.
##
## [b]A sandboxed scratch directory.[/b] [method scratch_path] hands out unique
## [code]user://[/code] paths per test, which is what Twitcher's token cache,
## encryption key store and media cache need in order to stay off the developer's
## real filesystem.
##
## [b]Fixture loading.[/b] [method fixture_text] and [method fixture_json] read
## from [code]test/fixtures/[/code] so captured Twitch payloads live as data
## files rather than inline string literals.
##
## Subclasses that override [method before_each] or [method after_each] MUST
## call [code]super()[/code] — the guard is installed there.
class_name TwitcherTest
extends GutTest

const FIXTURE_ROOT := "res://test/fixtures/"
const SCRATCH_ROOT := "user://gut_scratch/"

var _guard: StaticStateGuard
var _scratch_counter := 0
var _scratch_dirs: PackedStringArray = []


func before_each() -> void:
	_guard = StaticStateGuard.new()
	_guard.snapshot()
	_scratch_counter = 0
	_scratch_dirs = []


func after_each() -> void:
	_clear_scratch()
	if _guard != null:
		_guard.restore()
		_guard = null


#region Scratch filesystem

## Returns a unique, empty directory under [code]user://[/code] for this test,
## removed automatically in [method after_each].
##
## Use this for anything that writes to disk — [code]OAuthToken._cache_path[/code],
## [code]CryptoKeyProvider.encrpytion_secret_location[/code], the media loader's
## [code]cache_*[/code] exports.
func scratch_dir() -> String:
	_scratch_counter += 1
	var path := "%s%s_%d/" % [SCRATCH_ROOT, _clean_name(), _scratch_counter]
	DirAccess.make_dir_recursive_absolute(path)
	_scratch_dirs.append(path)
	return path


## Returns a unique file path inside a fresh [method scratch_dir]. The file is
## not created; only its parent directory is.
func scratch_path(file_name: String) -> String:
	return scratch_dir().path_join(file_name)


func _clear_scratch() -> void:
	for dir: String in _scratch_dirs:
		_remove_recursive(dir)
	_scratch_dirs = []


func _remove_recursive(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var child := path.path_join(entry)
		if dir.current_is_dir():
			_remove_recursive(child + "/")
		else:
			DirAccess.remove_absolute(child)
		entry = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)


func _clean_name() -> String:
	return get_script().resource_path.get_file().get_basename()

#endregion


#region Fixtures

## Reads a text fixture from [code]test/fixtures/[/code], failing the test with a
## useful message rather than returning an empty string if it is missing.
func fixture_text(relative_path: String) -> String:
	var path := FIXTURE_ROOT.path_join(relative_path)
	if not FileAccess.file_exists(path):
		fail_test("Missing fixture: %s" % path)
		return ""
	return FileAccess.get_file_as_string(path)


## Reads and parses a JSON fixture. Fails the test on malformed JSON so a broken
## fixture reports as a fixture problem rather than a mysterious null deref.
func fixture_json(relative_path: String) -> Variant:
	var raw := fixture_text(relative_path)
	if raw == "":
		return null
	var parsed: Variant = JSON.parse_string(raw)
	if parsed == null:
		fail_test("Fixture is not valid JSON: %s" % relative_path)
	return parsed


## Reads a fixture of newline-delimited records, dropping blank lines and
## [code]#[/code] comments. Used for the captured IRC line corpus.
func fixture_lines(relative_path: String) -> PackedStringArray:
	var out := PackedStringArray()
	for line: String in fixture_text(relative_path).split("\n"):
		var trimmed := line.strip_edges()
		if trimmed == "" or trimmed.begins_with("#"):
			continue
		out.append(trimmed)
	return out

#endregion


#region Assertions

## Asserts that [param actual] contains every key of [param expected] with equal
## values, ignoring extra keys in [param actual].
##
## Useful for round-trip tests against captured Twitch payloads, where the DTO
## legitimately adds fields the wire format did not carry.
func assert_has_entries(actual: Dictionary, expected: Dictionary, text := "") -> void:
	var missing: PackedStringArray = []
	var wrong: PackedStringArray = []
	for key: Variant in expected:
		if not actual.has(key):
			missing.append(str(key))
		elif actual[key] != expected[key]:
			wrong.append("%s (expected %s, got %s)" % [key, expected[key], actual[key]])

	if missing.is_empty() and wrong.is_empty():
		pass_test(text if text != "" else "has all expected entries")
		return

	var parts: PackedStringArray = []
	if not missing.is_empty():
		parts.append("missing keys: " + ", ".join(missing))
	if not wrong.is_empty():
		parts.append("wrong values: " + ", ".join(wrong))
	fail_test("%s%s" % [text + " — " if text != "" else "", " / ".join(parts)])


## Asserts that [param value] matches [param pattern] as a regular expression.
func assert_matches(value: String, pattern: String, text := "") -> void:
	var regex := RegEx.create_from_string(pattern)
	assert_not_null(regex, "Test bug: invalid regex %s" % pattern)
	if regex == null:
		return
	if regex.search(value) != null:
		pass_test(text if text != "" else "%s matches %s" % [value, pattern])
	else:
		fail_test("%sExpected [%s] to match [%s]" % [text + " — " if text != "" else "", value, pattern])

#endregion
