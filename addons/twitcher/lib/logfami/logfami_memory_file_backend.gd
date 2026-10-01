@tool
class_name LogfamiMemoryFileBackend
extends LogfamiFileBackend
## [LogfamiFileBackend] that keeps files in memory, for tests. Behaves like the
## strictest real filesystem: renaming onto an existing file fails.

## Path to its lines.
var files: Dictionary[String, PackedStringArray] = {}
var directories: PackedStringArray = []
## Path to the number of lines that were flushed.
var flushed_lines: Dictionary[String, int] = {}
var open_path: String = ""

## Failure switches, to test how the sink copes.
var fail_make_dir: bool = false
var fail_open: bool = false
var fail_write: bool = false


func make_dir(path: String) -> bool:
	if fail_make_dir:
		return false
	if not directories.has(path):
		directories.append(path)
	return true


func exists(path: String) -> bool:
	return files.has(path)


func line_count(path: String) -> int:
	return files.get(path, PackedStringArray()).size()


func remove(path: String) -> bool:
	if open_path == path:
		close()
	flushed_lines.erase(path)
	return files.erase(path)


func rename(from_path: String, to_path: String) -> bool:
	if not files.has(from_path) or files.has(to_path):
		return false
	files[to_path] = files[from_path]
	files.erase(from_path)
	flushed_lines[to_path] = flushed_lines.get(from_path, 0)
	flushed_lines.erase(from_path)
	return true


func open_file(path: String, append: bool) -> bool:
	close()
	if fail_open:
		return false
	if not append or not files.has(path):
		files[path] = PackedStringArray()
		flushed_lines[path] = 0
	open_path = path
	return true


func write_line(line: String) -> bool:
	if open_path == "" or fail_write:
		return false
	files[open_path].append(line)
	return true


func flush() -> void:
	if open_path != "":
		flushed_lines[open_path] = files[open_path].size()


func close() -> void:
	open_path = ""


## Lines of [param path], empty when it doesn't exist.
func lines_of(path: String) -> PackedStringArray:
	return files.get(path, PackedStringArray())
