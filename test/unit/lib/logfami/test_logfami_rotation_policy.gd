extends TwitcherTest
## Unit tests for [LogfamiRotationPolicy].

const BASE: String = "user://logs/app.log"

var _backend: LogfamiMemoryFileBackend


func before_each() -> void:
	super()
	_backend = LogfamiMemoryFileBackend.new()


func test_archive_path_keeps_the_extension() -> void:
	var policy: LogfamiRotationPolicy = LogfamiRotationPolicy.new()
	assert_eq(policy.archive_path(BASE, 1), "user://logs/app.1.log")
	assert_eq(policy.archive_path("user://logs/app.jsonl", 2), "user://logs/app.2.jsonl")
	assert_eq(policy.archive_path("user://logs/app", 1), "user://logs/app.1")


func test_all_paths_lists_current_then_archives() -> void:
	var policy: LogfamiRotationPolicy = LogfamiRotationPolicy.new(1000, 3)
	assert_eq(policy.all_paths(BASE), PackedStringArray([
		"user://logs/app.log",
		"user://logs/app.1.log",
		"user://logs/app.2.log",
	]))


func test_max_files_is_at_least_one() -> void:
	assert_eq(LogfamiRotationPolicy.new(10, 0).max_files, 1)


func test_should_rotate_at_max_lines() -> void:
	var policy: LogfamiRotationPolicy = LogfamiRotationPolicy.new(3, 3)
	assert_false(policy.should_rotate(2))
	assert_true(policy.should_rotate(3))


func test_zero_max_lines_never_rotates() -> void:
	assert_false(LogfamiRotationPolicy.new(0, 3).should_rotate(1_000_000))


func test_rotate_shifts_every_file_back() -> void:
	var policy: LogfamiRotationPolicy = LogfamiRotationPolicy.new(1000, 3)
	_put("user://logs/app.log", "current")
	_put("user://logs/app.1.log", "previous")

	policy.rotate(_backend, BASE)

	assert_false(_backend.exists("user://logs/app.log"))
	assert_eq(_first_line("user://logs/app.1.log"), "current")
	assert_eq(_first_line("user://logs/app.2.log"), "previous")


func test_rotate_drops_the_oldest_file() -> void:
	var policy: LogfamiRotationPolicy = LogfamiRotationPolicy.new(1000, 3)
	_put("user://logs/app.log", "current")
	_put("user://logs/app.1.log", "previous")
	_put("user://logs/app.2.log", "oldest")

	policy.rotate(_backend, BASE)

	assert_eq(_backend.files.size(), 2, "never more than max_files")
	assert_eq(_first_line("user://logs/app.1.log"), "current")
	assert_eq(_first_line("user://logs/app.2.log"), "previous")


func test_rotate_with_a_single_file_deletes_it() -> void:
	var policy: LogfamiRotationPolicy = LogfamiRotationPolicy.new(1000, 1)
	_put("user://logs/app.log", "current")

	policy.rotate(_backend, BASE)

	assert_eq(_backend.files.size(), 0)


func test_rotate_fills_gaps() -> void:
	var policy: LogfamiRotationPolicy = LogfamiRotationPolicy.new(1000, 3)
	_put("user://logs/app.log", "current")
	_put("user://logs/app.2.log", "oldest")

	policy.rotate(_backend, BASE)

	assert_eq(_first_line("user://logs/app.1.log"), "current")
	assert_false(_backend.exists("user://logs/app.2.log"), "the oldest falls off")


func _put(path: String, line: String) -> void:
	_backend.files[path] = PackedStringArray([line])


func _first_line(path: String) -> String:
	var lines: PackedStringArray = _backend.lines_of(path)
	return lines[0] if not lines.is_empty() else ""
