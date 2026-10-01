extends TwitcherTest
## Unit tests for [LogfamiMemoryFileBackend].

var _backend: LogfamiMemoryFileBackend


func before_each() -> void:
	super()
	_backend = LogfamiMemoryFileBackend.new()


func test_write_needs_an_open_file() -> void:
	assert_false(_backend.write_line("nowhere"))
	assert_true(_backend.open_file("a.log", false))
	assert_true(_backend.write_line("somewhere"))
	assert_eq(_backend.lines_of("a.log"), PackedStringArray(["somewhere"]))


func test_open_replaces_unless_appending() -> void:
	_backend.files["a.log"] = PackedStringArray(["old"])

	_backend.open_file("a.log", true)
	_backend.write_line("appended")
	assert_eq(_backend.lines_of("a.log"), PackedStringArray(["old", "appended"]))

	_backend.open_file("a.log", false)
	assert_eq(_backend.lines_of("a.log"), PackedStringArray())


func test_rename_onto_an_existing_file_fails() -> void:
	_backend.files["a.log"] = PackedStringArray(["a"])
	_backend.files["b.log"] = PackedStringArray(["b"])
	assert_false(_backend.rename("a.log", "b.log"))
	assert_true(_backend.rename("a.log", "c.log"))
	assert_eq(_backend.lines_of("c.log"), PackedStringArray(["a"]))


func test_flush_records_how_many_lines_are_safe() -> void:
	_backend.open_file("a.log", false)
	_backend.write_line("one")
	_backend.flush()
	_backend.write_line("two")
	assert_eq(_backend.flushed_lines["a.log"], 1)


func test_failure_switches() -> void:
	_backend.fail_make_dir = true
	_backend.fail_open = true
	assert_false(_backend.make_dir("logs"))
	assert_false(_backend.open_file("a.log", false))
	_backend.fail_open = false
	_backend.open_file("a.log", false)
	_backend.fail_write = true
	assert_false(_backend.write_line("x"))
