extends TwitcherTest
## Unit tests for [LogfamiFsFileBackend], on the real filesystem inside the
## test's scratch directory.

var _backend: LogfamiFsFileBackend
var _dir: String


func before_each() -> void:
	super()
	_backend = LogfamiFsFileBackend.new()
	_dir = scratch_dir()


func after_each() -> void:
	_backend.close()
	super()


func test_writes_lines_to_disk() -> void:
	var path: String = _dir.path_join("app.log")
	assert_true(_backend.open_file(path, false))
	_backend.write_line("one")
	_backend.write_line("two")
	_backend.close()
	assert_eq(FileAccess.get_file_as_string(path), "one\ntwo\n")


func test_append_keeps_existing_lines() -> void:
	var path: String = _dir.path_join("app.log")
	_backend.open_file(path, false)
	_backend.write_line("first session")
	_backend.open_file(path, true)
	_backend.write_line("second session")
	_backend.close()
	assert_eq(FileAccess.get_file_as_string(path), "first session\nsecond session\n")


func test_open_without_append_replaces_the_file() -> void:
	var path: String = _dir.path_join("app.log")
	_backend.open_file(path, false)
	_backend.write_line("old")
	_backend.open_file(path, false)
	_backend.write_line("new")
	_backend.close()
	assert_eq(FileAccess.get_file_as_string(path), "new\n")


func test_rename_remove_and_exists() -> void:
	var path: String = _dir.path_join("app.log")
	var moved: String = _dir.path_join("app.1.log")
	_backend.open_file(path, false)
	_backend.close()

	assert_true(_backend.exists(path))
	assert_true(_backend.rename(path, moved))
	assert_false(_backend.exists(path))
	assert_true(_backend.remove(moved))
	assert_false(_backend.exists(moved))


func test_rename_onto_an_existing_file_fails() -> void:
	var first: String = _dir.path_join("a.log")
	var second: String = _dir.path_join("b.log")
	_backend.open_file(first, false)
	_backend.open_file(second, false)
	_backend.close()
	assert_false(_backend.rename(first, second))


func test_make_dir_creates_parents() -> void:
	var nested: String = _dir.path_join("deep/er/logs")
	assert_true(_backend.make_dir(nested))
	assert_true(DirAccess.dir_exists_absolute(nested))
	assert_true(_backend.make_dir(nested), "an existing directory is fine")


func test_write_without_open_file_fails() -> void:
	assert_false(_backend.write_line("nowhere"))
