@tool
class_name LogfamiRotationPolicy
extends RefCounted
## Decides when a log file rotates and keeps the number of files bounded.
##
## With [code]max_files = 3[/code], [code]app.log[/code] is the current file,
## [code]app.1.log[/code] the one before and [code]app.2.log[/code] the oldest.
## Rotating moves every file one step back and deletes the one falling off.

## Lines per file before it rotates; 0 or less never rotates on size.
var max_lines: int
## Files kept in total, the current one included. At least 1.
var max_files: int


func _init(lines: int = 1000, files: int = 3) -> void:
	max_lines = lines
	max_files = maxi(files, 1)


## [code]app.log[/code] → [code]app.1.log[/code] for index 1.
func archive_path(base_path: String, index: int) -> String:
	var extension: String = base_path.get_extension()
	if extension == "":
		return "%s.%d" % [base_path, index]
	return "%s.%d.%s" % [base_path.get_basename(), index, extension]


## The current file followed by every archive slot, newest first.
func all_paths(base_path: String) -> PackedStringArray:
	var paths: PackedStringArray = [base_path]
	for index: int in range(1, max_files):
		paths.append(archive_path(base_path, index))
	return paths


func should_rotate(lines_in_file: int) -> bool:
	return max_lines > 0 and lines_in_file >= max_lines


## Shifts the files of [param base_path] one step back and drops the oldest.
## The current file is closed by the caller beforehand.
func rotate(backend: LogfamiFileBackend, base_path: String) -> void:
	var paths: PackedStringArray = all_paths(base_path)
	var oldest: String = paths[paths.size() - 1]
	if backend.exists(oldest):
		backend.remove(oldest)
	for index: int in range(paths.size() - 2, -1, -1):
		if backend.exists(paths[index]):
			backend.rename(paths[index], paths[index + 1])
